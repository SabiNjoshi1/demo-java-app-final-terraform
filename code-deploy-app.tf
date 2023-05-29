resource "aws_codedeploy_app" "Java_app" {
  compute_platform = "Server"
  name             = "JavaApp"
}