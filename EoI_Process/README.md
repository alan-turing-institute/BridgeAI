# Process EoIs

## Introduction

The purpose of this work is to automate some manual data wrangling and validation steps that are often done when a new batch of EoIs are received. 
Another purpose is to create summary plots of current and previous EoIs, to summarise and visualise features of the companies that are submitting EoIs.

### Prerequisites to run this code:

 - Install `R` and `R Studio` on your computer (to interact with `R`)
 - Have access to EoI csv files (these are the input to this code)

### How to run this code:

Locally, download the files within this folder to your computer (or clone this GitHub repository).

- Put the EoI csv files into a folder called 'Inputs'
- Make an empty folder called 'Outputs'
- Open up [EoI_Process.Rmd](EoI_Process.Rmd) in R Studio and:
   - Change location of your 'Inputs' folder and csv file name (Step 1)
   - Press *Run -> Run All* or run every code chunk individually, to see each stage of processing
- After [EoI_Process.Rmd](EoI_Process.Rmd) has successfully run, you should have a new folder in Outputs called 'OUTPUTS_EoIname' with a formatted excel file and png plots 

## :warning: Important note about personal data 

No data should be stored on this GitHub repo! Just the code to process the data. 

This is an `R notebook` file, to make it more accessible to new comers. 
 `R notebook` files can contain outputs from running the code chunks. 
 
**Clear All Outputs** before uploading a new version to GitHub to make sure only the code (not the output of the code) is displayed. 

Make sure no outputs are present in the `.Rmd` file and the `.html` rendered file. 

<img width="896" alt="clear-outputs" src="https://github.com/user-attachments/assets/bc85f495-3b65-47c4-9861-9705b01bb10d">

Note, GitHub does not display the html file nicely if you click on it :( - download and open in your browser. 

## Description of what the `R` code does:
> - Coming soon

## Features to implement soon:
- When reading in the EoI, check the formatting matches a demo format (we are assuming all bathes are the same as batch 7)
- Check for duplicates across previous batches (by looping through the 'Inputs' directory - note which batch the duplicate is in, if found)
- Create the plots for all batches, not just one batch

## Features to consider later:
- When checking for duplicates, do partial name matches
- Can we pre-match companies to ISAs in some sort automated way - based on some key words matches - can AI help? 

## People working on this
- Rachael Stickland (BridgeAI ISA and Turing employee)
- Alexandra Araujo Alvarez (BridgeAI Senior Research Community Manager)
- Punita Maisuria 
> - Please add
