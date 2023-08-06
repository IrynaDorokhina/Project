/*#Create pulic access bucket
resource "aws_s3_bucket" "projectbucket026" {
    bucket = "projectbucket026"
}

resource "aws_s3_bucket_public_access_block" "projectbucket026" {
    bucket = aws_s3_bucket.projectbucket026.id
    block_public_acls = false
    block_public_policy = false
}*/

/*#Create private bucket
resource "aws_s3_bucket" "projectbucket025" {
bucket = "projectbucket025"
    tags = {
        Name = "projectbucket025"
    }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
    bucket = aws_s3_bucket.projectbucket025.id
    acl = "private"
    depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership ]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
    bucket = aws_s3_bucket.projectbucket025.id
    rule {
        object_ownership = "ObjectWriter"    //BucketOwnerPreferred
    }
}*/