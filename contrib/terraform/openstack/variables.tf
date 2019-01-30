variable "cluster_name" {
  default = "example"
}

variable "az_list" {
  description = "List of Availability Zones available in your OpenStack cluster"
  type = "list"
  default = ["nova"]
}

variable "number_of_bastions" {
  default = 1
}

variable "number_of_k8s_masters" {
  default = 2
}

variable "number_of_k8s_masters_no_etcd" {
  default = 2
}

variable "number_of_etcd" {
  default = 2
}

variable "number_of_k8s_masters_no_floating_ip" {
  default = 2
}

variable "number_of_k8s_masters_no_floating_ip_no_etcd" {
  default = 2
}

variable "number_of_k8s_nodes" {
  default = 1
}

variable "number_of_k8s_nodes_no_floating_ip" {
  default = 1
}

variable "number_of_gfs_nodes_no_floating_ip" {
  default = 0
}

variable "gfs_volume_size_in_gb" {
  default = 75
}

variable "public_key_path" {
  description = "The path of the ssh pub key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "image" {
  description = "the image to use"
  default     = "ubuntu-14.04"
}

variable "image_gfs" {
  description = "Glance image to use for GlusterFS"
  default     = "ubuntu-16.04"
}

variable "ssh_user" {
  description = "used to fill out tags for ansible inventory"
  default     = "ubuntu"
}

variable "ssh_user_gfs" {
  description = "used to fill out tags for ansible inventory"
  default     = "ubuntu"
}

variable "flavor_bastion" {
  description = "Use 'nova flavor-list' command to see what your OpenStack instance uses for IDs"
  default     = 3
}

variable "flavor_k8s_master" {
  description = "Use 'nova flavor-list' command to see what your OpenStack instance uses for IDs"
  default     = 3
}

variable "flavor_k8s_node" {
  description = "Use 'nova flavor-list' command to see what your OpenStack instance uses for IDs"
  default     = 3
}

variable "flavor_etcd" {
  description = "Use 'nova flavor-list' command to see what your OpenStack instance uses for IDs"
  default     = 3
}

variable "flavor_gfs_node" {
  description = "Use 'nova flavor-list' command to see what your OpenStack instance uses for IDs"
  default     = 3
}

variable "network_name" {
  description = "name of the internal network to use"
  default     = "internal"
}

variable "use_neutron" {
  description = "Use neutron"
  default     = 1
}

variable "subnet_cidr" {
  description = "Subnet CIDR block."
  type = "string"
  default = "10.0.0.0/24"
}

variable "dns_nameservers" {
  description = "An array of DNS name server names used by hosts in this subnet."
  type        = "list"
  default     = []
}

variable "floatingip_pool" {
  description = "name of the floating ip pool to use"
  default     = "external"
}

variable "external_net" {
  description = "uuid of the external/public network"
}

variable "supplementary_master_groups" {
  description = "supplementary kubespray ansible groups for masters, such kube-node"
  default = ""
}

variable "supplementary_node_groups" {
  description = "supplementary kubespray ansible groups for worker nodes, such as kube-ingress"
  default = ""
}

variable "bastion_allowed_remote_ips" {
  description = "An array of CIDRs allowed to SSH to hosts"
  type = "list"
  default = ["0.0.0.0/0"]
}

variable "worker_allowed_ports" {
  type = "list"
  default = [
    {
      "protocol" = "tcp"
      "port_range_min" = 30000
      "port_range_max" = 32767
      "remote_ip_prefix" = "0.0.0.0/0"
    }
  ]
}

variable "router_extra_interfaces" {
  type        = "map"
  description = "Map of network to connect (network id as key, List of map of strings with subnet_id/ip_address, look at fixed_ip on openstack_networking_port_v2 for help)"
  default     = {
  }
}

variable "router_extra_routes" {
  type        = "map"
  description = "A map of routes to register near the kube neutron router (key=route, value=nexthop)"
  default     = {
  }
}

variable "use_fip_to_ssh" {
  type        = "string"
  description = "When set to false, the host script will use private ip of instances instead of floating ip"
  default     = "true"
}

/*
variable "router_disable_snat" {
  type        = "string"
  description = "Allow to disable snat on k8s neutron router (true or false as string)"
  default     = "false"
}
*/

variable "vyos_router" {
  type        = "string"
  description = "Spawn a vyos software router"
  default     = "false"
}

variable "vyos_image" {
  type        = "string"
  description = "Vyos image to use"
  default     = "vyos"
}

variable "flavor_vyos" {
  description = "Use 'nova flavor-list' command to see what your OpenStack instance uses for IDs"
  default     = 3
}

variable "vyos_user" {
  type        = "string"
  description = "User to create on the vyos instance"
  default     = "vyos"
}

variable "vyos_user_pwd" {
  type        = "string"
  description = "vyos_user mkpasswd -m sha-512 crypted password (default = vyos)"
  default     = "$6$Mln2atYRwvfJ7$a8aW.pHBsqenSH2N0lmd1f7LOHrafIEjVYaBzYTOWTKcAAwGME.jWpQ8QnutI79.q1QW2QZPmNaStlwGAE.pn/"
}

variable "vyos_delete_vyos_user" {
  type        = "string"
  description = "true to delete vyos default user"
  default     = "false"
}

/*
variable "k8s_subnet_no_gateway" {
  type        = "string"
  description = "true to not set df gateway on k8s subnet"
  default     = "false"
}
*/

variable "neutron_router_index_in_k8s_subnet" {
  type        = "string"
  description = "neutron router index to compute ip"
  default     = "1"
}

variable "k8s_subnet_gw_index" {
  type        = "string"
  description = "Gateway index to compute ip"
  default     = "1"
}

variable "routes_to_vyos" {
  type        = "list"
  description = "Routes to vyos on k8s subnet"
  default     = []
}
