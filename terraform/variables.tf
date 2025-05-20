variable "twc_token" {
  description = "API токен Timeweb Cloud"
  type        = string
  sensitive   = true
}

variable "vm_ssh_public_key" {
  description = "SSH публичный ключ для доступа к виртуальным машинам"
  type        = string
}

variable "vm_ssh_private_key" {
  description = "SSH приватный ключ для доступа к виртуальным машинам"
  type        = string
  sensitive   = true
}
variable "servers" {
  description = "Список конфигураций серверов"
  type = list(object({
    name              = string
    preset_id         = number
    project_id        = number
    os_id             = number
    ssh_keys_ids      = list(number)
    floating_ip       = bool
    local_network_ip  = optional(string)
  }))
  default = [
    {
      name             = "deb"
      preset_id        = 4795
      project_id       = 1407935
      os_id            = 79
      ssh_keys_ids     = [288185]
      floating_ip      = true
      local_network_ip = "192.168.0.4"
    },
    {
      name             = "el"
      preset_id        = 4795
      project_id       = 1407935
      os_id            = 79
      ssh_keys_ids     = [288185]
      floating_ip      = true
      local_network_ip = "192.168.0.5"
    }
  ]
}

variable "availability_zone" {
  description = "Зона доступности для ресурсов"
  type        = string
  default     = "msk-1"
}

variable "local_network_id" {
  description = "ID приватной (локальной) сети"
  type        = string
  default     = ""
}
