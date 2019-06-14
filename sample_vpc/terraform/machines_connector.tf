resource "aws_instance" "cfy_connector_instance" {
  depends_on                  = [aws_nat_gateway.nat_gw_private]
  ami                         = data.aws_ami.windows_ami.id
  instance_type               = var.connector_instance_type
  vpc_security_group_ids      = [aws_security_group.cfy_intranet_sg.id]
  key_name                    = aws_key_pair.cfy_machine_key.key_name
  subnet_id                   = element(local.private_subnets, count.index % 2)
  user_data                   = data.template_file.connector_user_data_payload.rendered
  iam_instance_profile        = aws_iam_instance_profile.cfy_machine_iam_instance_profile.name
  availability_zone           = element(data.aws_availability_zones.available.names, count.index % 2)
  get_password_data           = true
  associate_public_ip_address = false
  source_dest_check           = false

  count = 2

  root_block_device {
    volume_size           = var.connector_disk_size
    delete_on_termination = true
  }

  tags = {
    Name = "cfy_connector_instance-${count.index}-${random_id.instance.hex}"
  }
}

resource "random_string" "conn_password_gen" {
  length           = 16
  upper            = true
  min_upper        = 4
  lower            = true
  min_lower        = 4
  number           = true
  min_numeric      = 4
  special          = true
  min_special      = 4
  override_special = "!@#%&*()-_=+[]{}<>:?"
}

data "template_file" "connector_user_data_payload" {
  template = file(
    "${path.module}/../data/cfy_machine_connector_user_data.ps1.template",
  )

  vars = {
    conn_url   = var.conn_url
    reg_user   = var.reg_user
    reg_pass   = var.reg_pass
    reg_url    = var.reg_url
    admin_pass = random_string.conn_password_gen.result
  }
}

