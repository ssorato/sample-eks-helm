resource "aws_ssm_parameter" "dns_name_certificate_id" {
  name = format("/%s/certificate/%s/id", var.project_name, replace(var.route53.dns_name, "*.", ""))
  type = "String"

  value = aws_acm_certificate.main.id

  tags = merge(
    {
      Name = format("/%s/certificate/%s/id", var.project_name, replace(var.route53.dns_name, "*.", ""))
    },
    var.common_tags
  )
}
