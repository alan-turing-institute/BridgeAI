# Process EoIs

## Introduction

The purpose of this work is to automate some manual data wrangling and validation steps that are often done when a new batch of EoIs are recieved. 
Another purpose is to create summary plots of current and previous EoIs, to summarise and visualise features of the companies that are submitting EoIs.

### Prerequisites to run this code:

 - Install `R` and `R Studio` on your computer (to interact with `R`)
 - Have access to EoI csv files (these are the input to this code)

### How to run this code:

Locally, download the files within this folder to your computer (or clone this GitHub repository).

- Edit lines in `EoI_Process_Inputs.R`
- Open up `EoI_Process.Rmd` and either
   - Press Run -> Run All
   - Run every code chunk invidually, to see each stage of processing
- After `EoI_Process.Rmd` has successfully run, you should have a new folder called 'EoI_x_formatted' with a formatted excel file and png plots   

## :warning: Important note about personal data 

No data should be stored on this GitHub repo! Just the code to process the data. 

This is an `R notebook` file, to make it more accessible to new comers. 
 `R notebook` files can contain outputs from running the code chunks. 
 
**Clear All Outputs** before uploading a new version to GitHub to make sure only the code (not the output of the code) is displayed. 

Make sure no outputs are present in the `.Rmd` file and the `.html` rendered file. 

<img width="896" alt="clear-outputs" src="https://github.com/user-attachments/assets/bc85f495-3b65-47c4-9861-9705b01bb10d">

## Description of what the `R` code does:
> - Coming soon

## People working on this
- Rachael Stickland (BridgeAI ISA and Turing employee)
- Alexandra Araujo Alvarez (BridgeAI Senior Research Community Manager)
> - Please add
