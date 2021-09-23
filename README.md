# Serve Spark MLLib models on Google Cloud Vertex AI

This project contains the Docker setup necessary to create a [custom container](https://cloud.google.com/vertex-ai/docs/predictions/use-custom-container) on [Google Cloud Vertex AI](https://cloud.google.com/vertex-ai/docs/predictions/getting-predictions) for serving Spark MLLib models using [Mleap](https://github.com/combust/mleap)

# How it works
[Mleap](https://github.com/combust/mleap) allows you to retrieve individual predictions from models developed in Spark MLLib over a REST interface. Mleap defines a certain input/output interface.

Model servers hosted on Google Cloud Vertex AI must satisfy [certain requirements](https://cloud.google.com/vertex-ai/docs/predictions/custom-container-requirements) related to the data passed to and from the model server. Unfortunately, Mleap doesn't match these requirements. So, this project places an NGINX proxy in front of Mleap to translate data formats between those supported by those in Mleap and in Google Cloud Vertex AI.

# Instructions for usage
1. 