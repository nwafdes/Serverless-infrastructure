
# Creat the Policy
resource "aws_iam_policy" "Update_DDB_Table" {
    name = var.policy_name
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = [
                "dynamodb:ListTables",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem"
            ]
            Effect = "Allow"
            Resource = [
                "arn:aws:dynamodb:us-east-1:518029234085:table/My_Web_Visitors",
                "arn:aws:dynamodb:us-east-1:518029234085:table/My_Web_Visitors/* "
                ]
        }]
    })
}

# Create the IAM Role + Trust Policy
resource "aws_iam_role" "Lambda_Update_DDB_Role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "P-attch" {
  role       = aws_iam_role.Lambda_Update_DDB_Role.name
  policy_arn = aws_iam_policy.Update_DDB_Table.arn
}