variable "external_net" {}

variable "network_name" {}

variable "cluster_name" {}

variable "dns_nameservers" {
  type = "list"
}

variable "subnet_cidr" {}

variable "use_neutron" {}

variable "router_extra_interfaces" {
  type = "map"
}

variable "router_extra_routes" {
  type = "map"
}

/*
variable "router_disable_snat" {
  type        = "string"
}
*/

variable "vyos_router" {}

/*
variable "k8s_subnet_no_gateway" {}
*/

variable "neutron_router_index_in_k8s_subnet" {}

variable "k8s_subnet_gw_index" {}
