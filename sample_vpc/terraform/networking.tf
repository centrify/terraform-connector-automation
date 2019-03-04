// Main VPC
resource "aws_vpc" "cfy_vpc" {
    cidr_block = "${var.vpc_cidr_block}"    
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
      Name = "cfy_vpc-${random_id.instance.hex}"
    }
}

// Public subnets
resource "aws_subnet" "cfy_public_subnets" {
    count = "${length(var.vpc_public_subnet_cidrs)}"
    vpc_id = "${aws_vpc.cfy_vpc.id}"
    cidr_block = "${element(var.vpc_public_subnet_cidrs, count.index)}"
    availability_zone = "${element(data.aws_availability_zones.available.names, count.index % 2)}"
    
    tags {
        Name = "cfy_public_subnet-${count.index}-${random_id.instance.hex}"
    }
}

// Private subnets
resource "aws_subnet" "cfy_private_subnets" {
    count = "${length(var.vpc_private_subnet_cidrs)}"
    vpc_id = "${aws_vpc.cfy_vpc.id}"
    cidr_block = "${element(var.vpc_private_subnet_cidrs, count.index)}"
    availability_zone = "${element(data.aws_availability_zones.available.names, count.index % 2)}"
    
    tags {
        Name = "cfy_private_subnet-${count.index}-${random_id.instance.hex}"
    }
}

// Internet gateway so VPC<->internet can work
resource "aws_internet_gateway" "cfy_igw" {
  vpc_id = "${aws_vpc.cfy_vpc.id}"  

  tags {
    Name = "cfy_igw-${random_id.instance.hex}"
  }
}

// EIP for each NAT'd subnet
resource "aws_eip" "nat_private_ips" {
  count             = "${length(var.vpc_private_subnet_cidrs)}"
  vpc = true
}

// NAT gateway's
resource "aws_nat_gateway" "nat_gw_private" {
  depends_on = ["aws_internet_gateway.cfy_igw"]
  count         = "${length(var.vpc_private_subnet_cidrs)}"

  allocation_id = "${element(aws_eip.nat_private_ips.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.cfy_public_subnets.*.id, count.index)}"
}

// And finally routes 
resource "aws_route_table" "igw_route_public" {
  count         = "${length(var.vpc_public_subnet_cidrs)}"

  vpc_id        = "${aws_vpc.cfy_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = "${aws_internet_gateway.cfy_igw.id}"
  }

  tags {
    Name        = "cfy-igw-route-public-${count.index}-${random_id.instance.hex}"
  }
}

resource "aws_route_table" "nat_route_private" {
  count         = "${length(var.vpc_private_subnet_cidrs)}"

  vpc_id        = "${aws_vpc.cfy_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat_gw_private.*.id, count.index)}"
  }

  tags {
    Name        = "cfy-nat-route-private-${count.index}-${random_id.instance.hex}"
  }
}

resource "aws_route_table_association" "cfy_public_routes" {
    count          = "${length(var.vpc_public_subnet_cidrs)}"
    subnet_id      = "${element(aws_subnet.cfy_public_subnets.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.igw_route_public.*.id, count.index)}"    
}

resource "aws_route_table_association" "cfy_private_routes" {
    count          = "${length(var.vpc_private_subnet_cidrs)}"
    subnet_id      = "${element(aws_subnet.cfy_private_subnets.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.nat_route_private.*.id, count.index)}"    
}