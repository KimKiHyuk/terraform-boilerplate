provider "rke" {
  debug    = true
  log_file = "rke.log"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


resource "rke_cluster" "aws_rke_cluster" {
  cloud_provider {
    name = "aws"
  }

  nodes {
    address = aws_instance.rke_main.private_ip
    user    = var.ssh_username
    ssh_key = file("k8s.pem")
    role    = ["controlplane", "etcd"]
  }
  nodes {
    address = aws_instance.rke_node[0].private_ip
    user    = var.ssh_username
    ssh_key = file("k8s.pem")
    role    = ["worker"]
  }
  nodes {
    address = aws_instance.rke_node[1].private_ip
    user    = var.ssh_username
    ssh_key = file("k8s.pem")
    role    = ["worker"]
  }
}

resource "local_file" "kube_cluster_yaml" {
  filename = "./kube_config_cluster.yml"
  content  = rke_cluster.aws_rke_cluster.kube_config_yaml
}
