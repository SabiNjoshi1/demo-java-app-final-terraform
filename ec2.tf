resource "aws_instance" "java_app_ec2_instance" {
  ami                         = var.ami-id
  instance_type               = var.instance-type
  associate_public_ip_address = true
  key_name                    = var.key-name
  subnet_id                   = aws_subnet.java_app_subnet.id
  availability_zone           = "us-east-1a" 
  vpc_security_group_ids      = [aws_security_group.java_app_sg_ssh.id]
  user_data                   = file("./launch-instance.sh")
  iam_instance_profile        = aws_iam_instance_profile.Ec2_Role_Attachment.name
  tags = {
    Name    = "java-app-ec2"
    project = "web server"
  }
}

resource "aws_iam_instance_profile" "Ec2_Role_Attachment" {
  name = "Ec2-role-attachment"
  role = aws_iam_role.ec2_to_s3_read_role.name
}

resource "aws_iam_role" "ec2_to_s3_read_role" {
  name = "JavaAppEc2ToS3ReadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "s3.amazonaws.com",
            "codepipeline.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "S3_Read_Policy" {
  policy_arn = aws_iam_policy.Java_app_s3_bucket_access_policy.arn
  role       = aws_iam_role.ec2_to_s3_read_role.name
}