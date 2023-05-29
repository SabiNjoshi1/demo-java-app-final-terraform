resource "aws_codebuild_project" "java_app_build" {
  name          = "java-app-build"
  build_timeout = "20"
  description   = "This is java app demo."
  service_role  = aws_iam_role.java_app_code_build_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = {
    project = "web server"
  }
}

resource "aws_iam_role" "java_app_code_build_role" {
  name = "JavaAppBuildRole"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codebuild.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })
}

resource "aws_iam_role_policy" "java_app_codebuild_policy" {
  name = "JavaAppBuildPolicy"
  role = aws_iam_role.java_app_code_build_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ],
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "code_build_policy_attach" {
  role       = aws_iam_role.java_app_code_build_role.name
  policy_arn = aws_iam_policy.Java_app_s3_bucket_access_policy.arn
}

