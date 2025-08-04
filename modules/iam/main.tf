locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}-${var.component}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = "${local.base_name}-role-01"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name        = "${local.base_name}-role-01"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "main" {
  name = "${local.base_name}-profile-01"
  role = aws_iam_role.main.name

  tags = {
    Name        = "${local.base_name}-profile-01"
    Environment = var.environment
  }
}