# AWS ETL Project

This repository contains an end-to-end ETL pipeline solution using AWS Glue, S3, SNS, and AWS Glue Crawlers integrated via Terraform. The pipeline ingests raw CSV files from S3, processes and validates the data using a Glue job written with PySpark, writes partitioned Parquet files to S3, catalogs the processed data via a Glue Crawler, and sends email notifications on job completion. The project is managed using Infrastructure as Code (Terraform modules) and automated with GitHub Actions.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Directory Structure](#project-directory-structure)
- [Components](#components)
  - [ETL Code](#etl-code)
  - [Testing](#testing)
  - [Infrastructure (Terraform Modules)](#infrastructure-terraform-modules)
  - [CI/CD Pipeline (GitHub Actions)](#cicd-pipeline-github-actions)
  - [Athena & SQL Query](#athena--sql-query)
  - [Schema Evolution](#schema-evolution)
- [Setup & Deployment](#setup--deployment)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This project implements a robust ETL process that:
- **Ingests Raw Data:** Uploads CSV files into a raw S3 bucket under the folder `transactions/raw/`.
- **Processes Data:** Uses AWS Glue (PySpark) to read the CSV files, perform validation and transformation, and write partitioned Parquet files to a processed S3 bucket under `transactions/processed/`.
- **Catalogs Data:** Utilizes an AWS Glue Crawler to create and update an external table in the AWS Glue Data Catalog.
- **Alerts:** Sends email notifications via Amazon SNS with job run summaries.
- **Analyzes Data:** Enables querying the processed data from Athena (e.g., to display account balance history).
- **Handles Schema Evolution:** Supports dynamic table updates when the data schema changes.

---

## Architecture

<<Diagram here: Architecture Diagram>>

### High-Level Components:
1. **Amazon S3 Buckets:**
   - **Raw Data Bucket:** `ohpen-etl-raw-financial-data` (contains `transactions/raw/`)
   - **Processed Data Bucket:** `ohpen-etl-processed-financial-data` (contains `transactions/processed/`)
2. **AWS Glue ETL Job:**
   - Reads CSV files from the raw folder.
   - Validates, transforms, and partitions data.
   - Writes Parquet files to the processed folder.
   - Sends SNS alerts with job metrics.
3. **AWS Glue Crawler:**
   - Crawls the processed data in S3.
   - Creates/updates an external table in the AWS Glue Data Catalog (e.g., in a database `etl_database`).
4. **Amazon SNS:**
   - Notifies business users via email with summary metrics of each Glue job run.
5. **Athena:**
   - Queries the external table and enables analytics (for example, end-of-month account balance history).
6. **Infrastructure Management (Terraform):**
   - Organizes resources into reusable modules: S3, SNS, Glue, and Glue Crawler.
7. **CI/CD Pipeline (GitHub Actions):**
   - Automates testing, packaging (zipping the ETL code), and deployment of resources via Terraform.

---

## Project Directory Structure

project-name/
├── etl/
│   ├── __init__.py                # Marks etl as a package (can be empty)
│   ├── glue_job.py                # Main AWS Glue ETL logic (PySpark)
│   ├── config.py                  # Application settings and configurations
│   ├── utils.py                   # Helper functions (data validation, etc.)
│   └── main.py                    # Entry point for AWS Glue (calls glue_job.main())
├── tests/                         # Contains unit tests and test fixtures
│   └── ...                        
├── terraform/                     # Terraform configuration for IAC
│   ├── backend.tf                 # Remote state config (S3 and DynamoDB)
│   ├── modules.tf                 # Instantiates modules (S3, SNS, Glue, Glue Crawler)
│   ├── outputs.tf                 # Root-level outputs
│   ├── variables.tf               # Root-level variables
│   ├── versions.tf                # Terraform version and provider requirements
│   └── modules/
│       ├── s3/                    # S3 module (creates buckets and dummy folder objects)
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── sns/                   # SNS module (creates topic and subscriptions)
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── glue/                  # Glue Job module (creates Glue job and IAM role)
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── glue_crawler/          # Glue Crawler module (creates catalog database, crawler, and IAM role/policy)
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions workflow for testing and deployment
├── requirements.txt               # Python dependencies (e.g., pyspark, boto3, pytest, etc.)
├── pytest.ini                     # Pytest configuration (ensures proper PYTHONPATH)
└── README.md



---

## Components

### ETL Code

- **glue_job.py:**  
  Contains the main ETL logic: reading CSV files from S3, validating and transforming the data, partitioning by year/month, writing Parquet files, and sending alerts via SNS.

- **config.py:**  
  Provides configuration settings such as application name, logging levels, and valid currencies.

- **utils.py:**  
  Contains helper functions like data validation.

- **__main__.py:**  
  Provides the entry point for AWS Glue. When the ZIP package is deployed on Glue, this file invokes `glue_job.main()`.

### Testing

- **Tests Folder:**  
  Contains unit tests written using PySpark and pytest. A `pytest.ini` file ensures the project root is in the `PYTHONPATH`.

### Infrastructure (Terraform Modules)

- **S3 Module:**  
  Creates the raw and processed S3 buckets with dummy folder objects.
- **SNS Module:**  
  Creates an SNS topic and subscribes an email (configurable) for alerts.
- **Glue Module:**  
  Creates the AWS Glue job with IAM roles to access S3, SNS, and CloudWatch Logs.
- **Glue Crawler Module:**  
  Creates a Glue Catalog database and a Glue crawler that scans the processed data in S3. The crawler policy supports schema evolution (e.g., adding new columns such as `TransactionType`).

### CI/CD Pipeline (GitHub Actions)

- **ci-cd.yml:**  
  Packages the ETL code into a ZIP file (ensuring `__main__.py` is at the root), runs tests, and deploys the Terraform configuration.

### Athena & SQL Query

- **External Table:**  
  Once the Glue crawler runs, an external table (e.g., `"AwsDataCatalog"."etl_database"."processed"`) is created over your processed data in S3.
- **Sample Athena Query:**  
  ```sql
  SELECT 
    account_id,
    date_trunc('month', transactiontimestamp) AS month_end,
    MAX(new_balance) AS end_of_month_balance
  FROM "AwsDataCatalog"."etl_database"."processed"
  WHERE transactiontimestamp BETWEEN TIMESTAMP '2025-01-01 00:00:00'
                             AND TIMESTAMP '2025-03-31 23:59:59'
  GROUP BY account_id, date_trunc('month', transactiontimestamp)
  ORDER BY account_id, month_end;

### Athena & SQL Query
If the source schema changes (for example, adding a TransactionType column), the Glue crawler is configured to update the table schema (using AddOrUpdateBehavior: "InheritFromTable"), so that the external table in Glue Catalog reflects the evolving schema. You may then update your Athena queries accordingly.

## Setup & Deployment

1. **Prerequisites:**
   - AWS account with necessary permissions (Glue, S3, SNS, Athena, CloudWatch).
   - Terraform (version ≥ 1.1.0) installed.
   - AWS CLI installed and configured.
   - Git and GitHub Actions enabled in your repository.

2. **Clone the Repository:**
   ```bash
   git clone https://github.com/hiteshsonawane007/ohpen-etl-dataengineering.git
