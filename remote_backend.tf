terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "jpapazian-org"

    workspaces {
      name = "aws-ec2-win-credentials"
    }
  }
}