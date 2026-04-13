terraform {
  backend "s3" {
    bucket       = "terraform-state-217729648492" # replace!
    key          = "staging/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
