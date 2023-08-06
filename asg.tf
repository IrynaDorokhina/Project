
resource "aws_launch_template" "launch-template" {
    name = "launch-template"
    image_id = data.aws_ami.latest_amazon_linux.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.autoscaling-sg.id ]
    user_data = base64encode(templatefile("userdatatemplate.sh", {
        DB = "wordpress"
        User = "wpuser"
        PW = "wppassword"
        host = "aws_db_instance.wp-db.address"     #how to store variables
    }
    ))
    depends_on = [ aws_db_instance.wp-db ]
    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "wp-server"
        }
    }
}
resource "aws_autoscaling_group" "autoscaling-group" {
    name = "autoscaling-group"
    max_size = 4
    min_size = 2
    desired_capacity = 2
    vpc_zone_identifier = [ aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id ]
    target_group_arns = [ aws_lb_target_group.target-group.arn ]
    health_check_type = "ELB"
    health_check_grace_period = 300
    launch_template {
        id = aws_launch_template.launch-template.id
        version = "$Latest"
    }
}

resource "aws_autoscaling_policy" "policy" {
    name = "CPUpolicy"
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 70.0
    }
    autoscaling_group_name = aws_autoscaling_group.autoscaling-group.name
}

resource "aws_security_group" "autoscaling-sg" {
    vpc_id = aws_vpc.wp-vpc.id
    name = "autoscaling-sg"
    tags = {
        Name = "autoscaling-sg"
    }
}
resource "aws_vpc_security_group_ingress_rule" "autoscaling-ingress-http" {
    from_port = 80
    ip_protocol = "tcp"
    security_group_id = aws_security_group.autoscaling-sg.id
    to_port = 80
    cidr_ipv4 = var.cidr_blocks
}

resource "aws_vpc_security_group_ingress_rule" "autoscaling-ingress-ssh" {
    from_port = 22
    ip_protocol = "tcp"
    security_group_id = aws_security_group.autoscaling-sg.id
    to_port = 22
    referenced_security_group_id= aws_security_group.wordpress-sg.id      # referenced sg
}

resource "aws_vpc_security_group_ingress_rule" "autoscaling-ingress-db" {
    from_port = 3306
    ip_protocol = "tcp"
    security_group_id = aws_security_group.autoscaling-sg.id
    to_port = 3306
    referenced_security_group_id= aws_security_group.db-sg.id
}

resource "aws_vpc_security_group_egress_rule" "autoscaling-http-egress" {
    from_port = 0
    ip_protocol = "tcp"
    security_group_id = aws_security_group.autoscaling-sg.id
    to_port = 65535
    cidr_ipv4 = var.cidr_blocks
}

resource "aws_vpc_security_group_egress_rule" "autoscaling-db-egress" {
    from_port = 3306
    ip_protocol = "tcp"
    security_group_id = aws_security_group.autoscaling-sg.id
    to_port = 3306
    referenced_security_group_id = aws_security_group.db-sg.id
}

resource "aws_vpc_security_group_egress_rule" "autoscaling-https-egress" {
    from_port = 443
    ip_protocol = "tcp"
    security_group_id = aws_security_group.autoscaling-sg.id
    to_port = 443
    cidr_ipv4 = var.cidr_blocks
}

resource "aws_security_group_rule" "autoscaling-sg-egress" {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.cidr_blocks]
    security_group_id = aws_security_group.autoscaling-sg.id
    type = "egress"
}