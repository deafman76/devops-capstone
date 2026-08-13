terraform {
    backend "s3" {
        bucket = "bootcamp-terraform-state-597765856364-team3"
        key = "devops-capstone/team3/terraform.tfstate"
        region = "eu-west-1"
        dynamodb_table = "bootcamp-terraform-lock-team3"
        encrypt = true
    }
}