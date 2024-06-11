# resource "aws_db_subnet_group" "db_subnet_group" {
#   name       = "db-subnet-group"
#   description = "My database subnet group"
#   subnet_ids = [
#     aws_subnet.db_AZ-1_subnet.id,
#     aws_subnet.db_AZ-2_subnet.id
#   ]

#   tags = {
#     Name = "db-subnet-group"
#   }
# }

# resource "aws_rds_cluster" "aurora_cluster" {
#   cluster_identifier      = "aurora-cluster"
#   engine                  = "aurora-mysql"
#   engine_version          = "5.7.mysql_aurora.2.11.2"
#   database_name           = "mydatabase"
#   master_username         = "admin"
#   master_password         = "password123"
#   db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
#   vpc_security_group_ids  = [aws_security_group.db_sg.id]
#   skip_final_snapshot     = true
#   storage_encrypted       = true

#   tags = {
#     Name = "aurora-cluster"
#   }
# }

# resource "aws_rds_cluster_instance" "aurora_writer" {
#   identifier              = "aurora-writer"
#   cluster_identifier      = aws_rds_cluster.aurora_cluster.id
#   instance_class          = "db.r5.large"
#   engine                  = aws_rds_cluster.aurora_cluster.engine
#   engine_version          = aws_rds_cluster.aurora_cluster.engine_version
#   publicly_accessible     = false
#   availability_zone       = var.az_1

#   tags = {
#     Name = "aurora-writer"
#   }
# }

# resource "aws_rds_cluster_instance" "aurora_reader" {
#   identifier              = "aurora-reader"
#   cluster_identifier      = aws_rds_cluster.aurora_cluster.id
#   instance_class          = "db.r5.large"
#   engine                  = aws_rds_cluster.aurora_cluster.engine
#   engine_version          = aws_rds_cluster.aurora_cluster.engine_version
#   publicly_accessible     = false
#   availability_zone       = var.az_2  # Specify a different AZ for the reader

#   tags = {
#     Name = "aurora-reader"
#   }
# }