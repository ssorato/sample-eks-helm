resource "aws_ssm_parameter" "vpc" {
  name = "/${var.project_name}/vpc/id"
  type = "String"

  value = aws_vpc.main.id

  tags = merge(
    {
      Name = "/${var.project_name}/vpc/id"
    },
    var.common_tags
  )
}

resource "aws_ssm_parameter" "public_subnets" {
  count = length(aws_subnet.public)

  name  = "/${var.project_name}/subnets/public/${var.public_subnets[count.index].availability_zone}/${var.public_subnets[count.index].name}"
  type  = "String"
  value = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "/${var.project_name}/subnets/public/${var.public_subnets[count.index].availability_zone}/${var.public_subnets[count.index].name}"
    },
    var.common_tags
  )
}

resource "aws_ssm_parameter" "private_subnets" {
  count = length(aws_subnet.private)

  name  = "/${var.project_name}/subnets/private/${var.private_subnets[count.index].availability_zone}/${var.private_subnets[count.index].name}"
  type  = "String"
  value = aws_subnet.private[count.index].id

  tags = merge(
    {
      Name = "/${var.project_name}/subnets/private/${var.private_subnets[count.index].availability_zone}/${var.private_subnets[count.index].name}"
    },
    var.common_tags
  )
}

resource "aws_ssm_parameter" "natgw_eips" {
  count = var.unique_natgw == true ? 1 : length(var.public_subnets)

  name  = "/${var.project_name}/subnets/public/${var.public_subnets[count.index].availability_zone}/natgw-eip"
  type  = "String"
  value = aws_nat_gateway.main[count.index].allocation_id

  tags = merge(
    {
      Name = "/${var.project_name}/subnets/public/${var.public_subnets[count.index].availability_zone}/natgw-eip"
    },
    var.common_tags
  )
}
