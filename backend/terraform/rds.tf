resource "aws_db_subnet_group" "this" {
  name       = "strapi-db-subnet"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier             = "strapi-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}
