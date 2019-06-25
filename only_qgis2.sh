#!/bin/bash
set -e
echo "Welcome to ODM docker."
WORKSPACE=$1


docker run --name qgis_example_hub -v $WORKSPACE/:/workspace nuest/docker-qgis-model:trusty
docker cp qgis_example_hub:/workspace/results QGIS_results
tree QGIS_results
docker rm qgis_example_hub