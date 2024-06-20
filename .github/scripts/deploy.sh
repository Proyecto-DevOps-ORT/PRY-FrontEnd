#cd out

ROOT_FOLDER="dist/apps/catalog"

cd $ROOT_FOLDER 
# Sync HTML and other files with no cache
aws s3 sync ./ s3://$S3_ORIGIN_BUCKET --exclude "common/favicons/*" --exclude "_next/*" --exclude "common/assets/*" --include "common/favicons/site.webmanifest" --metadata-directive 'REPLACE' --cache-control no-cache,no-store,must-revalidate --delete
