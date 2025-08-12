import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql import functions as F

args = getResolvedOptions(sys.argv, ["RAW_BUCKET", "CURATED_BUCKET"])
RAW_BUCKET = args["RAW_BUCKET"]; CURATED_BUCKET = args["CURATED_BUCKET"]

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

def standardize(df):
    # lower/trim headers and trim string values
    for c in df.columns:
        nc = c.strip().lower().replace(" ", "_")
        if nc != c:
            df = df.withColumnRenamed(c, nc)
    for (c, t) in df.dtypes:
        if t == "string":
            df = df.withColumn(c, F.trim(F.col(c)))
    return df

def read_csv(name):
    return (spark.read.option("header","true").option("inferSchema","true")
            .csv(f"s3://{RAW_BUCKET}/input/{name}"))

acc = standardize(read_csv("account.csv"))
cus = standardize(read_csv("customer.csv"))
txn = standardize(read_csv("transaction.csv"))

# --- explicit column names in your data ---
ACC_ID  = "account_id"      # account.csv
CUS_ID  = "customer_id"     # account.csv + customer.csv
TXN_ACC = "account_id"      # transaction.csv
AMT_COL = "amount_cents"    # if present, cents -> will divide by 100

# ---- Prefix helpers to avoid duplicate column names ----
def pref(df, prefix, keep=()):
    # return a new DF with all columns prefixed, except ones in 'keep'
    cols = []
    keep = set(k.lower() for k in keep)
    for c in df.columns:
        alias = c if c.lower() in keep else f"{prefix}{c}"
        cols.append(F.col(c).alias(alias))
    return df.select(*cols)

# Keep 'account_id' from transactions only; prefix everything else
txn_p = pref(txn, "t_", keep={TXN_ACC})    # keeps 'account_id'
acc_p = pref(acc, "a_")                    # e.g., a_account_id, a_customer_id, a_status, ...
cus_p = pref(cus, "c_")                    # e.g., c_customer_id, ...

# ---- Joins using the prefixed keys ----
df = txn_p.alias("t").join(
        acc_p.alias("a"),
        F.col(f"t.{TXN_ACC}") == F.col(f"a.a_{ACC_ID}"),
        "left"
     )

df = df.join(
        cus_p.alias("c"),
        F.col(f"a.a_{CUS_ID}") == F.col(f"c.c_{CUS_ID}"),
        "left"
     )

# amount normalization (optional)
amt_candidates = [AMT_COL, f"t_{AMT_COL}"]
for colname in amt_candidates:
    if colname in df.columns:
        df = df.withColumn("amount", (F.col(colname).cast("double") / F.lit(100.0)))
        break

out = f"s3://{CURATED_BUCKET}/joined/"
df.write.mode("overwrite").format("parquet").save(out)
print(f"[Glue] Wrote curated dataset to {out}")
