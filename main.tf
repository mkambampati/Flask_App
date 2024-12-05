resource "aws_instance" "flask_app" {
    depends_on = [ aws_security_group.flask_app_sg ]
  ami           = "ami-012967cc5a8c9f891" # Replace with a valid Amazon Linux 2 AMI for your region
  instance_type = "t2.micro"
  key_name="terraform-key"
    vpc_security_group_ids = [aws_security_group.flask_app_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install python3 -y
              pip3 install flask
              echo "${file("${path.module}/app.py")}" > /home/ec2-user/app.py
              nohup python3 /home/ec2-user/app.py &
              EOF

  tags = {
    Name = "FlaskApp"
  }
}

resource "aws_security_group" "flask_app_sg" {
  name        = "flask_app_security_group"
  description = "Allow HTTP and SSH traffic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (Restrict this in production)
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "FlaskAppSG"
  }
}


output "instance_ip" {
  value = aws_instance.flask_app.public_ip
}