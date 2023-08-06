# Query all available Availability Zones
data "aws_availability_zones" "VPC_available" {}

resource "aws_vpc" "wp-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "wp-vpc"
    }
    provisioner "local-exec" {
        command = "echo vpc id = ${self.id} >> metadatafile.txt"
    }
}

resource "aws_subnet" "public_subnet_1" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.wp-vpc.id
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.VPC_available.names[1]
    tags = {
        Name = "public_subnet_1"
    }
    provisioner "local-exec" {
        command = "echo public_subnet_1 id = ${self.id} >> metadatafile.txt"
    }
}
resource "aws_subnet" "private_subnet_1" {
    cidr_block = "10.0.2.0/24"
    vpc_id = aws_vpc.wp-vpc.id
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.VPC_available.names[1]
    tags = {
        Name = "private_subnet_1"
    }
    provisioner "local-exec"{
        command = "echo private_subnet_1 id = ${self.id} >> metadatafile.txt"
    }
}

resource "aws_subnet" "public_subnet_2" {
    cidr_block = "10.0.3.0/24"
    vpc_id = aws_vpc.wp-vpc.id
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.VPC_available.names[2]
    tags = {
        Name = "public_subnet_2"
    }
    provisioner "local-exec"{
        command = "echo public_subnet_2 id = ${self.id} >> metadatafile.txt"
    }
}
resource "aws_subnet" "private_subnet_2" {
    cidr_block = "10.0.4.0/24"
    vpc_id = aws_vpc.wp-vpc.id
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.VPC_available.names[2]
    tags = {
        Name = "private_subnet_2"
    }
    provisioner "local-exec"{
        command = "echo private_subnet_2 id = ${self.id} >> metadatafile.txt"
    }
}

resource "aws_internet_gateway" "VPC_IGW" {
    vpc_id = aws_vpc.wp-vpc.id
    tags = {
        Name = "vpc_igw"
    }
    provisioner "local-exec"{
        command = "echo VPC_IGW id = ${self.id} >> metadatafile.txt"
    }
}

resource "aws_route_table" "public_route_1" {
    vpc_id = aws_vpc.wp-vpc.id
    route {
        cidr_block = var.cidr_blocks
        gateway_id = aws_internet_gateway.VPC_IGW.id
    }
    tags = {
        Name = "public_route_1"
    }
}

resource "aws_route_table_association" "public_subnet_association_1" {
    route_table_id = aws_route_table.public_route_1.id
    subnet_id = aws_subnet.public_subnet_1.id
    depends_on = [ aws_route_table.public_route_1, aws_subnet.public_subnet_1 ]
}

resource "aws_route_table" "public_route_2" {
    vpc_id = aws_vpc.wp-vpc.id
    route {
        cidr_block = var.cidr_blocks
        gateway_id = aws_internet_gateway.VPC_IGW.id
    }
    tags = {
        Name = "public_route_2"
    }
}

resource "aws_route_table_association" "public_subnet_association_2" {
    route_table_id = aws_route_table.public_route_2.id
    subnet_id = aws_subnet.public_subnet_2.id
    depends_on = [ aws_route_table.public_route_2, aws_subnet.public_subnet_2 ]
}