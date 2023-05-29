resource "aws_codepipeline" "java_app_pipeline" {
  name     = "java-app-pipeline"
  role_arn = aws_iam_role.java_app_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.java_app_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source-artifact"]
      configuration = {
        Owner             = "SabiNjoshi1"
        Repo              = "demo-java-app-final"
        Branch            = "main"
        OAuthToken        = var.github-oauth-token
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "WebServerBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source-artifact"]
      output_artifacts = ["web-server-build-artifacts"]
      configuration = {
        ProjectName = aws_codebuild_project.java_app_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "WebserverDeploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      version          = "1"
      input_artifacts  = ["web-server-build-artifacts"]
      output_artifacts = []
      configuration = {
        ApplicationName     = "${aws_codedeploy_app.Java_app.name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.java_app_code_deployment_group.deployment_group_name}"
      }
    }
  }

  tags = {
    project = "web server"
  }
}

resource "aws_iam_role" "java_app_codepipeline_role" {
  name = "JavaAppPipelineRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com",
            "s3.amazonaws.com",
            "codepipeline.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    project = "web server"
  }
}

resource "aws_iam_role_policy" "java_app_codepipeline_policy" {
  name = "JavaAppPipelineRole"
  role = aws_iam_role.java_app_codepipeline_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codepipeline:StartPipelineExecution",
          "codepipeline:GetPipelineExecution",
          "codepipeline:GetPipelineState",
          "codepipeline:ListPipelines"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
        ],
        "Resource" : "${aws_codebuild_project.java_app_build.arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : "codedeploy:*"
        "Resource" : ["${aws_codedeploy_deployment_group.java_app_code_deployment_group.arn}", "arn:aws:codedeploy:*:*:deploymentconfig:*", "${aws_codedeploy_app.Java_app.arn}"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_bucket_policy_java_app_codepipeline" {
  role       = aws_iam_role.java_app_codepipeline_role.id
  policy_arn = aws_iam_policy.Java_app_s3_bucket_access_policy.arn
}
