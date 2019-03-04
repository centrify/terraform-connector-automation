// Intranet security group - all from the VPC, and all outbound to internet
resource "aws_security_group" "cfy_intranet_sg" {
  name = "cfy_intranet_sg-${random_id.instance.hex}"
  vpc_id = "${aws_vpc.cfy_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"    
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  } 
  
  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }    

  tags {
    Name = "cfy_intranet_sg-${random_id.instance.hex}"
  }
}