resource "aws_kms_key" "main" {
  description = var.project_name

  tags = merge(
    {
      Name = var.project_name
    },
    var.common_tags
  )
}

resource "aws_kms_alias" "main" {
  name          = format("alias/%s", var.project_name)
  target_key_id = aws_kms_key.main.id
}
