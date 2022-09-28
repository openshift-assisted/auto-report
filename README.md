# Auto Report

Generates reports automatically from AI stats.


### Required environment variables

`OPENSEARCH_USERNAME` Username for OpenSearch
`OPENSEARCH_PASSWORD` Password for OpenSearch
`OPENSEARCH_HOST` Host for OpenSearch
`SLACK_WEBHOOK_URL` Slack webhook for sending the message.


### Usage

Run `auto_report`.

It automatically reads the needed data from OpenSearch and spits them in slack.
