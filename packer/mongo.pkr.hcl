locals { 
  timestamp = regex_replace(timestamp(), "[- TZ:]", "") 
}

source "amazon-ebs" "mongodb" {
  ami_name      = "packer mongodb ${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-2.*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.mongodb"]

  provisioner "file" {
    source      = "./mongodb-org-4.4.repo"
    destination = "/tmp/mongodb-org-4.4.repo"
  }

  provisioner "shell" {
    script = "./mongo_setup.sh"
  }
}