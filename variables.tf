variable do_token {
  type = string
  sensitive = true
}

variable docker_host {
  type = string
}

variable docker_cert_path {
  type = string
  sensitive = true
}

variable app_namespace {
  type = string
  default = "my"
}

variable do_region {
  type = string
  default = "sgp1"
}

variable backend_version {
  type = string
  default = "latest"
}

variable do_image {
  type = string
  default = "ubuntu-20-04-x64"
}

variable do_size {
  type = string
  default = "s-2vcpu-4gb"
}

variable nginx_do_size {
  type = string
  default = "s-1vcpu-512mb-10gb"
}

variable do_ssh_key {
  type = string
  default = "terraform"
}

variable ssh_private_key {
  type = string
}

variable backend_instance_count{
  type = number
  default = 2
}