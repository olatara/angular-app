# S3 Bucket reference
resource "aws_s3_bucket" "convertr-codepipeline" {
  bucket = "convertr-codepipeline"
  acl    = "private"

  tags = {
    Name        = "convertr-codepipeline"
    Environment = "prod"
  }
}

resource "aws_iam_role" "codebuild" {
  name = "codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:123456789012:network-interface/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.convertr-codepipeline.arn}",
        "${aws_s3_bucket.convertr-codepipeline.arn}/*"
      ]
    }
  ]
}
POLICY
}

# Configure ECR
resource "aws_ecr_repository" "convertr-app" {
  name = "convertr-app"
  encryption_configuration {
      encryption_type = "KMS"
  }
}

resource "aws_codebuild_project" "convertr-codebuild" {
  name          = "convertr-codebuild"
  description   = "convertr codebuild"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.convertr-codepipeline.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = "true"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.convertr-codepipeline.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Environment = "Prod"
  }
}

resource "aws_codebuild_webhook" "convertr-codebuild-hook" {
  project_name = aws_codebuild_project.convertr-codebuild.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
  }
}

resource "aws_codebuild_source_credential" "github_token" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}
