#!/bin/bash

HOST='http://localhost:3000'
KEY=""
DIR="grafana_dashboards"

# Iterate through dashboards using the current API Key
for dashboard_uid in $(curl -sS -H "Authorization: Bearer $KEY" $HOST/api/search\?query\=\& | jq -r '.[] | select( .type | contains("dash-db")) | .uid'); do
    url=$(echo $HOST/api/dashboards/uid/$dashboard_uid | tr -d '\r')
    dashboard_json=$(curl -sS -H "Authorization: Bearer $KEY" $url)
    dashboard_title=$(echo $dashboard_json | jq -r '.dashboard | .title' | sed -r 's/[ \/]+/_/g')
    dashboard_version=$(echo $dashboard_json | jq -r '.dashboard | .version')
    folder_title="$(echo $dashboard_json | jq -r '.meta | .folderTitle')"

    echo "Creating: ${DIR}/${folder_title}/${dashboard_title}_v${dashboard_version}.json"
    mkdir -p "${DIR}/${folder_title}"
    echo ${dashboard_json} | jq -r {meta:.meta}+.dashboard > "${DIR}/${folder_title}/${dashboard_title}_v${dashboard_version}.json"
done
