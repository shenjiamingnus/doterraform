# images
resource "docker_image" "dealhunter-backend" {
  name = "nandonus/dealhunter-backend:${var.backend_version}"
}

#data "docker_registry_image" "dealhunter" {
#name = "nandonus/dealhunter-backend:${var.backend_version}"
#}
#
#resource "docker_image" "dealhunter-backend" {
#name = data.docker_registry_image.dealhunter.name
#pull_triggers = [data.docker_registry_image.dealhunter.sha256_digest]
#}

# the stack
resource "docker_network" "dealhunter-net" {
  name = "${var.app_namespace}-dealhunter-net"
}

resource "docker_container" "dealhunter-backend" {

  count = var.backend_instance_count

  name = "${var.app_namespace}-dealhunter-backend-${count.index}"
  image = docker_image.dealhunter-backend.image_id

  networks_advanced {
    name = docker_network.dealhunter-net.id
  }

  ports {
    internal = 8080
  }
}

resource "local_file" "nginx-conf" {
  filename = "nginx.conf"
  content = templatefile("sample.nginx.conf.tftpl", {
    docker_host = var.docker_host,
    ports = docker_container.dealhunter-backend[*].ports[0].external
  })
}

data "digitalocean_ssh_key" "terraform" {
  name = var.do_ssh_key
}


resource "digitalocean_droplet" "nginx" {
  name = "nginx"
  image = var.do_image
  region = var.do_region
  size = var.do_size

  ssh_keys = [ data.digitalocean_ssh_key.terraform.id ]

  connection {
    type = "ssh"
    user = "root"
    private_key = file(var.ssh_private_key)
    host = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "apt update -y",
      "apt install nginx -y",
    ]
  }
  provisioner "file" {
    source = local_file.nginx-conf.filename
    destination = "/etc/nginx/nginx.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "systemctl restart nginx",
      "systemctl enable nginx",
    ]
  }
}

resource "local_file" "root_at_nginx" {
  filename = "root@${digitalocean_droplet.nginx.ipv4_address}"
  content = ""
  file_permission = "0444"
}

output nginx_ip {
  value = digitalocean_droplet.nginx.ipv4_address
}

output backend_ports {
  value = docker_container.dealhunter-backend[*].ports[0].external
}