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

