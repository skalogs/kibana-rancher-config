#!/usr/bin/env bash
set -e

RANCHER_BASEURL="rancher-metadata.rancher.internal/latest"

response=$(curl --write-out %{http_code} --silent --output /dev/null http://${RANCHER_BASEURL}/self/service/metadata/kibana-config)
if [ "$response" -eq 200 ]
then
  echo "Installing custom Kibana config"
  mkdir -p /usr/share/kibana/config
  # kibana.yml
  curl -sf ${RANCHER_BASEURL}/self/service/metadata/kibana-config > /usr/share/kibana/config/kibana.yml
fi

echo "Installing plugins..."
PLUGINS_TXT="/tmp/plugins.txt"
curl -sf ${RANCHER_BASEURL}/self/service/metadata/plugins > ${PLUGINS_TXT}

if [ -n "$CUSTOM_KIBANA_LOOK_AND_FEEL" ]; then
  CUSTOM_KIBANA="/tmp/kibana.tar.gz"
  curl -Lsf ${CUSTOM_KIBANA_LOOK_AND_FEEL} > ${CUSTOM_KIBANA}
  echo "Curl ${CUSTOM_KIBANA_LOOK_AND_FEEL} finish ..."
  tar -xvzf ${CUSTOM_KIBANA} -C /usr/share/kibana/
  echo "untar  ${CUSTOM_KIBANA} finish ..."
  rm -rf /usr/share/kibana/optimize/bundles
  echo "clean bundles finish ..."
fi

if [ -f "$PLUGINS_TXT" ]; then
  for plugin in $(<"${PLUGINS_TXT}"); do
    echo "Installing $(basename ${plugin})"
    /usr/share/kibana/bin/kibana-plugin install $plugin || true
  done
fi

/usr/local/bin/kibana-docker
