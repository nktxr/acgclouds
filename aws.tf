resource "aws_kms_key" "secrets_manager_key" {
  description             = "KMS key for encrypting Secrets Manager secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  #checkov:skip=CKV2_AWS_64:Ephemeral key for testing
}

resource "aws_kms_alias" "secrets_manager_key_alias" {
  name          = "alias/secretsmanager"
  target_key_id = aws_kms_key.secrets_manager_key.key_id
}

resource "tls_private_key" "ec2_keypair_generate" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_secretsmanager_secret" "keypair_private" {
  name        = "keypair_private"
  description = "Private key for EC2 keypair"
  kms_key_id  = aws_kms_key.secrets_manager_key.arn
  #checkov:skip=CKV2_AWS_57:Testing secret only
}

resource "aws_secretsmanager_secret_version" "keypair_private" {
  secret_id     = aws_secretsmanager_secret.keypair_private.id
  secret_string = tls_private_key.ec2_keypair_generate.private_key_openssh
}

resource "aws_secretsmanager_secret" "keypair_public" {
  name        = "keypair_public"
  description = "Public key for EC2 keypair"
  kms_key_id  = aws_kms_key.secrets_manager_key.arn
  #checkov:skip=CKV2_AWS_57:Testing secret only
}

resource "aws_secretsmanager_secret_version" "keypair_public" {
  secret_id     = aws_secretsmanager_secret.keypair_public.id
  secret_string = tls_private_key.ec2_keypair_generate.public_key_openssh
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "ec2_example_keypair"
  public_key = tls_private_key.ec2_keypair_generate.public_key_openssh
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "example_ec2" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t3.medium"

  key_name = aws_key_pair.ec2_keypair.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name     = "Example EC2 Instance"
    Deployed = "By Terraform"
  }
}