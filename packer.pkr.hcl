packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
      name = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  name = "web-nginx"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo creating directories",
      "sudo mkdir -p /web/html",
      "sudo chown -R ubuntu:ubuntu /web/html",
      "mkdir -p /tmp/web"
    ]
  }

  provisioner "file" {
    source      = "scripts/install-nginx"
    destination = "/tmp/install-nginx"
  }

  provisioner "file" {
    source      = "scripts/setup-nginx"
    destination = "/tmp/setup-nginx"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install-nginx",
      "sudo /tmp/install-nginx",
    ]
  }

  provisioner "file" {
    source      = "files/index.html"
    destination = "/web/html/index.html"
  }

  provisioner "file" {
    source      = "files/nginx.conf"
    destination = "/tmp/web/nginx.conf"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup-nginx",
      "sudo /tmp/setup-nginx"
    ]
  }
}