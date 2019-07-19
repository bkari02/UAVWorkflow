# UAVWorkflow
UAV Image Processing Automated Workflow

The automated workflow for usage on macOS and Linux operating systems is implemented within a Bash script. The commands to run the script form the command line are presented here:

```arduino 
cd [PATH_TO_SCRIPT_DIR] 
chmod +x UAS_Workflow.sh
./UAS_Workflow.sh [PATH_TO_INPUT_IMAGES_DIR] [PATH_TO_RESULT_DIR]
```

The first command changes the current directory of command line to the directory where the script is located. Therefore, the path needs to be specified according to the users particular device. The second line is only necessary once before the first execution of the script file.

It allows executing the script file as a program. Finally the third line executes the script. As previously mentioned, path to input images and result path are required as parameters. For detailed information on the execution commands within the script comments can be found in the script file.
