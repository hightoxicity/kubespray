output "router_id" {
  value = "${element(concat(openstack_networking_router_v2.k8s.*.id, list("")), 0)}"
}

output "router_internal_port_id" {
  value = "${element(concat(openstack_networking_port_v2.neutron_router_k8s_network_port.*.id, list("")), 0)}"

}

output "subnet_id" {
  value = "${element(concat(openstack_networking_subnet_v2.k8s.*.id, list("")), 0)}"
}

output "network_id" {
  value = "${element(concat(openstack_networking_network_v2.k8s.*.id, list("")), 0)}"
}
