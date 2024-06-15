cd out

# Sync bundles with strong cache
aws s3 sync ./common/favicons s3://$S3_ORIGIN_BUCKET/common/favicons --exclude "site.webmanifest" --metadata-directive 'REPLACE' --cache-control max-age=31536000,public,must-revalidate --delete
aws s3 sync ./common/assets s3://$S3_ORIGIN_BUCKET/common/assets --metadata-directive 'REPLACE' --cache-control max-age=31536000,public,must-revalidate --delete
aws s3 sync ./_next s3://$S3_ORIGIN_BUCKET/_next --exclude "data/*" --metadata-directive 'REPLACE' --cache-control max-age=31536000,public,immutable --delete
aws s3 sync ./_next/data s3://$S3_ORIGIN_BUCKET/_next/data --metadata-directive 'REPLACE' --cache-control max-age=3600,must-revalidate --delete

# Sync HTML and other files with no cache
aws s3 sync ./ s3://$S3_ORIGIN_BUCKET --exclude "common/favicons/*" --exclude "_next/*" --exclude "common/assets/*" --include "common/favicons/site.webmanifest" --metadata-directive 'REPLACE' --cache-control no-cache,no-store,must-revalidate --delete
