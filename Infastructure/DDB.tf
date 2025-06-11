# DDB Table
    # Standard Table
    # name = Visitor_Count
# DDB Item
#
resource "aws_dynamodb_table" "Sahaba-Table" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

resource "aws_dynamodb_table_item" "Sahaba-Table-Item" {
  table_name = aws_dynamodb_table.Sahaba-Table.name
  hash_key   = aws_dynamodb_table.Sahaba-Table.hash_key

  item = <<ITEM
{
  "${var.hash_key}": {"S": "${var.item_name}"},
  "${var.attr_name}": {"N": "0"}
}
ITEM
}