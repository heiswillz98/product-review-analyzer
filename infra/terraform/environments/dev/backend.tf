terraform {
  backend "s3" {
    bucket  = "your-terraform-state-bucket"
    key     = "your-terraform-state-key"
    region  = "your-terraform-state-region"
    encrypt = true
  }
}
