terraform {
  backend "s3" {
    bucket = "hiteshnlams-demos-001"
    key    = "terraform/state/ohpen-etl-project/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}
