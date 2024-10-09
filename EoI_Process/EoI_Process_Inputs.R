# Define inputs needed for EoI_Process.Rmd

# PLEASE CHANGE ME - the path that contains the EoI you want to process
cEoI_csv_directory <- "~/Documents/BridgeAI_EoI" 
# PLEASE CHANGE ME - the file name of the EoI you want to process
cEoI_csv_filename <- "EoI_Oct2024.csv" 

# Past EoIs currently not used in the code yet, but we will want to use them eventually
# pEoI_csv_directory <- "path" # the path that contains all past (p) EoI(s) 
# pEoI_csv_basename <- "EoI_past_" # the start of the filenames all the past (p) EoIs(s)

# Install necessary packages in your R software

# Define a function to check if a package is installed - install if not
install_if_missing <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package, dependencies = TRUE)
  }
}
packages <- c("dplyr", "tidyverse", "ggplot2", "openxlsx")
for (pkg in packages) {
  install_if_missing(pkg)
}




