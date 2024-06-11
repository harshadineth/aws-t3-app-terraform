resource "aws_security_group" "external_lb_sg" {
  name        = "external_lb_http_sg"
  description = "Security group to allow HTTP traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webtier_sg" {
  name        = "webtier_http_sg"
  description = "Security group to allow HTTP traffic to webtier"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "Allow HTTP traffic from the first security group"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.external_lb_sg.id]
  }
}

resource "aws_security_group" "internal_lb_sg" {
  name        = "internal_lb_http_sg"
  description = "Security group to allow HTTP traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.webtier_sg.id]
  }
}

resource "aws_security_group" "appserver_sg" {
  name        = "appserver_traffic_sg"
  description = "Security group to allow HTTP traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "Allow tcp traffic"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_traffic_sg"
  description = "Security group to allow db traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "Allow db traffic"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.appserver_sg.id]
  }
}