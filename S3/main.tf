provider "aws" {
  #version = "~> 3.22"
  region                  = "ap-northeast-2"
  shared_credentials_file = "/Users/kym/.aws/credentials"
  profile                 = "default"
  
}


// terrafrom state 파일용 lock 테이블
resource "aws_dynamodb_table" "terraform-state-lock" {
  name = "TerraformStateLock"
  read_capacity = 5
  write_capacity = 5
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

// 로그 저장용 버킷
resource "aws_s3_bucket" "terraform-logs" {
  bucket = "gsn.tf.logs"
  acl    = "log-delivery-write"
}

// Terraform state 저장용 S3 버킷
resource "aws_s3_bucket" "terraform-state" {
  bucket = "gsn.tf.state"
  acl    = "private"
  versioning {
    enabled = true
  }
  logging {
    target_bucket = "${aws_s3_bucket.terraform-logs.id}"
    target_prefix = "log/"
  }
  lifecycle {
    prevent_destroy = false
  }
}
