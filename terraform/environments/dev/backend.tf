terraform {
  required_version = ">= 1.10.0"
  backend "s3" {
    bucket       = "terraform-state-217729648492" # replace!
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
