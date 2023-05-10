terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ca-central-1"
}

# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Demo VPC"
  }
}

# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-1a"
  }
}






# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "Demo IGW"
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.web-rt.id
}

#create private S3 bucket

resource "aws_s3_bucket" "bucket" {
  bucket = "mypribucketinterview"
  acl    = "private"
}


#create EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "efsvolumes"

  tags = {
    Name = "efsvolume"
  }
}

# Creating Mount target of EFS
resource "aws_efs_mount_target" "mount" {
file_system_id = aws_efs_file_system.efs.id
subnet_id      = aws_subnet.web-subnet.id
security_groups = [aws_security_group.web-sg.id]
}

# Creating Mount Point for EFS
resource "null_resource" "configure_nfs" {
depends_on = [aws_efs_mount_target.mount]
connection {
type     = "ssh"
user     = "ec2-user"
private_key = local_file.ssh_key.content
host     = data.aws_eip.eip.public_ip
 }
 provisioner "remote-exec" {
    inline = [
      "echo ${aws_efs_file_system.efs.dns_name}",
      "ls -la",
      "sudo mkdir -p /data",
      "sudo mkdir -p /data/test",
      "ls -la",
      "sudo yum install -y amazon-efs-utils",
      "sleep 30",
      
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/ /data/test",
      "ls",
      "sudo chown -R ec2-user:ec2-user /data/test",      
      "cd /data/test",
      
    ]
  }

}
# resource block for eip #
data "aws_eip" "eip" {
  tags = {
    Project = "NetSPI_EIP"
  }
}
resource "aws_eip_association" "eip-association" {
  instance_id   = aws_instance.webserver1.id
  allocation_id = data.aws_eip.eip.id
}

# Generates a secure private k ey and encodes it as PEM
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Create the Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2_key_pair2"  
  public_key = tls_private_key.ec2_key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "keypair.pem"
  content  = tls_private_key.ec2_key.private_key_pem
}

#Create EC2 Instance
resource "aws_instance" "webserver1" {
  ami                    = "ami-0b18956f"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id              = aws_subnet.web-subnet.id
  key_name               = aws_key_pair.ec2_key.key_name
  

  tags = {
    Name = "Web Server"
  }

}


# Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "Web-SG"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
ingress {
description = "EFS mount target"
from_port   = 2049
to_port     = 2049
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-SG"
  }
}



output "ec2" {
  description = "EC2 ID"
  value = "${aws_instance.webserver1.id}"
}

output "s3" {
  description = "S3 ID"
  value = "${aws_s3_bucket.bucket.id}"
}

output "EFS" {
  description = "EFS ID"
  value = "${aws_efs_file_system.efs.id}"
}

output "SGgroup" {
  description = "SG ID"
  value = "${aws_security_group.web-sg.id}"
}

output "Subnet" {
  description = "subnet ID"
  value = "${aws_subnet.web-subnet.id}"
}