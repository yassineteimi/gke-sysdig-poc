# Requires the Sysdig Secure API token in the environment. Do not hardcode it.
#   export SYSDIG_SECURE_API_TOKEN="<your-token>"
: "${SYSDIG_SECURE_API_TOKEN:?Set SYSDIG_SECURE_API_TOKEN before running this script}"

# A scanning summary of all images used in the namespace : sysdigtest (Online boutique app ns)
curl -X GET "https://eu1.app.sysdig.com/api/scanning/runtime/v2/workflows/results?cursor&filter=kubernetes.namespace.name%20%3D%20%22sysdigtest%22&limit=100&order=desc&sort=runningVulnsBySev" \
-H "Authorization: Bearer ${SYSDIG_SECURE_API_TOKEN}" | python3 -mjson.tool > all_vulns.json

# For frontend image: gcr.io/google-samples/microservices-demo/frontend:v0.8.0
curl -X GET "https://eu1.app.sysdig.com/api/scanning/runtime/v2/workflows/results?cursor&filter=kubernetes.workload.name%20%3D%20%22frontend%22&limit=100&order=desc&sort=runningVulnsBySev" \
-H "Authorization: Bearer ${SYSDIG_SECURE_API_TOKEN}" | python3 -mjson.tool > frontend_vulns.json
