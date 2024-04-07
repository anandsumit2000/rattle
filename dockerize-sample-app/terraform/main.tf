provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address     = "registry-1.docker.io"
    config_file = pathexpand("~/.docker/config.json")
    username    = "anandsumit2000"
    password    = "sumitanand@81199"
  }
}

resource "docker_image" "image" {
  name = "${var.profile_name}/${var.image_name}"
  build {
    context    = "../"
    dockerfile = "Dockerfile"
    tag        = ["registry-1.docker.io/${var.profile_name}/${var.image_name}:${var.tag}"]
  }
}


resource "docker_registry_image" "image" {
  name          = docker_image.image.name
  keep_remotely = true
}
