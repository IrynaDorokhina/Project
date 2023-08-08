
#Select latest AMI-id amazon linux
data "aws_ami" "latest_amazon_linux" {
    most_recent = true
    filter {
        name = "name"
        values = [ "amzn2-ami-hvm-*-x86_64-gp2" ]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["amazon"]
}

resource "aws_instance" "wordpress" {
    ami = data.aws_ami.latest_amazon_linux.id
    instance_type = "t2.micro"
    key_name = "vockey"
    vpc_security_group_ids = [ aws_security_group.wordpress-sg.id ]
    subnet_id = aws_subnet.public_subnet_1.id
    user_data = file("userdata.sh")
    tags = {
        Name = "wordpress"
    }
    depends_on = [ aws_db_instance.wp-db ]
    provisioner "local-exec" {
        command = "echo Instance Type=${self.instance_type},Instance ID=${self.id},Public DNS=${self.public_dns},AMI ID=${self.ami} >> ec2-details"
    }
} 

resource "aws_security_group" "wordpress-sg" {
    vpc_id = aws_vpc.wp-vpc.id
    name = "allow_ss_http"
    tags = {
        Name = "wordpress-sg"
    }
    provisioner "local-exec" {
        command = "echo ec2_sg id = ${self.id} >> metadatafile.txt"
    }
}

resource "aws_security_group_rule" "wordpress-sg-ssh-ingress" {
    from_port = 22
    protocol = "tcp"
    security_group_id = aws_security_group.wordpress-sg.id
    to_port = 22
    type = "ingress"
    cidr_blocks = [var.cidr_blocks]
}

resource "aws_security_group_rule" "wordpress-sg-http-ingress" {
    from_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.wordpress-sg.id
    to_port = 80
    type = "ingress"
    cidr_blocks = [var.cidr_blocks]
}

resource "aws_security_group_rule" "wordpress-sg-egress" {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.cidr_blocks]
    security_group_id = aws_security_group.wordpress-sg.id
    type = "egress"
}