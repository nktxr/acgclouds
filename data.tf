data "aws_kms_key" "aws_secretsmanager" {
  key_id = "aws/secretsmanager"
}