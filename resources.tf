# images
resource "docker_image" "bgg-database" {
  name = "chukmunnlee/bgg-database:${var.database_version}"
}

resource "docker_image" "bgg-backend" {
  name = "chukmunnlee/bgg-backend:${var.backend_version}"
}


resource "docker_container" "bgg-backend" {

  count = var.backend_instance_count

  name = "${var.app_namespace}-bgg-backend-${count.index}"
  image = docker_image.bgg-backend.image_id

  networks_advanced {
  name = docker_network.bgg-net.id
  }

  env = [
  "BGG_DB_USER=root",
  "BGG_DB_PASSWORD=changeit",
  "BGG_DB_HOST=${docker_container.bgg-database.name}",
  ]

  ports {
    internal = 8080
  }
}

data "digitalocean_ssh_key" "terraform" {
  name = var.do_ssh_key
}

resource "local_file" "root_at_nginx" {
  filename = "root@${digitalocean_droplet.nginx.ipv4_address}"
  content = ""
  file_permission = "0444"
}


output backend_ports {
  value = docker_container.bgg-backend[*].ports[0].external
}