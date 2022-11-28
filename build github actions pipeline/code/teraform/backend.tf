terraform {
  backend "s3" {
    bucket = "nodeapp-statefile"
    key    = "core/terraform.tfstate"
    region = "us-east-2"
  }
}