import json
import logging
from datetime import datetime, timezone
from json import JSONDecodeError
from logging import Logger
from os import environ
from typing import Dict, List

from azure.functions import HttpRequest, HttpResponse
from notion_client import Client
from opencensus.ext.azure.log_exporter import AzureLogHandler

logger: Logger = logging.getLogger(__name__)
instrumentation_key = environ.get("APPINSIGHTSINSTRUMENTATIONKEY")
if instrumentation_key:
    logger.addHandler(
        AzureLogHandler(
            connection_string=f"InstrumentationKey={instrumentation_key}"
        )
    )
else:
    logger.warning(
        "Environment variable APPINSIGHTSINSTRUMENTATIONKEY was not found! "
        "Using default logging settings."
    )


def get_notion_data(notion_client: Client, database_id: str) -> List[Dict]:
    logger.info(
        f"Probeer de database-inhoud op te halen met ID: {database_id}"
    )
    return notion_client.databases.query(database_id=database_id).get(
        "results", []
    )


def write_to_lake(
    data: str, file_name: str, file_path: str, local_mode: bool = False
) -> None:
    logger.info(
        f"Wegschrijven data naar het lake (file {file_name}, path {file_path})"
    )
    if local_mode:
        with open(file_name, "w") as f:
            f.write(data)
        return


def get_datalake_path() -> str:
    return datetime.now(timezone.utc).strftime("%Y/%m/%d/%H%M%S")


def main(req: HttpRequest) -> HttpResponse:
    request_body: bytes = req.get_body()
    try:
        request_json = json.loads(request_body)
    except JSONDecodeError:
        return HttpResponse(
            json.dumps(
                {
                    "message": (
                        "Malformed JSON in request body. "
                        "Please check your HTTP request."
                    )
                }
            ),
            status_code=400,
        )
    database_id = request_json.get("database_id")

    if not database_id:
        return HttpResponse(
            json.dumps(
                {
                    "message": (
                        "Your request body must " "contain a database_id."
                    )
                }
            ),
            status_code=400,
        )

    if not environ.get("NOTIONAPITOKEN"):
        return HttpResponse(
            json.dumps(
                {
                    "message": (
                        "Environment variable NOTIONAPITOKEN not found! "
                        "Please check the function app settings."
                    )
                }
            ),
            400,
        )

    if not environ.get(f"DATABASEID{database_id}"):
        return HttpResponse(
            json.dumps(
                {
                    "message": (
                        f"Environment variable DATABASEID{database_id} "
                        "does not exist!"
                    )
                }
            ),
            status_code=400,
        )

    notion_client = Client(auth=environ["NOTIONAPITOKEN"])
    data: str = json.dumps(
        get_notion_data(notion_client, environ[f"DATABASEID{database_id}"])
    )
    directory = get_datalake_path()
    write_to_lake(data, "test.json", directory, local_mode=True)
    return json.dumps(
        {
            "message": (
                "Successfully written raw data for "
                f"database {database_id} to the data lake."
            )
        }
    )
