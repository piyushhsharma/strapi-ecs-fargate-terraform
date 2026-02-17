resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = local.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-db"
  engine                 = "postgres"
  engine_version         = "14.10"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  username               = var.db_username
  password               = var.db_password
  db_name                = "strapi"
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  tags = {
    Name = "${var.project_name}-db"
  }
}
