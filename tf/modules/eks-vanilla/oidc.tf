data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint,
    var.eks_oidc_thumbprint
  ]
  url = flatten(concat(aws_eks_cluster.main[*].identity[*].oidc[0].issuer, [""]))[0]

  tags = merge(
    {
      Name = aws_eks_cluster.main.name
    },
    var.common_tags
  )
}
