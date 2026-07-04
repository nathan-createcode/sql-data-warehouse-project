"""
Bronze Layer Loader
-------------------
Reads CSV files from source_crm and source_erp, then loads them into the 'bronze' schema in postgreSQL using pandas + SQLAlchemy (df.to_sql())

First-time setup:
1. Copy ".env.example" to ".env" (in the same fodler as this script).
2. Fill in ".env" with your actual database credentials.
3. Install dependecies: pip install pandas python-dotenv
4. Run: python load_bronze.py
"""

import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# =======================================================================
# 1. LOAD CREDENTIAL FROM .env FILE
# =======================================================================
# load_dotenv() reads the ".env" file and injects its contents into
# this process's environment variables (os.environ), so credentials
# are never hardcoded directly in the source code.

load_dotenv()

DB_CONFIG = {
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT"),
    "database": os.getenv("DB_NAME")
}

# simple validation: make sure all required variables are set,
# so we get a clear error if something is missing from .env,
# instead of a confusing error later when SQLAlchemy tries to connect.

missing = [k for k, v in DB_CONFIG.items() if not v]
if missing:
    raise ValueError(
        f"The following config values are missing from .env: {missing}."
        f"Make sure the .env file exists and is complete (see .env.example)."
    )

CONNECTION_STRING = (
    f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
    f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
)

# =======================================================================
# 1. LOAD CREDENTIAL FROM .env FILE
# =======================================================================
BASE_PATH = "../../datasets" # relative to warehouse-dbt-postgres/bronze_loader

# Mapping: source CSV file -> target table name in the bronze schema
FILES_TO_LOAD = {
    f"{BASE_PATH}/source_crm/cust_info.csv": "crm_cust_info",
    f"{BASE_PATH}/source_crm/prd_info.csv": "crm_prd_info",
    f"{BASE_PATH}/source_crm/sales_details.csv": "crm_sales_details",
    f"{BASE_PATH}/source_erp/CUST_AZ12.csv": "erp_cust_az12",
    f"{BASE_PATH}/source_erp/LOC_A101.csv": "erp_loc_a101",
    f"{BASE_PATH}/source_erp/PX_CAT_G1V2.csv": "erp_px_cat_g1v2",
}

SCHEMA_NAME = "bronze"

def create_schema_if_not_exists(engine, schema_name):
    """ Create the 'bronze' schema in the database if it doesn't exist yet. """
    with engine.connect() as conn:
        conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {schema_name}"))
        conn.commit()
    print(f"Schema '{schema_name}' is ready.")

def load_csv_to_postgres(engine, file_path, table_name, schema_name):
    """ Read a single CSV file and load it into a Postgres table. """
    print(f"Reading {file_path} ...")
    df = pd.read_csv(file_path)

    print(f" -> Found {len(df)} rows. Loading into {schema_name}.{table_name} ...")
    df.to_sql(
        name=table_name,
        con=engine,
        schema=schema_name,
        if_exists="replace", # full reload every time this script runs
        index=False,
    )
    print(f" -> Done: {schema_name}.{table_name} ({len(df)}) rows\n")


def main():
    engine = create_engine(CONNECTION_STRING)

    create_schema_if_not_exists(engine, SCHEMA_NAME)

    for file_path, table_name, in FILES_TO_LOAD.items():
        try:
            load_csv_to_postgres(engine, file_path, table_name, SCHEMA_NAME)
        except FileNotFoundError:
            print(f"    [SKIP] File not found: {file_path}\n")
        except Exception as e:
            print(f"    [ERROR] Failed to load {file_path}: {e}\n")

    print("Bronze layer loading process complete.")

if __name__ =="__main__":
    main()