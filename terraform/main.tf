provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "web" {
  name        = "web_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Default VPC
resource "aws_default_vpc" "default" {

}

resource "aws_instance" "realestate" {
  ami               = "ami-0c7843ce70e666e51"
  instance_type     = "t3.micro"
  security_groups   = [aws_security_group.web.name]
  availability_zone = "us-west-2b"
  key_name          = "dev-us-west-2"
  tags = {
    Name = "Real-Estate-Server"
  }
  user_data = data.template_file.init.rendered
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/xvdf"
  volume_id   = "vol-0f10f75ddf61023bd"
  instance_id = aws_instance.realestate.id
}

# Create a Route 53 record for the instance's public IP
resource "aws_route53_record" "example_record" {
  zone_id = "Z01260761N1694YGQEOPD"
  name    = "realestate.polyglotvision.online"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.realestate.public_ip]
}

data "template_file" "init" {
  template = filebase64("userdata.tpl")
}

output "aws_instance_public_dns" {
  value = aws_instance.realestate.public_dns
}