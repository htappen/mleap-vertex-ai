# Check that necessary config is set

if [ ! -v AIP_STORAGE_URI ]; then
    echo "Env variable AIP_STORAGE_URI is not set! Usually this means you didn't set artifactUri in Vertex when deploying the model. " >&2
fi

if [ ! -v MLEAP_SCHEMA_URI ]; then
    echo "Env variable MLEAP_SCHEMA_URI is not set! Set this to the GCS path of an example input to your model, in MLeap Frame JSON format. " >&2
fi

if [ ! -v OUTPUT_KEY ]; then
    echo "Env variable OUTPUT_KEY is not set! Set this to the key from your model that contains the final prediction. " >&2
fi


# Start mleap
/opt/docker/bin/mleap-spring-boot &

# Download the model
mkdir -p /root/models/
gsutil cp -r $AIP_STORAGE_URI /root/models/
if [ $? -ne 0 ]; then
    echo "Failed to download model!" >&2
fi
find /root/models -name "*zip" | head -n 1 | xargs -I{} mv {} /root/model.zip
if [[ ! -f /root/model.zip ]]; then
    echo "Model failed to copy" >&2
fi

# Download the schema
mkdir -p /root/schema/
gsutil cp $MLEAP_SCHEMA_URI /root/schema/
if [ $? -ne 0 ]; then
    echo "Failed to download schema!" >&2
fi
find /root/schema -name "*json" | head -n 1 | xargs -I{} mv {} /root/input_schema.json
if [[ ! -f /root/input_schema.json ]]; then
    echo "Schema failed to copy" >&2
fi

# Load the model in mleap
sleep 10

curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"modelName":"model","uri":"file:/root/model.zip","config":{"memoryTimeout":900000,"diskTimeout":900000},"force":false}' \
  http://localhost:65327/models

# Start nginx
nginx -c /etc/nginx/nginx.conf