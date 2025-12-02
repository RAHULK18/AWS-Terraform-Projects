resource "aws_dynamodb_table" "base-dynamodb" {
  name           = "${var.env}-rk-state-management"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key = var.hash_key
  attribute {
    name = var.hash_key
    type = "S"
  }
  
  tags = {
    Name        = "${var.env}-rk-state-management"
    Environment = var.env
  }
}