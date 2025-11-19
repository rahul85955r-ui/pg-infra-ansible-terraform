terraform {
  backend "s3" {
    bucket = "postgres-infra-state12"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
