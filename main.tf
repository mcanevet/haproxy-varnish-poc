variable "environment_id" {
  default = "1a122614"
}

provider "aws" {
  profile = "c2c"
  region  = "eu-west-1"
}

provider "rancher" {
  config = "${pathexpand("~/.rancher/cli-caas-dev.camptocamp.com.json")}"
}

data "template_file" "blue" {
  template = "${file("app/docker-compose.yml")}"

  vars {
    line = "blue"
  }
}

resource "rancher_stack" "blue" {
  name            = "blue"
  environment_id  = "${var.environment_id}"
  start_on_create = true
  finish_upgrade  = true
  docker_compose  = "${data.template_file.blue.rendered}"
  rancher_compose = "${file("app/rancher-compose.yml")}"
}

data "template_file" "green" {
  template = "${file("app/docker-compose.yml")}"

  vars {
    line = "green"
  }
}

resource "rancher_stack" "green" {
  name            = "green"
  environment_id  = "${var.environment_id}"
  start_on_create = true
  finish_upgrade  = true
  docker_compose  = "${data.template_file.green.rendered}"
  rancher_compose = "${file("app/rancher-compose.yml")}"
}

resource "rancher_stack" "reverse_proxy" {
  name            = "reverse-proxy"
  environment_id  = "${var.environment_id}"
  start_on_create = true
  finish_upgrade  = true
  docker_compose  = "${file("reverse-proxy/docker-compose.yml")}"
  rancher_compose = "${file("reverse-proxy/rancher-compose.yml")}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "reverse-proxy-stack-poc"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "semaphore" {
  bucket = "${aws_s3_bucket.bucket.bucket}"
  key    = "DANGER-ZONE/mode.txt"
  source = "mode.txt"
  acl    = "public-read"
}
