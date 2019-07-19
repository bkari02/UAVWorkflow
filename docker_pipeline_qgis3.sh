#!/bin/bash
set -e
echo "Welcome to ODM docker."

# Get input parameters and create variables
PICTURE_SOURCE_DIR=$1
RESULT_DIR=$2


# Change directory to result directory
cd $RESULT_DIR

#Create results folder and workspace folder
echo "Creating temporary workspace directory..."
mkdir -p "results"
mkdir -p "working_dir"
mkdir -p "working_dir/images"

# Copy input images into folder called "images" to safecase docker process
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

# Create subfolder for ODM results
mkdir "results/$CURRENT_DATE_TIME/ODM"

# Move results from workspace to result folder of ODM
mv -i "working_dir/odm_orthophoto" "results/$CURRENT_DATE_TIME/ODM"
mv -i "working_dir/odm_georeferencing" "results/$CURRENT_DATE_TIME/ODM"
mv -i "working_dir/odm_meshing" "results/$CURRENT_DATE_TIME/ODM"
mv -i "working_dir/odm_texturing" "results/$CURRENT_DATE_TIME/ODM"

# Remove workspace 
rm -R "working_dir"

# Create result folder for QGIS outputs
mkdir -p "results/$CURRENT_DATE_TIME/QGIS"

# Run QGIS3 Docker and provide orthophoto as input 
docker run --name test_qgis3_model -it --rm -v "$PWD/results/odm_orthophoto":/data/input -v "$PWD/results/$CURRENT_DATE_TIME/QGIS":/data/output  ismailsunni/qgis3-model /bin/bash start.sh 'odm_orthophoto.tif' 'odm_orthophoto.tif'

# Delete docker container
docker rm test_qgis3_model

echo "--------------------------- FINISHED ------------------------------------------------"
echo "Automated Workflow for UAV Image Processing has finished. Find your results in the directory you provided as input."
echo "There is a folder in results directory that is name $CURRENT_DATE_TIME with the following folder structure:"
cd results/$CURRENT_DATE_TIME
find .