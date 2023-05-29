variable "ami-id" {
  type = string
  default = "ami-0889a44b331db0194"
  description = "AMI ID to deploy EC2 instance"
}

variable "instance-type" {
  type = string
  default = "t2.micro"
  description = "Type of instance to deploy" 
}

variable "key-name" {
  default       = "sabinnew"
  description   = "Pem File"
  type          = string
}

variable "github-oauth-token" {
  default       = "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"
  description   = "OAuthToken GitHub"
  type          = string
}


