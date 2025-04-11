resource "tls_private_key" "ec2_keypair_generate" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_secretsmanager_secret" "keypair_private" {
  name        = "keypair_private"
  description = "Private key for EC2 keypair"
  kms_key_id  = data.aws_kms_key.aws_secretsmanager.key_id
}

resource "aws_secretsmanager_secret_version" "keypair_private" {
  secret_id     = aws_secretsmanager_secret.keypair_private.id
  secret_string = tls_private_key.ec2_keypair_generate.private_key_openssh

}

resource "aws_secretsmanager_secret" "keypair_public" {
  name        = "keypair_public"
  description = "Public key for EC2 keypair"
  kms_key_id  = data.aws_kms_key.aws_secretsmanager.key_id

}

resource "aws_secretsmanager_secret_version" "keypair_public" {
  secret_id     = aws_secretsmanager_secret.keypair_public.id
  secret_string = tls_private_key.ec2_keypair_generate.public_key_openssh
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2_keypair"
  public_key = tls_private_key.ec2_keypair_generate.public_key_openssh
}