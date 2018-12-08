#!/usr/bin/env bash
export API_KEY=352833645b0088dceb7fa8de8162e096
export APPLICATION_ID=ODXESEWP8N
curl -X POST \
-H "X-Algolia-API-Key: ${API_KEY}" \
-H "X-Algolia-Application-Id: ${APPLICATION_ID}" \
--data-binary '{"requests":[{"indexName":"àlgol?à-dart-47842739-35ab-41f0-96ec-467896fad017","params":"hitsPerPage=1&query=francisco"},{"indexName":"àlgol?à-dart-47842739-35ab-41f0-96ec-467896fad017","params":"query=jose"}],"strategy":"none"}' \
"https://${APPLICATION_ID}-dsn.algolia.net/1/indexes/*/queries"
