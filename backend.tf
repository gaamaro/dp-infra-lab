terraform {
  backend "s3" {
    bucket         = "dp-lab3-tfstate"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
