# Notebooks for data analysis and visualization

Here are two notebooks that help with the analysis and visualization of test results when deploying a new release of the Confluence workflow.

## data_check.ipynb

Determines if data is present at the specified reaches and plots time series of the discharge data that is present.

Usage:

1) Create a directory named data in this `notebooks` directory: `mkdir data`
2) Copy the priors (`na_sword_v16_SOS_priors.nc`) and results (`na_sword_v16_SOS_results.nc`) granules to the `data` directory
3) Execute the cells in the notebook

## data_visualize.ipynb

Visualizes mean discharge from each FLPE and MOI algorithm on a map.

Usage:

1) Create a directory named data in this `notebooks` directory: `mkdir data`
2) Copy the priors (`na_sword_v16_SOS_priors.nc`) and results (`na_sword_v16_SOS_results.nc`) granules to the `data` directory
3) Execute the cells in the notebook

## Set up and run Jupyterlab

The `setup.sh` and `run.sh` script will help you get set up to run Jupyterlab and execute the notebooks.

### `setup.sh`

This scripts creates a virtual environment to install Juptyerlab and the Python dependencies for running the notebook.

Before running this script, make sure to set up a directory where a virtual environment can be created. For example: `/Users/username/Documents/environments/jupyter`

To run the script pass the directory you created as the first command line argument:

`./setup.sh /Users/username/Documents/environments/jupyter`

### `run.sh`

This scripts runs Jupyterlab which allows you to display and execute the notebooks.

To run the script pass the directory you created from the setup script as the first command line argument:

`./run.sh /Users/username/Documents/environments/jupyter`

You can press `ctrl+c` in the terminal you ran this commannd in to exit out of the Jupyterlab environment.
