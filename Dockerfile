FROM combustml/mleap-spring-boot:0.19.0-SNAPSHOT

# Install nginx
RUN \
  apt-get update && \
  apt install -y curl gnupg2 ca-certificates lsb-release && \
  echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
    | tee /etc/apt/sources.list.d/openresty.list && \
  curl -fsSL https://openresty.org/package/pubkey.gpg | apt-key add - && \
  apt-get update && \
  apt-get install -y --no-install-recommends openresty
ENV PATH "/usr/local/openresty/nginx/sbin:${PATH}"
EXPOSE 8080

# Install lua dependencies
# TODO: cjson is already installed according to https://openresty.org/en/lua-cjson-library.html

# Set up container boot
COPY scripts/startup.sh /root/

# Configure nginx as a proxy
COPY nginx/edit_input_json.lua /usr/local/openresty/nginx/
COPY nginx/edit_output_json.lua /usr/local/openresty/nginx/
COPY nginx/load_schema.lua /usr/local/openresty/nginx/
COPY nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["/bin/bash", "/root/startup.sh"]
CMD ["/bin/bash", "/root/startup.sh"]