// #AMI For autoscaling group

// packer {
//   required_plugins {
//     amazon = {
//       version = ">= 0.0.2"
//       source  = "github.com/hashicorp/amazon"
//     }
//   }
// }

// locals {
//   timestamp = regex_replace(timestamp(), "[- TZ:]", "")
// }

// variable "green_ami_prefix" {
//   type    = string
//   default = "green_ami"
// }

// variable "blue_ami_prefix" {
//   type    = string
//   default = "blue_ami"
// }

// variable "bluedeploy" {
//   type    = string
//   default = "blue"
// }

// variable "greendeploy" {
//   type    = string
//   default = "green"
// }




// source "amazon-ebs" "ubuntu_blue" {
//   ami_name      = "${var.blue_ami_prefix}-${local.timestamp}"
//   instance_type = "t2.micro"
//   region        = "eu-west-1"
//   vpc_id        = "vpc-0cbc001bef7bb7c67"
//   subnet_id     = "subnet-0dd911e392accd5ef"
//   source_ami_filter {
//     filters = {
//       name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
//       root-device-type    = "ebs"
//       virtualization-type = "hvm"
//     }
//     most_recent = true
//     owners      = ["099720109477"]
//   }
//   ssh_username = "ubuntu"
// }


// source "amazon-ebs" "ubuntu_green" {
//   ami_name      = "${var.green_ami_prefix}-${local.timestamp}"
//   instance_type = "t2.micro"
//   region        = "eu-west-1"
//   vpc_id        = "vpc-0cbc001bef7bb7c67"
//   subnet_id     = "subnet-0dd911e392accd5ef"
//   source_ami_filter {
//     filters = {
//       name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
//       root-device-type    = "ebs"
//       virtualization-type = "hvm"
//     }
//     most_recent = true
//     owners      = ["099720109477"]
//   }
//   ssh_username = "ubuntu"
// }


// build {
//   name = "Blue-deploy"
//   sources = [
//     "source.amazon-ebs.ubuntu_blue"
//   ]

//   provisioner "ansible" {
//     playbook_file   = "./playbooks/main.yml"
//     extra_arguments = ["--extra-vars", "color=${var.bluedeploy}"]

//   }
// }


// build {
//   name = "Green-deploy"
//   sources = [
//     "source.amazon-ebs.ubuntu_green"
//   ]

//   provisioner "ansible" {
//     playbook_file   = "./playbooks/main.yml"
//     extra_arguments = ["--extra-vars", "color=${var.greendeploy}"]

//   }
// }

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "AMI-BUILD"
}

variable "bldeploy" {
  type    = string
  default = "blue"
}

variable "grdeploy" {
  type    = string
  default = "green"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}



source "amazon-ebs" "Blue" {
  ami_name          = "${var.ami_prefix}-Blue-${local.timestamp}"
  instance_type     = "t3.small"
  region            = "eu-west-1"
  vpc_id            = "vpc-0cd8edf62d9e6db71"
  subnet_id         = "subnet-0a7ae8339e4678a50"
  security_group_id = "sg-06daab54ed9f99c68"


  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name" = "Blue-Server"
  }

}

build {
  name = "  Blue-packer"
  sources = [
    "source.amazon-ebs.Blue",
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/main.yml"
    extra_arguments = ["--extra-vars", "color=${var.bldeploy}"]

  }
}

source "amazon-ebs" "Green" {
  ami_name          = "${var.ami_prefix}-Green-${local.timestamp}"
  instance_type     = "t3.small"
  region            = "eu-west-1"
  vpc_id            = "vpc-0cd8edf62d9e6db71"
  subnet_id         = "subnet-0a7ae8339e4678a50"
  security_group_id = "sg-06daab54ed9f99c68"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name" = "Green-Server"
  }
  deprecate_at = timeadd(timestamp(), "8766h")
}

build {
  name = " Green-packer"
  sources = [
    "source.amazon-ebs.Green"
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/main.yml"
    extra_arguments = ["--extra-vars", "color=${var.grdeploy}"]
  }
}

