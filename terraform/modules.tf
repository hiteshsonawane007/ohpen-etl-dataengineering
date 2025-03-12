module "raw" {
  source      = "./modules/s3"
  bucket_name = "ohpen-etl-raw-financial-data"
  folder_keys = ["transactions/raw/"]
  tags = {
    Name        = "ETL Raw Data"
    Environment = "production"
  }
  upload_zip  = true
  zip_source  = "../etl_package.zip"
}

module "processed" {
  source      = "./modules/s3"
  bucket_name = "ohpen-etl-processed-financial-data"
  folder_keys = ["transactions/processed/"]
  tags = {
    Name        = "ETL Processed Data"
    Environment = "production"
  }
}

module "sns" {
  source     = "./modules/sns"
  topic_name = "GlueJobAlerts"
  email      = var.sns_topic_email
}

module "glue" {
  source              = "./modules/glue"
  job_name            = var.glue_job_name
  role_name           = var.role_name
  etl_package_s3_uri  = module.raw.etl_package_s3_uri
  max_capacity        = 2
  input_folder_uri    = "s3://${module.raw.bucket_name}/transactions/raw/"
  output_folder_uri   = "s3://${module.processed.bucket_name}/transactions/processed/"
  sns_topic_arn       = module.sns.topic_arn
  temp_dir            = "s3://${module.processed.bucket_name}/tmp/"
  s3_resources        = [
    "arn:aws:s3:::${module.raw.bucket_name}",
    "arn:aws:s3:::${module.raw.bucket_name}/*",
    "arn:aws:s3:::${module.processed.bucket_name}",
    "arn:aws:s3:::${module.processed.bucket_name}/*"
  ]
}

module "glue_crawler" {
  source       = "./modules/glue_crawler"
  crawler_name = "transactions-crawler"
  database_name = "etl_database"
  s3_target     = "s3://${module.processed.bucket_name}/transactions/processed/"
  region        = var.region
}