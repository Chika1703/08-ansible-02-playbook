resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    vms          = values(twc_server.vm)
    floating_ips = values(twc_floating_ip.floating_ips)
  })
  filename = "${path.module}/../playbook/inventory/prod.yml"
}
