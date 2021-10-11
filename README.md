# Serve Spark MLLib models on Google Cloud Vertex AI

This project contains the Docker setup necessary to create a [custom container](https://cloud.google.com/vertex-ai/docs/predictions/use-custom-container) on [Google Cloud Vertex AI](https://cloud.google.com/vertex-ai/docs/predictions/getting-predictions) for serving Spark MLLib models using [Mleap](https://github.com/combust/mleap)

# How it works
[Mleap](https://github.com/combust/mleap) allows you to retrieve individual predictions from models developed in Spark MLLib over a REST interface. Mleap defines a certain input/output interface.

Model servers hosted on Google Cloud Vertex AI must satisfy [certain requirements](https://cloud.google.com/vertex-ai/docs/predictions/custom-container-requirements) related to the data passed to and from the model server. Unfortunately, Mleap doesn't match these requirements. So, this project places an NGINX proxy in front of Mleap to translate data formats between those supported by those in Mleap and in Google Cloud Vertex AI.

# Instructions for usage
1. Build the Docker image using `Dockerfile` and upload to Google Artifact Registry.
1. Create an [MLeap model bundle](https://github.com/combust/mleap-docs/blob/master/core-concepts/mleap-bundles.md). Upload it to Google Cloud Storage.
1. Save an frame that has one input example for your model in [JSON format](https://combust.github.io/mleap-docs/mleap-runtime/storing.html). Also upload this to Google Cloud Storage.
1. Create a Vertex AI model, including setting these fields
  - `artifactUri`: The page to the MLeap model from above
  - `containerSpec`:
    - `env`: Set these variables
      - `name` = `OUTPUT_KEY`, `value` = the name of the key in the output frame from your model that contains the final prediction result
      - `name` = `MLEAP_SCHEMA_URI`, `value` = the GCS path (e.g. `gs://my_bucket/my_path/schema.json`) to the MLeap schema for your model. The required format is the same as the MLeap Frame JSON format, except the `rows` key is not required. The easiest way to provide this is to export an MLeap Frame compatible with your model. See [here](https://github.com/combust/mleap/blob/master/mleap-benchmark/src/main/resources/leap_frame/frame.airbnb.json) for an example.
    - `predictRoute`: `/models/model/transform`
    - `healthRoute`: `/api/`