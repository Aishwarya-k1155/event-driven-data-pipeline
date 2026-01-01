provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.project_name}-raw-data-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "processed_data" {
  bucket = "${var.project_name}-processed-data-${random_id.suffix.hex}"
}

