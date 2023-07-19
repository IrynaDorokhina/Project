output "vpc_id"{
    value = aws_vpc.devVPC.id    
}
output "aws_internet_gateway"{
    value = aws_internet_gateway.devVPC_IGW.id  
}
output "public_subnet_1"{
    value = aws_subnet.devVPC_public_subnet_1.id 
} 

output "public_subnet_2"{
    value = aws_subnet.devVPC_public_subnet_2.id 

}
output "security_group"{
    value = aws_security_group.devVPC_sg_allow_ssh_http.id
}

/*output "packer_ami"{
    value= data.aws_ami.packeramisjenkins.id
}
output "aws_instance"{
    value=aws_instance.jenkins-instance.id
}
# For more attributes https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#attributes-reference
output "public_ip"{
    value = aws_instance.jenkins-instance.public_ip
}
output "public_dns"{
    value = aws_instance.jenkins-instance.public_dns
}*/