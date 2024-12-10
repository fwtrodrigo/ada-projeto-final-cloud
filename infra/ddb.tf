resource "aws_dynamodb_table" "contabilidade_ddb_table" {
  name         = "${var.ENV_NAME}-ddb-table-rdg"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "filename"

  attribute {
    name = "filename"
    type = "S"
  }

  attribute {
    name = "lines_count"
    type = "N"
  }

  global_secondary_index {
    name            = "lines_countIndex"
    hash_key        = "lines_count"
    projection_type = "ALL"
  }
}
