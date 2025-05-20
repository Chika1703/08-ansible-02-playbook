output "vm_list" {
  value = [
    for i, server in twc_server.vm : {
      name = server.name,
      ipv4 = twc_floating_ip.floating_ips[i].ip,
    }
  ]
}