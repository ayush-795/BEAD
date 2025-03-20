{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
\
# Load the conda module and activate the BEAD environment\
module load conda\
source activate bead_env\
\
# Define the workspace name (input data is shared across model runs)\
WORKSPACE="CSF_Workspace"\
\
# Define CSV source directory (adjust this path as needed)\
CSV_SOURCE="/path/to/csv_inputs"\
\
# Automatically move CSV input files to the expected location for the workspace.\
CSV_DEST="BEAD/bead/workspaces/$\{WORKSPACE\}/data/csv"\
echo "Ensuring CSV destination directory exists: $\{CSV_DEST\}"\
mkdir -p $\{CSV_DEST\}\
echo "Copying CSV files from $\{CSV_SOURCE\} to $\{CSV_DEST\}"\
cp $\{CSV_SOURCE\}/*.csv $\{CSV_DEST\}/\
\
# Define the list of NormFlow+ConvVAE model variants.\
# (Update these names according to BEAD documentation.)\
models=("NormFlow_ConvVAE_A" "NormFlow_ConvVAE_B" "NormFlow_ConvVAE_C")\
\
# Loop over each model variant.\
for model in "$\{models[@]\}"\
do\
    # Define a unique project name for this model run.\
    PROJECT="monotop_$\{model\}"\
    \
    # Create a new project within the workspace.\
    # This sets up the directory structure under BEAD/bead/workspaces/$\{WORKSPACE\}/$\{PROJECT\}\
    poetry run bead -m new_project -p $\{WORKSPACE\} $\{PROJECT\}\
    \
    # Auto-update the project's configuration file.\
    CONFIG_PATH="BEAD/bead/workspaces/$\{WORKSPACE\}/$\{PROJECT\}/config/$\{PROJECT\}_config.py"\
    echo "Updating config file for $\{PROJECT\}: $\{CONFIG_PATH\}"\
    sed -i 's/^\\s*c\\.epochs\\s*=.*/    c.epochs                       = 500/' $\{CONFIG_PATH\}\
    sed -i 's/^\\s*c\\.intermittent_model_saving\\s*=.*/    c.intermittent_model_saving    = True/' $\{CONFIG_PATH\}\
    sed -i 's/^\\s*c\\.intermittent_saving_patience\\s*=.*/    c.intermittent_saving_patience = 100/' $\{CONFIG_PATH\}\
    \
    # Train the model using the updated config settings.\
    # Process: monotop_200_A, Model: current NormFlow+ConvVAE variant.\
    poetry run bead -m train -p $\{WORKSPACE\} $\{PROJECT\} --process monotop_200_A --model $\{model\}\
    \
    # Run detection/inference on the trained model.\
    poetry run bead -m detect -p $\{WORKSPACE\} $\{PROJECT\}\
    \
    # Generate plots for the outputs.\
    poetry run bead -m plot -p $\{WORKSPACE\} $\{PROJECT\}\
done\
}