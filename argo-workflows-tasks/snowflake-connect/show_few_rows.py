import os

import snowflake.connector as snow

account = os.getenv("SNOWFLAKE_ACCOUNT", "my_account_name")
user = os.getenv("SNOWFLAKE_USER", "my_user_name")
password = os.getenv("SNOWFLAKE_PASSWORD", "my_password")

print(f"Connecting to Snowflake account: {account} as user: {user}")

# Create a connection to Snowflake
connection = snow.connect(
    account=account,
    user=user,
    password=password,
    warehouse="load_wh",
    database="fraud",
    schema="public",
)

# Define a cursor
cursor = connection.cursor()

try:
    cursor.execute("SELECT * FROM FRAUD.PUBLIC.FIRSTSHIELD_CONTROL_ORDERDATA LIMIT 5")
    one_row = cursor.fetchone()
    print(one_row)
finally:
    cursor.close()
connection.close()
