resource "twc_ssh_key" "ansible_key" {
  name = "ansible_key"
  body = var.vm_ssh_public_key
}

resource "twc_floating_ip" "floating_ips" {
  for_each          = { for s in var.servers : s.name => s if s.floating_ip }
  availability_zone = var.availability_zone
  comment           = "Floating IP for ${each.value.name}"
}

data "template_file" "cloud_init_zabbix" {
  template = file("${path.module}/cloud_init_zabbix.yaml")
}

resource "twc_server" "vm" {
  for_each = { for srv in var.servers : srv.name => srv }

  name           = each.value.name
  preset_id      = each.value.preset_id
  project_id     = each.value.project_id
  os_id          = each.value.os_id
  ssh_keys_ids   = [twc_ssh_key.ansible_key.id]
  floating_ip_id = twc_floating_ip.floating_ips[each.key].id
  cloud_init     = data.template_file.cloud_init_zabbix.rendered
}
