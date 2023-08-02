# Query all available Availability Zone; we will use specific availability zone using index - The Availability Zones data source
# provides access to the list of AWS availabililty zones which can be accessed by an AWS account specific to region configured in the provider.
data "aws_availability_zones" "VPC_available"{}

resource "aws_vpc" "wp-vpc"{
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames=true
    enable_dns_support = true
    tags = {
        Name = "wp-vpc"
    }
     provisioner "local-exec"{
        command = "echo vpc id =${self.id} >> metadatafile.txt"
    }
}
# Public subnet public CIDR block available in vars.tf and provisionersVPC
resource "aws_subnet" "public_subnet_1"{
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.wp-vpc.id
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.VPC_available.names[1]
    tags = {
        Name = "vpc_public_subnet_1"
    }
}
resource "aws_subnet" "private_subnet_1"{
    cidr_block = "10.0.2.0/24"
    vpc_id = aws_vpc.wp-vpc.id
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.VPC_available.names[1]
    tags = {
        Name = "vpc_private_subnet_1"
    }
}

# Public subnet public CIDR block available in vars.tf and provisionersVPC
resource "aws_subnet" "public_subnet_2"{
    cidr_block = "10.0.3.0/24"
    vpc_id = aws_vpc.wp-vpc.id
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.VPC_available.names[2]
    tags = {
        Name = "vpc_public_subnet_2"
    }
}
resource "aws_subnet" "private_subnet_2"{
    cidr_block = "10.0.4.0/24"
    vpc_id = aws_vpc.wp-vpc.id
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.VPC_available.names[2]
    tags = {
        Name = "vpc_private_subnet_2"
    }
}
# To access EC2 instance inside a Virtual Private Cloud (VPC) we need an Internet Gateway
# and a routing table Connecting the subnet to the Internet Gateway
# Creating Internet Gateway
# Provides a resource to create a VPC Internet Gateway
resource "aws_internet_gateway" "VPC_IGW"{
    vpc_id = aws_vpc.wp-vpc.id
    tags = {
        Name = "vpc_igw"
    }
}
# Provides a resource to create a VPC routing table
resource "aws_route_table" "public_route_1"{
    vpc_id = aws_vpc.wp-vpc.id
    route{
        cidr_block = var.cidr_blocks
        gateway_id = aws_internet_gateway.VPC_IGW.id
    }
    tags = {
        Name = "vpc_public_route_1"
    }
}

# Provides a resource to create an association between a Public Route Table and a Public Subnet
resource "aws_route_table_association" "public_subnet_association_1" {
    route_table_id = aws_route_table.public_route_1.id
    subnet_id = aws_subnet.public_subnet_1.id
    depends_on = [aws_route_table.public_route_1, aws_subnet.public_subnet_1]
}

# Provides a resource to create a VPC routing table
resource "aws_route_table" "public_route_2"{
    vpc_id = aws_vpc.wp-vpc.id
    route{
        cidr_block = var.cidr_blocks
        gateway_id = aws_internet_gateway.VPC_IGW.id
    }
    tags = {
        Name = "public_route_2"
    }
}
# Provides a resource to create an association between a Public Route Table and a Public Subnet
resource "aws_route_table_association" "public_subnet_association_2" {
    route_table_id = aws_route_table.public_route_2.id
    subnet_id = aws_subnet.public_subnet_2.id
    depends_on = [aws_route_table.public_route_2, aws_subnet.public_subnet_2]
}

resource "aws_security_group" "VPC_sg_allow_ssh_http"{
    vpc_id = aws_vpc.wp-vpc.id
    name = "vpc_allow_http"
    tags = {
        Name = "sg_allow_http"
    }
}

# Ingress Security Port 22 (Inbound) - Provides a security group rule resource (https://registry.terraform.io.providers/hashicorp/aws/latest/docs/resources/security_group_rule)
resource "aws_security_group_rule" "VPC_ssh_ingress_access"{
    from_port             = 22
    protocol              = "tcp"
    security_group_id     = aws_security_group.VPC_sg_allow_ssh_http.id
    to_port               = 22
    type                  = "ingress"
    cidr_blocks           = [var.cidr_blocks]
}

# Ingress Security Port 80 (Inbound)
resource "aws_security_group_rule" "VPC_http_ingress_access"{
    from_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.VPC_sg_allow_ssh_http.id
    to_port= 80
    type = "ingress"
    cidr_blocks = [var.cidr_blocks]
}
/*# Ingress Security Port 8080 (Inbound)
resource "aws_security_group_rule" "VPC_http8080_ingress_access"{
    from_port = 8080
    protocol = "tcp"
    security_group_id = aws_security_group.VPC_sg_allow_ssh_http.id
    to_port= 8080
    type = "ingress"
    cidr_blocks = [var.cidr_blocks]
}*/

# Egress Security (Outbound) - Allow all outbound traffic
resource "aws_security_group_rule" "VPC_egress_access" {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks]
    security_group_id = aws_security_group.VPC_sg_allow_ssh_http.id
    type = "egress"
}

/*#Create pulic access bucket
resource "aws_s3_bucket" "projectbucket022" {
  bucket = "projectbucket022"
}

resource "aws_s3_bucket_public_access_block" "projectbucket022" {
  bucket = aws_s3_bucket.projectbucket022.id
  block_public_acls   = false
  block_public_policy = false
}*/

/*#Create private bucket
resource "aws_s3_bucket" "projectbucket025" {
bucket = "projectbucket025"
    tags = {
        Name = "projectbucket025"
    }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.projectbucket025.id
  acl    = "private"
  depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership ]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.projectbucket025.id
  rule {
    object_ownership = "ObjectWriter"  //BucketOwnerPreferred
  }
}*/