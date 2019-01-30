resource "openstack_networking_port_v2" "vyos_k8s_network_port" {
  count          = "${(var.vyos_router == "true") ? 1 : 0}"
  name           = "vyos_k8s_port"
  network_id     = "${var.k8s_network_id}"
  admin_state_up = true
  fixed_ip       = [
    {
      "subnet_id"  = "${var.k8s_subnet_id}"
      "ip_address" = ""
    }
  ]
}

resource "openstack_networking_port_v2" "vyos_networks_ports" {
  count          = "${(var.vyos_router == "false") ? 0 : length(keys(var.router_extra_interfaces))}"
  name           = "${format("vyos - %s - %s", var.network_name, element(keys(var.router_extra_interfaces), count.index))}"
  network_id     = "${element(keys(var.router_extra_interfaces), count.index)}"
  admin_state_up = "true"
  fixed_ip       = "${var.router_extra_interfaces[element(keys(var.router_extra_interfaces), count.index)]}"
}

data "openstack_networking_subnet_v2" "ports_subnets" {
  count          = "${(var.vyos_router == "false") ? 0 : length(keys(var.router_extra_interfaces))}"
  subnet_id      = "${element(openstack_networking_port_v2.vyos_networks_ports.*.fixed_ip.0.subnet_id, count.index)}"
}

data "template_file" "ports_subnets_tpl" {
  count = "${(var.vyos_router == "false") ? 0 : length(keys(var.router_extra_interfaces))}"
  template = "${file("${path.module}/templates/ports_subnets.tpl")}"
  vars = {
    netbits = "${element(split("/",element(data.openstack_networking_subnet_v2.ports_subnets.*.cidr, count.index)), 1)}"
    mac     = "${element(openstack_networking_port_v2.vyos_networks_ports.*.mac_address, count.index)}"
    ip      = "${element(openstack_networking_port_v2.vyos_networks_ports.*.fixed_ip.0.ip_address, count.index)}"
  }
}

data "template_file" "port_k8s_subnet_tpl" {
  count = "${(var.vyos_router == "false") ? 0 : 1}"
  template = "${file("${path.module}/templates/ports_subnets.tpl")}"
  vars = {
    netbits = "${element(split("/", var.k8s_subnet_cidr), 1)}"
    mac     = "${element(openstack_networking_port_v2.vyos_k8s_network_port.*.mac_address, count.index)}"
    ip      = "dhcp"
  }
}

data "template_file" "extra_routes_tpl" {
  count = "${(var.vyos_router == "false") ? 0 : length(keys(var.router_extra_routes))}"
  template = "${file("${path.module}/templates/extra_routes.tpl")}"
  vars = {
    destination_cidr = "${element(keys(var.router_extra_routes), count.index)}"
    next_hop         = "${lookup(var.router_extra_routes, element(keys(var.router_extra_routes), count.index))}"
  }
}

data "template_file" "vyos_user" {
  count = "${(var.vyos_router == "false") ? 0 : 1}"
  template = "${file("${path.module}/templates/user.tpl")}"
  vars = {
    user = "${var.vyos_user}"
    pwd  = "${var.vyos_user_pwd}"
  }
}

data "template_file" "vyos_delete_default_user" {
  count = "${(var.vyos_router == "false") ? 0 : (var.vyos_delete_vyos_user == "true" ? 1 : 0)}"
  template = "${file("${path.module}/templates/delete_default_user.tpl")}"
  vars = {
  }
}


resource "openstack_compute_instance_v2" "vyos_instance" {
  name       = "${var.cluster_name}-vyos"
  count      = "${(var.vyos_router == "true") ? 1 : 0}"
  availability_zone = "${element(var.az_list, count.index)}"
  image_name = "${var.vyos_image}"
  flavor_id  = "${var.flavor_vyos}"
  key_pair   = "${var.keypair}"

  network {
    port = "${openstack_networking_port_v2.vyos_k8s_network_port.0.id}"
  }

  security_groups = ["default"]

  user_data  = "${join("", concat(list("#!/bin/vbash\nWRAPPER=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper\n$${WRAPPER} begin\n"), data.template_file.ports_subnets_tpl.*.rendered, data.template_file.port_k8s_subnet_tpl.*.rendered, data.template_file.extra_routes_tpl.*.rendered, data.template_file.vyos_user.*.rendered, data.template_file.vyos_delete_default_user.*.rendered, list("$${WRAPPER} commit\n", "$${WRAPPER} save\n", "$${WRAPPER} end\n")))}"

  metadata = {
    depends_on       = "${var.k8s_network_id}"
  }
}

resource "openstack_compute_interface_attach_v2" "attachments" {
  count       = "${(var.vyos_router == "false") ? 0 : length(keys(var.router_extra_interfaces))}"
  instance_id = "${openstack_compute_instance_v2.vyos_instance.0.id}"
  port_id     = "${openstack_networking_port_v2.vyos_networks_ports.*.id[count.index]}"
  depends_on  = ["openstack_networking_port_v2.vyos_networks_ports"]
}

resource "openstack_networking_subnet_route_v2" "routes_to_vyos" {
  count            = "${(var.vyos_router == "false") ? 0 : length(var.routes_to_vyos)}"
  destination_cidr = "${var.routes_to_vyos[count.index]}"
  next_hop         = "${openstack_compute_instance_v2.vyos_instance.access_ip_v4}"
  subnet_id        = "${var.k8s_subnet_id}"
}
