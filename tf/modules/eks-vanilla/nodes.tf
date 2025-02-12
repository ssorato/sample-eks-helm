resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.id
  node_group_name = aws_eks_cluster.main.id
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = data.aws_ssm_parameter.pod_subnets[*].value

  instance_types = var.nodes_instance_sizes

  scaling_config {
    desired_size = var.auto_scale_options["desired"]
    max_size     = var.auto_scale_options["max"]
    min_size     = var.auto_scale_options["min"]
  }

  labels = merge(
    {
      "ingress/ready" = "true"
    },
    var.node_labels
  )

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  timeouts {
    create = "1h"
    update = "2h"
    delete = "2h"
  }

  tags = merge(
    {
      Name                                        = format("%s-node-grpup", var.project_name),
      "kubernetes.io/cluster/${var.project_name}" = "owned"
    },
    var.common_tags
  )

  depends_on = [
    aws_eks_access_entry.nodes
  ]
}