variable "key" {
  description = "Please Enter the API KEY"
}
variable "secret" {
  description = "Please enter the API SECRET"
}


variable "zone" {
  default = "at-vie-1" # your prefered exoscale zone
}

variable "bucket" {
  default = "dep-longhorn-backup" # YOUR prefered bucket name , must be unique within exoscale
}

provider "aws" {
  access_key = var.key
  secret_key = var.secret

  region = var.zone
  endpoints {
    s3 = "https://sos-${var.zone}.exo.io"
  }

  # Deactivate the AWS specific behaviours
  #
  # https://www.terraform.io/docs/backends/types/s3.html#skip_credentials_validation
  skip_credentials_validation = true
  skip_get_ec2_platforms = true
  skip_requesting_account_id = true
  skip_metadata_api_check = true
  skip_region_validation = true

}

resource "aws_s3_bucket" "dep-longhorn-backup" {
  bucket = var.bucket 
}

resource "aws_s3_bucket_acl" "dep-longhorn-backup-acl" {
  bucket = var.bucket
  acl = "private"
  depends_on =[
    aws_s3_bucket.dep-longhorn-backup,
  ]
}




