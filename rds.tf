resource "aws_db_subnet_group" "db-subnet-group" {
  name        = "db_subnet_group"
  description = "DB group of subnets"
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
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
  engine               = "mysql"
  identifier           = "myrdsinstance"
  allocated_storage    =  20
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "password123"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  #skip_final_snapshot  = true
  #publicly_accessible =  true
}


#create a security group for RDS Database Instance
resource "aws_security_group" "db-sg" {
  name = "db-gs"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#output
output "security_group_id" {
  value       = aws_security_group.db-sg.id
}
output "db_instance_endpoint" {
  value       = aws_db_instance.wp-db.endpoint
}