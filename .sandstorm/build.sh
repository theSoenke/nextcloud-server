#!/bin/bash

set -euo pipefail

cd /opt/app
git submodule update --init

# link data and config folder
rm -rf /opt/app/data
rm -rf /var/data
rm -rf /opt/app/config
rm -rf /var/config
rm -rf /opt/app/apps
rm -rf /var/apps
ln -s /var/data /opt/app/data
ln -s /var/config /opt/app/config
ln -s /var/apps /opt/app/apps
