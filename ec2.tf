#Select latest AMI-id amazon linux
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "wordpress"{
    ami = data.aws_ami.latest_amazon_linux.id
    instance_type = "t2.micro"
    key_name = "vockey"
    vpc_security_group_ids = [aws_security_group.VPC_sg_allow_ssh_http.id]
    subnet_id = aws_subnet.public_subnet_1.id
    user_data = file("userdata.sh")
    tags = {
        Name = "wordpress"
    }

    provisioner "local-exec"{
        command = "echo Instance Type=${self.instance_type},Instance ID=${self.id},Public DNS=${self.public_dns},AMI ID=${self.ami} >> allinstancedetails"
    }


}

