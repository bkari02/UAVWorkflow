#!/bin/bash
set -e
echo "Welcome to ODM docker."
cd $1
echo $PWD
mkdir -p QGIS_results/$CURRENT_DATE_TIME

docker run --name test_qgis3_model -it --rm -v $PWD:/data/input -v "$PWD/QGIS_results/$CURRENT_DATE_TIME":/data/output  ismailsunni/qgis3-model /bin/bash start.sh 'odm_orthophoto.tif' 'Ortho-DroneMapper_ndvi.tif'
