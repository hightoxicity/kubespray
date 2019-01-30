variable "vyos_router" {}

variable "k8s_network_id" {
  default = ""
}

variable "k8s_network_name" {}

variable "vyos_image" {}

variable "flavor_vyos" {}

variable "keypair" {}

variable "cluster_name" {}

variable "az_list" {
  type = "list"
}

variable "router_extra_interfaces" {
  type = "map"
}

variable "router_extra_routes" {
  type = "map"
}

variable "network_name" {}

variable "k8s_subnet_id" {}

variable "k8s_subnet_cidr" {}

variable "vyos_user" {}

variable "vyos_user_pwd" {}

variable "vyos_delete_vyos_user" {}

variable "routes_to_vyos" {
  type    = "list"
  default = []
}
