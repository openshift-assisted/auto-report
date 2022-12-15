"""CLI entrypoint for executing auto-report"""

import os
import sys
import logging
from pythonjsonlogger import jsonlogger
from opensearchpy import OpenSearch
from slack_sdk.webhook import WebhookClient
from .release_stats import ReleaseStats
from .release_formatter import format_releases_to_text


def get_custom_format() -> str:
    """
    Return custom format for log formatter.
    """
    log_fields = [
        "asctime",
        "name",
        "levelname",
        "thread",
        "message",
        "pathname",
        "lineno",
    ]
    return " ".join([f"%({field})s" for field in log_fields])


def get_logger():
    """
    Initialize logger with json formatter and specific fields
    """
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)

    loglevel = os.environ.get('LOGLEVEL', 'INFO').upper()
    handler.setLevel(loglevel)

    formatter = jsonlogger.JsonFormatter(get_custom_format())
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    return logger


def cli():
    """
    Entrypoint for executing auto-report.
    """
    logger = get_logger()

    os_usr = os.environ['OPENSEARCH_USERNAME']
    os_pwd = os.environ['OPENSEARCH_PASSWORD']
    os_host = os.environ['OPENSEARCH_HOST']

    slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']

    client = OpenSearch(
        os_host,
        http_auth=(os_usr, os_pwd)
    )
    release_stats = ReleaseStats(
        opensearch_client=client,
        index="assisted-service-events",
        logger=logger
    )
    releases = release_stats.get(
        from_date="now-6w/d",
        to_date="now/d",
        top_n=3
    )
    logger.debug("Releases: %s", releases)

    text = format_releases_to_text(releases)
    logger.debug("Text: %s", text)

    if text:
        webhook = WebhookClient(slack_webhook_url)
        response = webhook.send(text=f"morning stats\n```{text}```")
        logger.debug("Slack webhook response: %s", response)
        sys.exit(0)

    logger.warning("There is no text to send.")
