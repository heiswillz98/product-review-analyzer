terraform {
  backend "s3" {
    bucket  = "product-review-tfstate"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
