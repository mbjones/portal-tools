#!/bin/sh
# Usage: get-portal-doc.sh portal-label
LABEL=$1
SERVICE="https://cn.dataone.org/cn/v2/"
REPO="https://mn-ucsb-1.dataone.org/knb/d1/mn/v2"
JSON=`curl -s ${REPO}/query/solr/?q=\(label:%22${LABEL}%22%20OR%20seriesId:%22${LABEL}%22\)%20AND%20-obsoletedBy:*\&fl=seriesId,id,label,datasource,obsoletes,obsoletedBy\&sort=dateUploaded%20asc\&rows=100\&wt=json`
PID=`echo ${JSON} | jq -r '.response.docs[0].id'`
NEWLABEL=`echo ${JSON} | jq -r '.response.docs[0].label'`
#echo "New label: ${NEWLABEL}"

echo "Getting PID: ${PID}"
curl -s ${REPO}/meta/${PID} -o ${NEWLABEL}-sysmeta.xml
echo "Saved system metadata doc to ${NEWLABEL}-sysmeta.xml"
curl -s ${REPO}/object/${PID} -o ${NEWLABEL}-portal.xml
echo "Saved portal doc to ${NEWLABEL}-portal.xml."
