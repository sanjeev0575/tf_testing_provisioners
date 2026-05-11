resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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


resource "aws_instance" "web" {
  ami                    = "ami-0a59ec92177ec3fad"      #"ami-091138d0f0d41ff90"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "office"

  tags = {
    Name = "nginx-server"
  }

  # local-exec

  provisioner "local-exec" {
    command = "echo EC2 Created with Public IP: ${self.public_ip} >> server_ip.txt"
  }

  provisioner "file" {
    source      = "./index.html"          # file on YOUR local machine
    destination = "/tmp/index.html"       # path on REMOTE EC2
        
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./office.pem")
      host        = self.public_ip
      timeout     = "5m"
    }
  }

  
  # remote-exec
  provisioner "remote-exec" {

    inline = [
      "sudo dnf update -y",
      "sudo dnf install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      #"echo '<h1>Terraform Nginx Server</h1>' | sudo tee /usr/share/nginx/html/index.html"
      "sudo cp /tmp/index.html /usr/share/nginx/html/index.html"

    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      #private_key = file("terraforms.pem")
      private_key = file("./office.pem")
      host        = self.public_ip
      timeout     = "5m"
    }
  }


}