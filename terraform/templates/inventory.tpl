deb:
  hosts:
%{ for i, inst in vms ~}
%{ if substr(inst.name, 0, 3) == "deb" }
    ${inst.name}:
      ansible_host: ${floating_ips[i].ip}
%{ endif }
%{ endfor }

el:
  hosts:
%{ for i, inst in vms ~}
%{ if substr(inst.name, 0, 2) == "el" }
    ${inst.name}:
      ansible_host: ${floating_ips[i].ip}
%{ endif }
%{ endfor }

clickhouse:
  hosts:
%{ for i, inst in vms ~}
%{ if substr(inst.name, 0, 3) == "deb" }
    ${inst.name}:
      ansible_host: ${floating_ips[i].ip}
%{ endif }
%{ endfor }
