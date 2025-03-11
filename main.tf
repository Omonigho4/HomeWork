# Define an S3 bucket resource named "jo_team_bucket"
resource "aws_s3_bucket" "jo_team_bucket" {
  bucket = var.bucket_name  # The bucket name is dynamically assigned from a variable
  acl    = "private"        # Access Control List (ACL) set to "private", meaning no public access

  # Configure server-side encryption for the S3 bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn  # Use the AWS KMS key for encryption
        sse_algorithm     = "aws:kms"              # Specify AWS KMS as the encryption method
      }
    }
  }

  # Define tags for the S3 bucket for identification and management
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Terraform   = "true"
  }
}

# Define an AWS KMS key for encrypting S3 objects
resource "aws_kms_key" "mykey" {
  description         = "This key is used to encrypt bucket objects"  # Description of the KMS key
  enable_key_rotation = true  # Enable automatic key rotation for better security
  policy = data.aws_iam_policy_document.key_policy.json  # Attach a custom IAM policy to the KMS key
}

# Retrieve the AWS account identity of the current user
data "aws_caller_identity" "current" { 
}

# Define an IAM policy for the KMS key
data "aws_iam_policy_document" "key_policy" {
  statement {
    sid = "GrantFullAccessToRootUser"  # Statement ID for reference
    effect = "Allow"  # Granting permissions
    
    # Specify the IAM principal (Root User of the AWS account)
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    # Allow all KMS actions on this key
    actions   = ["kms:*"]
    resources = ["*"]
  }
}
