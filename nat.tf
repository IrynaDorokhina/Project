/*
#NATgateway
#Create Elastic IP. The advantage of associating the Elastic IP address with the network interface instead of directly with the instance is that you can move all the attributes of the network interface from one instance to another in a single step.
resource "aws_eip" "eip" {
    vpc = true
    tags = {
        Name = "elastic_ip"
    }
}

#NAT Gateway in public subnet and assigned the above created Elastic IP to it 
resource "aws_nat_gateway" "nat-gateway" {
    allocation_id = "${aws_eip.eip.id}"
    subnet_id = "${aws_subnet.public_subnet_1.id}"
    tags = {
        Name = "nat-gateway"
    }
}

#Create a Route Table in order to connect our private subnet to the NAT Gateway
resource "aws_route_table" "privateroutetable" {
    vpc_id = "${aws_vpc.wp_vpc.id}"
    route {
        cidr_block = var.cidr_blocks
        gateway_id = "${aws_nat_gateway.nat-gateway.id}"
    }
    tags = {
    Name = "privateroutetable"
    }
}

#Associate this route table to private subnet 
resource "aws_route_table_association" "private_association" {
    route_table_id = aws_route_table.privateroutetable.id
    subnet_id = aws_subnet.private_subnet_1.id
}
*/