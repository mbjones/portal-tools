#!/bin/sh
# Usage: get-portal-doc.sh portal-label
LABEL=$1
SERVICE="https://cn.dataone.org/cn/v2/"
PID=`curl -s ${SERVICE}/query/solr/?q=\(label:%22${LABEL}%22%20OR%20seriesId:%22${LABEL}%22\)%20AND%20-obsoletedBy:*\&fl=seriesId,id,label,datasource,obsoletes,obsoletedBy\&sort=dateUploaded%20asc\&rows=100\&wt=json | jq -r '.response.docs[0].id'`
echo "Getting PID: ${PID}"
curl -s ${SERVICE}/meta/${PID} -o ${LABEL}-sysmeta.xml
echo "Saved system metadata doc to ${LABEL}-sysmeta.xml"
curl -s ${SERVICE}/object/${PID} -o ${LABEL}-portal.xml
echo "Saved portal doc to ${LABEL}-portal.xml."
