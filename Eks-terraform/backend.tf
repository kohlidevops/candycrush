terraform {
  backend "s3" {
    bucket = "latchutfs3"
    key    = "EKS/terraform.tfstate"
    region = "ap-south-1"
  }
}
