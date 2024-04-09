resource "aws_security_group" "jump_host_sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host"

  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing SSH access from anywhere, adjust this as per your security requirements
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance as the bastion host
resource "aws_instance" "jump_host" {
  ami           = "ami-051f8a213df8bc089" # Replace this with the appropriate AMI for your bastion host (Amazon Linux, Ubuntu, etc.)
  instance_type = "t2.micro"              # Adjust instance type as needed
  # vpc_id = data.aws_vpc.vpc.id

  subnet_id = data.aws_subnet.public_1.id # Ensure this is a public subnet
  key_name  = "sumitanand"                # Replace with your SSH key pair name

  security_groups             = [aws_security_group.jump_host_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "bastion-host"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "Installing Kubectl"
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
    echo "kubectl Installed"
    echo "------------------------------------"
    echo "Installing Helm"
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh

    EOF
}


# Output the public IP of the bastion host
output "bastion_public_ip" {
  value = aws_instance.jump_host.public_ip
}