#!/bin/sh
# Usage: get-portal-doc.sh portal-label
LABEL=$1
curl https://cn.dataone.org/cn/v2/query/solr/?q=\(label:%223842910%22%20OR%20seriesId:%223842910%22\)%20AND%20-obsoletedBy:*\&fl=seriesId,id,label,datasource,obsoletes,obsoletedBy\&sort=dateUploaded%20asc\&rows=100\&wt=json | jq -r '.response.docs[0].id'
#urn:uuid:72f9b6c5-8c45-4415-ae1e-4d627904c2db
