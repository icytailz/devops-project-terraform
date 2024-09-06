terraform {
  backend "s3" {
    bucket = "terraform-state-4fs2d"
    key = "state/terraform.tfstate"
    region = "us-east-1"
  }
}