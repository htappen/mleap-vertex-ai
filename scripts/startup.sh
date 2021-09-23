# Check that necessary config is set
# TODO: add the check

# Download the model
mkdir -p /root/models/
gsutil cp $AIP_STORAGE_URI /root/models/
ls *.zip | head -n 1 | xargs mv {} /root/model.zip

# Download the schema
mkdir -p /root/schema/
gsutil cp $MLEAP_SCHEMA_URI /root/schema/
ls *.zip | head -n 1 | xargs mv {} /root/input_schema.json

# Start mleap
/opt/docker/bin/mleap-spring-boot &

sleep 20

# Load the model in mleap
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"modelName":"model","uri":"file:/root/model.zip","config":{"memoryTimeout":900000,"diskTimeout":900000},"force":false}' \
  http://localhost:65237/models

# Start nginx
nginx -c /etc/nginx/nginx.conf