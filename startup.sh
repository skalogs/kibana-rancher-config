#!/usr/bin/env bash
set -e

RANCHER_BASEURL="rancher-metadata.rancher.internal/latest"


echo "Installing plugins..."
PLUGINS_TXT="/tmp/plugins.txt"
curl -sf ${RANCHER_BASEURL}/self/service/metadata/plugins > ${PLUGINS_TXT}

if [ -n "$CUSTOM_KIBANA_LOOK_AND_FEEL" ]; then
  CUSTOM_KIBANA="/tmp/kibana.tar.gz"
  curl -Lsf ${CUSTOM_KIBANA_LOOK_AND_FEEL} > ${CUSTOM_KIBANA}
  echo "Curl ${CUSTOM_KIBANA_LOOK_AND_FEEL} finish ..."
  tar -xvzf ${CUSTOM_KIBANA} /usr/share/kibana/
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
