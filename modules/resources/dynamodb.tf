resource "aws_dynamodb_table" "aws_dynamodb" {
  name           = "ToggleMasterAnalytics"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-dynamo-table"
    }
  )
}