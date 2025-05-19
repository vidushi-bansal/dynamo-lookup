resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "GameScores"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "uid"

  attribute {
    name = "uid"
    type = "S"
  }

  tags = {
    Name        = "lookup-table"
    Environment = "dev"
  }
}