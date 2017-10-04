#!/usr/bin/env bash
set -e

RANCHER_BASEURL="rancher-metadata.rancher.internal/latest"


echo "Installing plugins..."
PLUGINS_TXT="/tmp/plugins.txt"
curl -sf ${RANCHER_BASEURL}/self/service/metadata/plugins > ${PLUGINS_TXT}

if [ -f "$PLUGINS_TXT" ]; then
  for plugin in $(<"${PLUGINS_TXT}"); do
    echo "Installing $plugin"
    /usr/share/kibana/bin/kibana-plugin install $plugin
  done
fi

/usr/local/bin/kibana-docker
