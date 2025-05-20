resource "twc_firewall" "security_firewall" {
  name        = "security-firewall"
  description = "Фаервол для управления доступом"

  dynamic "link" {
    for_each = {
      for srv in var.servers : srv.name => srv if srv.floating_ip
    }
    content {
      id   = twc_server.vm[link.key].id
      type = "server"
    }
  }
}

resource "twc_firewall_rule" "security_allow_ssh" {
  firewall_id = twc_firewall.security_firewall.id
  direction   = "ingress"
  protocol    = "tcp"
  port        = 22
  cidr        = "0.0.0.0/0"
}

resource "twc_firewall_rule" "allow_zabbix" {
  for_each = toset([
    "92.53.116.12/32",
    "92.53.116.111/32",
    "92.53.116.119/32"
  ])

  firewall_id = twc_firewall.security_firewall.id
  direction   = "ingress"
  protocol    = "tcp"
  port        = 10050
  cidr        = each.value
}