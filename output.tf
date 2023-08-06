output "vpc_id" {
    value = aws_vpc.wp-vpc.id    
}

output "aws_internet_gateway" {
    value = aws_internet_gateway.VPC_IGW.id  
}

output "public_subnet_1" {
    value = aws_subnet.public_subnet_1.id 
} 

output "public_subnet_2" {
    value = aws_subnet.public_subnet_2.id 

}
output "security_group" {
    value = aws_security_group.wordpress-sg.id
}

output "name" {
    value = aws_lb.load-balancer.dns_name
}

# Launch Template Outputs
output "launch_template_id" {
    description = "Launch Template ID"
    value = aws_launch_template.launch-template.id
}

output "launch_template_latest_version" {
    description = "Launch Template Latest Version"
    value = aws_launch_template.launch-template.latest_version
}

# Autoscaling Outputs
output "autoscaling_group_id" {
    description = "Autoscaling Group ID"
    value = aws_autoscaling_group.autoscaling-group.id 
}

output "autoscaling_group_name" {
    description = "Autoscaling Group Name"
    value = aws_autoscaling_group.autoscaling-group.name 
}

output "autoscaling_group_arn" {
    description = "Autoscaling Group ARN"
    value = aws_autoscaling_group.autoscaling-group.arn 
}