resource "aws_instance" "wordpress"{
    ami = "ami-0ae49954dfb447966"
    instance_type = "t3.micro"
    key_name = "vockey"
    vpc_security_group_ids = [aws_security_group.devVPC_sg_allow_http.id]
    subnet_id = aws_subnet.devVPC_public_subnet_1.id
    user_data = "${file("template.tpl")}"
    tags = {
        Name = "wordpress"
    }

    #data "template_file" "init" {
    #git template = "${file("${path.module}/template.tpl")}"
    #vars =  {
    #    consul_address = "${aws_instance.consul.private.ip}"
    #    }
    #}

     provisioner "remote-exec"{
        inline = [
            "./template.tpl"
        ]
        on_failure = continue
    }

    provisioner "local-exec"{
        command = "echo Instance Type=${self.instance_type},Instance ID=${self.id},Public DNS=${self.public_dns},AMI ID=${self.ami} >> allinstancedetails"
    }


}

