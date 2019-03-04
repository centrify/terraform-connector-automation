
terraform {
  required_version = ">= 0.8"  
}

provider "aws" {    
    region = "us-west-2"    
}

variable "reg_user" {
    description = "The user identity to use to register the connector"
}

variable "reg_pass" {
    description = "Password for the registering user"
}

variable "reg_url" {
    description = "Podscape URL to register connector with"
}

variable "conn_url" {
    description = "Cloud-Management-Suite-win64.zip Download URL"
    default = "https://edge.centrify.com/products/cloud-service/ProxyDownload/Cloud-Management-Suite-win64.zip"
}

data "aws_ami" "windows_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*Windows_Server-2016-English-Full-Base*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "tls_private_key" "cfy_machine_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cfy_machine_key" {
  key_name   = "cfy_machine_key"
  public_key = "${tls_private_key.cfy_machine_key_pair.public_key_openssh}"
}

resource "local_file" "cfy_machine_priv_key_file" {
  content = "${tls_private_key.cfy_machine_key_pair.private_key_pem}"
  filename = "${path.module}/cfy_machine_key.priv"
}

resource "aws_security_group" "cfy_rdp_sg" {
  name = "cfy_rdp_sg"
  
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"    
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }    

  tags {
    Name = "cfy_rdp_sg"
  }
}

resource "aws_instance" "cfy_connector_instance" {    
  ami                    = "${data.aws_ami.windows_ami.id}"  
  instance_type          = "t2.medium"
  key_name               = "${aws_key_pair.cfy_machine_key.key_name}"  
  user_data              = "${data.template_file.mgmt_user_data_payload.rendered}"
  vpc_security_group_ids = ["${aws_security_group.cfy_rdp_sg.id}"]  
  get_password_data      = true
  associate_public_ip_address = true
  
  count                  = 1

  root_block_device {
    volume_size = "100"
    delete_on_termination = true
  }

  tags {
    Name = "cfy-connector-instance-${count.index}"    
  }
}

resource "random_string" "password_gen" {
  length = 16
  upper = true
  min_upper = 4
  lower = true
  min_lower = 4
  number = true
  min_numeric = 4
  special = true
  min_special = 4
  override_special = "!@#%&*()-_=+[]{}<>:?"  
}

data "template_file" "mgmt_user_data_payload" {
  template = "${file("${path.module}/user_data.ps1.template")}"  

  vars = {
    conn_url = "${var.conn_url}"
    reg_user = "${var.reg_user}"
    reg_pass = "${var.reg_pass}"
    reg_url = "${var.reg_url}"
    admin_pass = "${random_string.password_gen.result}"
  }
}

// Should actually do a local-exec and get this + machine into vault ....
output "machine_admin_pass" {
    value = "${random_string.password_gen.result}"
}