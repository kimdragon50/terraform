resource "aws_security_group" "bastion-sg" {
  name        = "KYM-NDP-BASTION-SG"
  description = "KYM-NDP-BASTION-SG"
  
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "KYM-NDP-BASTION-SG"
  }
}

resource "aws_security_group" "rds-mysql-sg" {
  name        = "KYM-NDP-RDS-MYSQL-SG"
  description = "KYM-NDP-RDS-MYSQL-SG"
  
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "KYM-NDP-BASTION-SG"
  }
}

