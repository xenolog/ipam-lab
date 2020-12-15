resource "local_file" "cp1_user_data" {
  filename = format("env__%s/cp1_user_data.yaml", var.env_name)
  content = templatefile("./templates/cp1_user_data.tmpl", {
    disable_root = var.ssh_disable_root
    gw           = openstack_networking_subnet_v2.mgmt.gateway_ip
    slave_nodes  = [for node in openstack_compute_instance_v2.minion_instance : node if node.name != local.cp1st_node.name]
  })
  depends_on = [
    openstack_compute_instance_v2.cp_instance,
    openstack_compute_instance_v2.minion_instance
  ]
}

# resource "local_file" "inventory" {
#   filename = format("env__%s/%s", var.env_name, var.output_inventory_file_name)
#   content = templatefile("./templates/inventory.tmpl", {
#     env_name       = var.env_name
#     network_plugin = var.kubespray_network_plugin
#     ssh_key_file   = var.ssh_private_key_file
#     floating_ip    = openstack_compute_floatingip_associate_v2.cp_instance_floating_ip.floating_ip
#     cps            = openstack_compute_instance_v2.cp_instance
#     minions        = openstack_compute_instance_v2.minion_instance
#     k8s_dashboard  = var.k8s_dashboard
#     # minion_numbers = var.minion_numbers
#   })
#   depends_on = [
#     openstack_compute_instance_v2.cp_instance,
#     openstack_compute_instance_v2.minion_instance
#   ]
# }

output "cp1_instance_floating_ip_addr" {
  value = openstack_compute_floatingip_associate_v2.cp_instance_floating_ip.floating_ip
}

output "CPs_mgmt_ip_addrs" {
  value = { for m in values(openstack_compute_instance_v2.cp_instance) : m.name => m.network[0].fixed_ip_v4 }
}

output "minions_mgmt_ip_addrs" {
  value = { for m in values(openstack_compute_instance_v2.minion_instance) : m.name => m.network[0].fixed_ip_v4 }
}


output "rack_networks" {
  value = local.rack_networks
}

output "nodes" {
  value = local.nodes
}

###
