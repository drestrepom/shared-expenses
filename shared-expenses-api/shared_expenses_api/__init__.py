import os
from fastapi import FastAPI, HTTPException, Depends
import aioboto3
from typing import AsyncGenerator
from types_aiobotocore_dynamodb.client import DynamoDBClient

# Nombre de la tabla DynamoDB
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE", "shared-expenses")

app = FastAPI()


# Dependencia para obtener el recurso de DynamoDB
async def get_dynamodb() -> AsyncGenerator[DynamoDBClient, None]:
    session = aioboto3.Session()
    async with session.client("dynamodb") as dynamodb:
        yield dynamodb


@app.get("/")
def read_root() -> dict[str, str]:
    return {"message": "Bienvenido al backend de gestión de gastos"}


@app.get("/db-check")
async def db_check(dynamodb: DynamoDBClient = Depends(get_dynamodb)) -> dict[str, str]:
    try:
        # Realiza una operación describe_table para verificar la conexión
        response = await dynamodb.describe_table(TableName=DYNAMODB_TABLE)
        if response and response.get("Table", {}).get("TableStatus") == "ACTIVE":
            return {"message": "DynamoDB connection successful!"}
        else:
            raise HTTPException(
                status_code=500,
                detail="DynamoDB connection check failed: Table not active",
            )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DynamoDB connection failed: {str(e)}")
