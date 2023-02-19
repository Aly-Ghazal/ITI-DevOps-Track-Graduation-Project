resource "aws_vpc" "custom-vpc" {
  cidr_block = var.VPC-cidr
  tags = {
    Name = var.VPC-name
  }
}
resource "aws_subnet" "publicSubnets" {
  count             = length(var.publicSubnets-cidr)
  cidr_block        = var.publicSubnets-cidr[count.index]
  vpc_id            = aws_vpc.custom-vpc.id
  availability_zone = var.Subnet-Availability-zones[count.index]
  tags = {
    Name = var.publicSubnets-tag-names[count.index]
  }
  
}


resource "aws_subnet" "privateSubnets" {
  count             = length(var.privateSubnets-cidr)
  cidr_block        = var.privateSubnets-cidr[count.index]
  vpc_id            = aws_vpc.custom-vpc.id
  availability_zone = var.Subnet-Availability-zones[count.index]
  tags = {
    Name = var.privateSubnets-tag-names[count.index]
  }
}


resource "aws_route_table" "publicRoutes" {
  vpc_id = aws_vpc.custom-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "publicRoutes"
  }
}

resource "aws_route_table_association" "publicRouteAssociate" {
  count          = length(var.publicSubnets-cidr)
  subnet_id      = aws_subnet.publicSubnets[count.index].id
  route_table_id = aws_route_table.publicRoutes.id
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.custom-vpc.id
  tags = {
    Name = "gw"
  }
}

resource "aws_route_table" "privateRoutes" {
  vpc_id = aws_vpc.custom-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw-NAT.id
  }

  tags = {
    Name = "privateRoute"
  }
}

resource "aws_route_table_association" "privateRouteAssociate" {
  count          = length(var.privateSubnets-cidr)
  subnet_id      = aws_subnet.privateSubnets[count.index].id
  route_table_id = aws_route_table.privateRoutes.id
}

# create an Elastic IP
resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "gw-NAT" {
  subnet_id     = aws_subnet.publicSubnets[0].id
  allocation_id = aws_eip.nat_gateway.id
  tags = {
    Name = "gw NAT"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}