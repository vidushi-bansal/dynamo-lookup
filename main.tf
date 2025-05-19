resource "aws_dynamodb_table" "cloudaccounts" {
  name           = "cloudaccounts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "account_id"

  attribute {
    name = "account_id"
    type = "S"
  }

  tags = {
    Name        = "cloudaccounts"
    Environment = "Dev"
    Managed-by  = "Terraform"
  }
}