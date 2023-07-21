resource "aws_ami_from_instance" "ami_wordpress" {
    name               = "ami_wordpress"
    source_instance_id = aws_instance.wordpress.id
}

resource "aws_lb_target_group" "target_group" {
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
    #instance_type = var.instance_type
}

resource "aws_autoscaling_group" "my_asg" {
    name_prefix = "myasg-"
    desired_capacity   = 2
    max_size           = 4
    min_size           = 2
    vpc_zone_identifier  = [data.aws_availability_zones.devVPC_available.names[1], data.aws_availability_zones.devVPC_available.names[2]]
    target_group_arns = [aws_lb_target_group.devVPC_target_group.arn]
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
        triggers = [ "launch_template", "desired_capacity" ] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger
    }  
    tag {
        key                 = "Name"
        value               = "WpApp"
        propagate_at_launch = true
    }      
}
