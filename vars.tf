variable "AWS_REGION" {
    default = "us-west-2"
    description = "AWS Region"
}

variable "cidr_blocks" {
    default = "0.0.0.0/0"
}

/*variable "public_cidr"{
    default = "10.0.2.0/24"
}

variable "private_cidr"{
    default = "10.0.4.16/24"
}*/

variable "endpoint" {
    default = "aws_db_instance.wp-db.endpoint"
}

variable "usernamerds" {
    default = "admin"
}

variable "passwordrds" {
    default = "password123"
}