FROM combustml/mleap-spring-boot:0.19.0-SNAPSHOT

# Install Vertex dependencies

RUN \
  apt-get update && \
  apt install -y curl gnupg2 ca-certificates lsb-release

RUN \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y
     
# Install nginx
RUN \
  echo "deb http://openresty.org/package/debian $(lsb_release -sc) openresty" \
    | tee /etc/apt/sources.list.d/openresty.list && \
  curl -fsSL https://openresty.org/package/pubkey.gpg | apt-key add - && \
  apt-get update && \
  apt-get install -y --no-install-recommends openresty
ENV PATH "/usr/local/openresty/nginx/sbin:${PATH}"
EXPOSE 8080

# Set up container boot
COPY scripts/startup.sh /opt/docker/bin/

# Configure nginx as a proxy
COPY nginx/edit_input_body.lua /usr/local/openresty/nginx/
COPY nginx/edit_output_body.lua /usr/local/openresty/nginx/
COPY nginx/mleap_schema.lua /usr/local/openresty/nginx/
COPY nginx/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["/bin/bash", "/opt/docker/bin/startup.sh"]
CMD ["/bin/bash", "/opt/docker/bin/startup.sh"]