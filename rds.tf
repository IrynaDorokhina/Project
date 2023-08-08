resource "aws_db_subnet_group" "db-subnet-group" {
    name = "db_subnet_group"
    description = "DB group of subnets"
    subnet_ids  = [ aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]
}

#create a RDS Database Instance
#db engine - mysql 5.7                          +
#Instance Type : t2.micro (Burstable classes)   +
#Storage (default)                              +
#Credentials (admin/<password>)                 +
#Enhanced Monitoring- disabled
#Auto minor upgrade- Enabled
#Backup & Retention (disabled)
#Password authentication
#Multi-AZ not required

resource "aws_db_instance" "wp-db" {
    engine = "mysql"
    identifier = "wp-db"
    allocated_storage = 20
    engine_version = "5.7"
    instance_class = "db.t2.micro"
    username = "admin"
    password = "password123"
    parameter_group_name = "default.mysql5.7"
    vpc_security_group_ids = [ aws_security_group.db-sg.id ]
    db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
    skip_final_snapshot = true
    #publicly_accessible = true
    #provisioner "local-exec"{
    #  command = "chmod 777 migrate.sh; ./migrate.sh"
    #}
    provisioner "local-exec" {
        command = "echo rds endpoint = ${self.endpoint}, rds address = ${self.address} >> metadatafile.txt"
    }
}

resource "aws_security_group" "db-sg" {
    vpc_id = aws_vpc.wp-vpc.id
    name = "db-sg"
    tags = {
        Name = "db-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "db-ingress" {
    from_port = 3306
    ip_protocol = "tcp"
    security_group_id = aws_security_group.db-sg.id
    to_port = 3306
    referenced_security_group_id= aws_security_group.autoscaling-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "db-ec2-ingress" {
    from_port = 3306
    ip_protocol = "tcp"
    security_group_id = aws_security_group.db-sg.id
    to_port = 3306
    referenced_security_group_id = aws_security_group.wordpress-sg.id
}

resource "aws_vpc_security_group_egress_rule" "db-egress" {
    from_port = 3306
    ip_protocol = "tcp"
    security_group_id = aws_security_group.db-sg.id
    to_port = 3306
    referenced_security_group_id = aws_security_group.autoscaling-sg.id
}

resource "aws_vpc_security_group_egress_rule" "db-ec2-egress" {
    from_port = 3306
    ip_protocol = "tcp"
    security_group_id = aws_security_group.db-sg.id
    to_port = 3306
    referenced_security_group_id = aws_security_group.wordpress-sg.id
}   

#output
output "security_group_id" {
    value = aws_security_group.db-sg.id
}
output "db_instance_endpoint" {
    value = aws_db_instance.wp-db.endpoint
}