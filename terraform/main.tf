provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.project_name}-raw-data-${var.unique_suffix}"
}

resource "aws_s3_bucket" "processed_data" {
  bucket = "${var.project_name}-processed-data-${var.unique_suffix}"
}
