#!/bin/sh
# Usage: update-portal-doc.sh portal-file sysmeta-file token
PORTAL=$1
SYSMETA=$2
TOKEN=$3

REPO="https://mn-ucsb-1.dataone.org/knb/d1/mn/v2"
D1NS="http://ns.dataone.org/service/types/v2.0"
PONS="https://purl.dataone.org/portals-1.0.0"

# Extract label from portal doc
LABEL=`xml sel -N por="${PONS}" -t -m "//por:portal" -v "label" ${PORTAL}`
echo "  Label: ${LABEL}"

# Extract old PID from sysmeta
OLD_PID=`xml sel -N d1="${D1NS}" -t -m "//d1:systemMetadata" -v "identifier" ${SYSMETA}`
echo "Old PID: ${OLD_PID}"

# Generate a new UUID identifier
UUID="urn:uuid:`uuid`"
echo "New PID: ${UUID}"

# Calculate a new checksum
CHK=`shasum -a 256 ${PORTAL} |awk '{print $1}'`
echo "SHA-256: ${CHK}"

# Determine new filesize
SIZE=$(stat -f%z ${PORTAL})
echo "   Size: ${SIZE}"

# Update SystemMetadata

## Set metadata fields: identifier, checksum, size, obsoletes, fileName, and remove replica
xml ed -N d1="${D1NS}" \
    -u /d1:systemMetadata/identifier -v "$UUID" \
    -u /d1:systemMetadata/size -v "$SIZE" \
    -u /d1:systemMetadata/obsoletes -v "$OLD_PID" \
    -u /d1:systemMetadata/checksum -v "$CHK" \
    -u /d1:systemMetadata/checksum/@algorithm -v "SHA-256" \
    -u /d1:systemMetadata/fileName -v "${LABEL}-portal.xml" \
    -d /d1:systemMetadata/replica \
    ${SYSMETA} > ${LABEL}-sysmeta-new.xml

# Ensure we have a valid TOKEN
#curl -H "Authorization: Bearer ${TOKEN}" ${SERVICE}/diag/subject

# Update the existing document on the node
curl -H "Authorization: Bearer ${TOKEN}" \
    -X PUT \
    -F "object=@${PORTAL}" \
    -F "newPid=${UUID}" \
    -F "sysmeta=@${LABEL}-sysmeta-new.xml" \
    ${REPO}/object/${OLD_PID}

