resource "openstack_networking_router_v2" "k8s" {
  name                = "${var.cluster_name}-router"
  count               = "${var.use_neutron}"
  admin_state_up      = "true"
  external_network_id = "${var.external_net}"
/*
  enable_snat         = "${var.router_disable_snat == "true" ? false : true}"
*/
}

resource "openstack_networking_network_v2" "k8s" {
  name           = "${var.network_name}"
  count          = "${var.use_neutron}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "k8s" {
  name            = "${var.cluster_name}-internal-network"
  count           = "${var.use_neutron}"
  network_id      = "${openstack_networking_network_v2.k8s.id}"
  cidr            = "${var.subnet_cidr}"
  ip_version      = 4
  dns_nameservers = "${var.dns_nameservers}"
/*
  no_gateway      = "${var.k8s_subnet_no_gateway == "true" ? true : false}"
*/
  gateway_ip      = "${cidrhost(var.subnet_cidr, var.k8s_subnet_gw_index)}"
}

resource "openstack_networking_port_v2" "neutron_router_k8s_network_port" {
  count          = "${var.use_neutron}"
  name           = "neutron_router_k8s_port"
  network_id     = "${element(openstack_networking_network_v2.k8s.*.id, 0)}"
  admin_state_up = true
  fixed_ip       = [
    {
      "subnet_id"      = "${element(openstack_networking_subnet_v2.k8s.*.id, 0)}"
      "ip_address"     = "${cidrhost(var.subnet_cidr, var.neutron_router_index_in_k8s_subnet)}"
    }
  ]
  depends_on = ["openstack_networking_subnet_v2.k8s"]
}

resource "openstack_networking_router_interface_v2" "k8s_router_main_interface" {
  count            = "${var.use_neutron}"
  router_id        = "${element(openstack_networking_router_v2.k8s.*.id, 0)}"
  port_id          = "${element(openstack_networking_port_v2.neutron_router_k8s_network_port.*.id, count.index)}"
}

resource "openstack_networking_port_v2" "networks_ports" {
  count          = "${((!var.use_neutron) || (var.vyos_router == "true")) ? 0 : length(keys(var.router_extra_interfaces))}"
  name           = "${format("%s - %s", var.network_name, element(keys(var.router_extra_interfaces), count.index))}"
  network_id     = "${element(keys(var.router_extra_interfaces), count.index)}"
  admin_state_up = "true"
  fixed_ip       = "${var.router_extra_interfaces[element(keys(var.router_extra_interfaces), count.index)]}"
}

resource "openstack_networking_router_interface_v2" "k8s_router_extra_interfaces" {
  count            = "${((!var.use_neutron) || (var.vyos_router == "true")) ? 0 : length(keys(var.router_extra_interfaces))}"
  depends_on       = ["openstack_networking_router_v2.k8s", "openstack_networking_port_v2.networks_ports"]
  router_id        = "${element(openstack_networking_router_v2.k8s.*.id, 0)}"
  port_id          = "${element(openstack_networking_port_v2.networks_ports.*.id, count.index)}"
}

resource "openstack_networking_router_route_v2" "k8s_router_extra_routes" {
  count            = "${((!var.use_neutron) || (var.vyos_router == "true")) ? 0 : length(keys(var.router_extra_routes))}"
  router_id        = "${openstack_networking_router_v2.k8s.id}"
  destination_cidr = "${element(keys(var.router_extra_routes), count.index)}"
  next_hop         = "${lookup(var.router_extra_routes, element(keys(var.router_extra_routes), count.index))}"
  depends_on       = [ "openstack_networking_router_interface_v2.k8s_router_main_interface", "openstack_networking_router_interface_v2.k8s_router_extra_interfaces"]
}
