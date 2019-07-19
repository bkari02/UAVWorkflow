#!/bin/bash
set -e
echo "Welcome to ODM docker."

# Get input parameters and create variables
PICTURE_SOURCE_DIR=$1
RESULT_DIR=$2
MODEL_PATH=$3
MODEL_PYTHON_PATH=$4

# Change directory to result directory
cd $RESULT_DIR

# Create results folder and workspace folder
mkdir -p "results"
mkdir -p "working_dir"
mkdir -p "working_dir/images"

# Copy input images into folder called "images" to safecase docker
cp -R "$PICTURE_SOURCE_DIR/." "working_dir/images"

# Create output folders for temp docker results 
# -p options to avoid errors if folders are already existing
mkdir -p "working_dir/odm_orthophoto"
mkdir -p "working_dir/odm_georeferencing"
mkdir -p "working_dir/odm_meshing"
mkdir -p "working_dir/odm_texturing"

# Run ODM Docker
echo "ODM Docker will be executed."
docker run -it --rm -v "$RESULT_DIR/working_dir/images:/code/images" -v "$RESULT_DIR/working_dir/odm_georeferencing:/code/odm_georeferencing" -v "$RESULT_DIR/working_dir/odm_meshing:/code/odm_meshing"  -v "$RESULT_DIR/working_dir/odm_orthophoto:/code/odm_orthophoto" -v "$RESULT_DIR/working_dir/odm_texturing:/code/odm_texturing" opendronemap/odm

echo "ODM Docker finished. Forwarding results to QGIS for further processing."

# Create folder for odm_orthophoto forwarding and copy orthophoto into it
mkdir -p "results/odm_orthophoto"
cp -r "working_dir/odm_orthophoto/odm_orthophoto.tif" "results/odm_orthophoto/"

# Store current date and time in a variable for unique folder naming
CURRENT_DATE_TIME=$( date '+%F_%H:%M:%S' )

# Create folder with date/time as name to avoid overwriting older results
mkdir "results/$CURRENT_DATE_TIME"

# Move results from workspace to result folder of ODM
mv -i "working_dir/odm_orthophoto" "results/$CURRENT_DATE_TIME"
mv -i "working_dir/odm_georeferencing" "results/$CURRENT_DATE_TIME"
mv -i "working_dir/odm_meshing" "results/$CURRENT_DATE_TIME"
mv -i "working_dir/odm_texturing" "results/$CURRENT_DATE_TIME"

# Remove workspace 
rm -R "working_dir"

# Create workspace folder for QGIS 
mkdir "results/QGIS"

# Copy orthophoto to workspace folder
cp "results/odm_orthophoto/odm_orthophoto.tif" "results/QGIS/Ortho-DroneMapper.tif"

# Copy python model to workspace folder
cp  $MODEL_PYTHON_PATH "results/QGIS/"

# Change directory to workspace folder
cd "results/QGIS"

# Create folder for model
mkdir "models"

# Copy model to workspace folder
cp $MODEL_PATH "models/"

# Create result folder for QGIS 
mkdir -p "QGIS_results"

docker run --name qgis_example_hub -v $PWD/:/workspace nuest/docker-qgis-model:trusty
docker cp qgis_example_hub:/workspace/results QGIS_results

# Delete docker container
docker rm qgis_example_hub

#Move results to result folder
mv -i "QGIS_results" "results/$CURRENT_DATE_TIME"
  
echo "--------------------------- FINISHED ------------------------------------------------"
echo "Automated Workflow for UAV Image Processing has finished. Find your results in the directory you provided as input."
echo "There is a folder in results directory that is name $CURRENT_DATE_TIME with the following folder structure:"
cd "$RESULT_DIR/result/$CURRENT_DATE_TIME"
find .