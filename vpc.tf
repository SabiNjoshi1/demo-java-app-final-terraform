resource "aws_vpc" "java_app_vpc" {
  cidr_block = "10.0.0.0/28"
  tags = {
    Name = "java-app-vpc"
  }
}

resource "aws_subnet" "java_app_subnet" {
  vpc_id                  = aws_vpc.java_app_vpc.id
  cidr_block              = "10.0.0.0/28"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "java-app-subnet"
  }
}
resource "aws_internet_gateway" "java_app_ig" {
  vpc_id = aws_vpc.java_app_vpc.id


  tags = {
    Name = "java-app-ig"
  }
}

resource "aws_route_table" "java_app_route_table" {
  vpc_id = aws_vpc.java_app_vpc.id

  tags = {
    Name = "java-app-route-table"
  }
}

resource "aws_route_table_association" "java_app_subnet_vpc_route_table_association" {
  subnet_id      = aws_subnet.java_app_subnet.id
  route_table_id = aws_route_table.java_app_route_table.id

}

resource "aws_route" "java_app_route" {
  route_table_id         = aws_route_table.java_app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.java_app_ig.id
}