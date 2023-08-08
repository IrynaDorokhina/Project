
resource "aws_lb" "load-balancer" {
    name = "load-balancer"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.elb-sg.id ]
    subnets = [ aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]
    enable_deletion_protection = false
        tags = {
            Environment = "production"
    }
    provisioner "local-exec" {
        command = "echo elb dns name = ${self.dns_name} >> metadatafile.txt"
    }
}

resource "aws_lb_target_group" "target-group" {
    name = "elb-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.wp-vpc.id
}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = aws_lb.load-balancer.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target-group.arn
    }
}

resource "aws_security_group" "elb-sg" {
    vpc_id = aws_vpc.wp-vpc.id
    name = "elb-sg"
        tags = {
            Name = "elb-sg"
        }
}

resource "aws_vpc_security_group_ingress_rule" "elb-http-ingress" {
    from_port = 80
    ip_protocol = "tcp"
    security_group_id = aws_security_group.elb-sg.id
    to_port = 80
    cidr_ipv4 = var.cidr_blocks
}

resource "aws_vpc_security_group_ingress_rule" "elb-https-ingress" {
    from_port = 443
    ip_protocol = "tcp"
    security_group_id = aws_security_group.elb-sg.id
    to_port = 443
    cidr_ipv4 = var.cidr_blocks
}

resource "aws_vpc_security_group_egress_rule" "elb-http-egress" {
    from_port = 80
    ip_protocol  = "tcp"
    security_group_id = aws_security_group.elb-sg.id
    to_port = 80
    referenced_security_group_id = aws_security_group.autoscaling-sg.id
}


#resource "aws_ami_from_instance" "ami_wordpress" {
#    name               = "ami_wordpress"
#    source_instance_id = aws_instance.wordpress.id
#}

/*resource "aws_lb_target_group" "target_group" {
    name = "target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.devVPC.id
    health_check {
        enabled = true
        healthy_threshold = 3
        interval = 10
        matcher = 200
        path = "/"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 3
        unhealthy_threshold = 2
        }
}

resource "aws_lb_target_group_attachment" "attach-myelb" {
    target_group_arn = aws_lb_target_group.target_group.arn
    target_id = aws_instance.wordpress.id
    port = 80
}

resource "aws_lb" "myelb" {
    name = "myelb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.devVPC_sg_allow_ssh_http.id]
    subnets= [aws_subnet.devVPC_public_subnet_1.id, aws_subnet.devVPC_public_subnet_2.id] #FIX
    #enable_deletion_protection = true
    tags = {
    Environment = "myelb"
    }
}

resource "aws_lb_listener" "myelb_end" {
    load_balancer_arn = aws_lb.myelb.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_group.arn
    }
}

resource "aws_launch_template" "my_launch_template" {
    name = "my-launch-template"
    description = "My Launch Template"
    image_id = aws_ami_from_instance.ami_wordpress.id
    instance_type = "t3.micro"
}

resource "aws_autoscaling_group" "myasg" {
    name_prefix = "myasg-"
    desired_capacity   = 2
    max_size           = 4
    min_size           = 2
    vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    target_group_arns = [aws_lb_target_group.target_group.arn]
    health_check_type = "EC2"
    #health_check_grace_period = 300 # default is 300 seconds  
    # Launch Template
    launch_template {
        id      = aws_launch_template.my_launch_template.id
        version = aws_launch_template.my_launch_template.latest_version
    }
    # Instance Refresh
    instance_refresh {
        strategy = "Rolling"
    preferences {
      #instance_warmup = 300 # Default behavior is to use the Auto Scaling Group's health check grace period.
        min_healthy_percentage = 50
    }
        triggers = [ "launch.tf", "desired_capacity" ] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger
    }  
    tag {
        key                 = "Name"
        value               = "WpApp"
        propagate_at_launch = true
    }      
}
*/