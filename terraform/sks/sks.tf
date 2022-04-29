terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.30.0"
    }
  }
}

locals {
  zone = "at-vie-1"
}

provider "exoscale" {
  key = var.key
  secret = var.secret
}

variable "key"{
  description = "Please enter your API KEY"
}

variable "secret"{
  description = "Please enter your API Secret"
}

variable "workernodes"{
  description = "Please enter the count of Workernodes"
}

#BEGIN_OLD_FILE
# Change version to the currently available Exoscale SKS version
resource "exoscale_sks_cluster" "SKS-Cluster" {
  zone          = local.zone
  name          = "data-exchange-platform"
  version       = "1.23.3"
  description   = "Scaleable-Data-Exchange-Platform"
  service_level = "starter"
  auto_upgrade = true
  exoscale_ccm = true
  metrics_server = true
  cni = "calico"
}

# This provisions an instance pool of nodes which will run the Kubernetes
# workloads. It is possible to attach multiple nodepools to the cluster:
# https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_nodepool
# Check instance types: https://www.exoscale.com/pricing/#/compute/

resource "exoscale_sks_nodepool" "prod" {
  zone               = local.zone
  cluster_id         = exoscale_sks_cluster.SKS-Cluster.id
  name               = "prod"
  instance_type      = "standard.small"
  size               = var.workernodes
  security_group_ids = [exoscale_security_group.sks_nodes.id]
}

# Create a security group so the nodes can communicate and we can pull logs

resource "exoscale_security_group" "sks_nodes" {
  name        = "sks_nodes"
  description = "Allows traffic between sks nodes and public pulling of logs"
}

resource "exoscale_security_group_rule" "sks_nodes_logs_rule" {
  security_group_id = exoscale_security_group.sks_nodes.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 10250
  end_port          = 10250
  description       = "Kubelet"
  user_security_group_id = exoscale_security_group.sks_nodes.id
}

resource "exoscale_security_group_rule" "sks_nodes_calico" {
  security_group_id      = exoscale_security_group.sks_nodes.id
  type                   = "INGRESS"
  protocol               = "UDP"
  start_port             = 4789
  end_port               = 4789
  description            = "Calico CNI networking"
  user_security_group_id = exoscale_security_group.sks_nodes.id
}

resource "exoscale_security_group_rule" "sks_nodes_ccm" {
  security_group_id = exoscale_security_group.sks_nodes.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 30000
  end_port          = 32767
  description       = "NodePort services"
  cidr              = "0.0.0.0/0"
}
