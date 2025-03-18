{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
\
# Load and activate the BEAD environment via conda\
module load conda\
source activate bead_env\
\
# Define workspace and project names\
WORKSPACE="CSF_Workspace"\
PROJECT="monotop_planar"\
\
# Define CSV source directory (adjust this path as needed)\
CSV_SOURCE="/path/to/csv_inputs"\
\
# Step 1: Create new project structure\
poetry run bead -m new_project -p $\{WORKSPACE\} $\{PROJECT\}\
\
# Step 1.5: Move CSV input files automatically\
CSV_DEST="BEAD/bead/workspaces/$\{WORKSPACE\}/data/csv"\
mkdir -p $\{CSV_DEST\}\
cp $\{CSV_SOURCE\}/*.csv $\{CSV_DEST\}/\
\
# Step 2: Convert CSV files to the preferred format (default h5)\
poetry run bead -m convert_csv -p $\{WORKSPACE\} $\{PROJECT\}\
\
# Step 3: Preprocess inputs to generate tensor files (.pt)\
poetry run bead -m prepare_inputs -p $\{WORKSPACE\} $\{PROJECT\}\
\
# Step 4: Auto-update configuration file with training parameters\
CONFIG_PATH="BEAD/bead/workspaces/$\{WORKSPACE\}/$\{PROJECT\}/config/$\{PROJECT\}_config.py"\
echo "Updating config: $\{CONFIG_PATH\}"\
sed -i 's/^\\s*c\\.epochs\\s*=.*/    c.epochs                       = 500/' $\{CONFIG_PATH\}\
sed -i 's/^\\s*c\\.intermittent_model_saving\\s*=.*/    c.intermittent_model_saving    = True/' $\{CONFIG_PATH\}\
sed -i 's/^\\s*c\\.intermittent_saving_patience\\s*=.*/    c.intermittent_saving_patience = 100/' $\{CONFIG_PATH\}\
\
# Step 5: Train the model with updated config settings (500 epochs, save every 100 epochs)\
poetry run bead -m train -p $\{WORKSPACE\} $\{PROJECT\} --process monotop_200_A --model Planar_ConvVAE\
\
# Step 6: Run detection/inference on the trained model\
poetry run bead -m detect -p $\{WORKSPACE\} $\{PROJECT\}\
\
# Step 7: Generate all required plots from the outputs\
poetry run bead -m plot -p $\{WORKSPACE\} $\{PROJECT\}\
}