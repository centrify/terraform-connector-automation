// A keypair for access to any machines we create (also necessary to get windows password)
resource "tls_private_key" "cfy_machine_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cfy_machine_key" {
  key_name   = "cfy_machine_key-${random_id.instance.hex}"
  public_key = tls_private_key.cfy_machine_key_pair.public_key_openssh
}

resource "local_file" "cfy_machine_priv_key_file" {
  content  = tls_private_key.cfy_machine_key_pair.private_key_pem
  filename = "${path.module}/../output/cfy_machine_key.priv"
}

