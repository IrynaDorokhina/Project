resource "aws_ami_from_instance" "wordpress" {
  name               = "ami_wordpress"
  source_instance_id = aws_instance.wordpress.id
}

resource "aws_lb_target_group" "front" {
    name = "application-front"
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

resource "aws_lb_target_group_attachment" "attach-app1" {
    target_group_arn = aws_lb_target_group.front.arn
    target_id = aws_instance.wordpress.id
    port = 80
}

resource "aws_lb" "front" {
    name = "front"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.devVPC_sg_allow_ssh_http.id]
    subnets= [aws_subnet.devVPC_public_subnet_1.id, aws_subnet.devVPC_public_subnet_2.id] #FIX
    enable_deletion_protection = true
    tags = {
    Environment = "front"
    }
}

resource "aws_lb_listener" "front_end" {
    load_balancer_arn = aws_lb.front.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.front.arn
    }
}

