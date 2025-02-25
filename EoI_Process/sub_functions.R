############# check_inputs ----

check_inputs = function(directory, filename){

    file_path <- file.path(directory, 'Inputs',filename)

    # Check if the file exists
    if (!file.exists(file_path)) {
      stop(paste0("The file below does not exist in the directory you provided - check your inputs again!\n\n",
                  file_path))
    }

    # Check if the file is a CSV
    if (tools::file_ext(file_path) != "csv") {
      stop("The file is not a CSV.")
    }

    message(paste0("Found the file! Processing file: ",file_path))
  }

############# demo_match ----

demo_match = function(cEoI_df){
  demo_EoI <- read.csv('Demo_Inputs/EoI_Demo_B1.csv', header = TRUE)

  # Check if the number of columns is the same for cEoI_df and demo_EoI
  if (ncol(cEoI_df) != ncol(demo_EoI)) {
    stop("Comparing EoI to the demo EoI. \nNumber of columns does not match! Resolve before continuing.")
  } else {
    # Check if the column names are the same
    if (all(names(cEoI_df) == names(demo_EoI))) {
      message("Success! Comparing EoI to the demo EoI: the structure matches!")
    } else {
      stop("Comparing EoI to the demo EoI. \nThe column names do not match! Resolve before continuing.")
    }
  }

}

#############  val_1 ----

val_1 = function(cEoI_df){
  # Find the column indices for rows with partial name matches
  consent_col_indices <- grep("Please.tick.to", colnames(cEoI_df))
  # Identify the rows where any of the identified columns contain 'No' (partial match)
  rows_with_no_consent_indices <- apply(cEoI_df[, consent_col_indices], 1, function(row) any(grepl("No", row)))
  # Subset the dataframe to get the rows with 'No' consent
  cEoI_NoConsent <- cEoI_df[rows_with_no_consent_indices, , drop = FALSE]
  # Remove these rows from the original dataframe
  cEoI_Val1 <- cEoI_df[!rows_with_no_consent_indices, , drop = FALSE]

  list(cEoI_NoConsent = cEoI_NoConsent,
       cEoI_Val1 = cEoI_Val1)
}

#############  val_2 ----

val_2 = function(cEoI_directory,cEoI_csv_filename,cEoI_Val1){

  # Define the column names to check for duplicates on
  column_names <- c('Organisation.Name', 'Companies.House.Registration.no.', 'Website', 'Email.address')

  # List all files in the directory, excluding the reference csv (cEoI)
  EoI_list <- list.files(paste0(cEoI_directory, '/Inputs'))
  EoI_list <- EoI_list[EoI_list != cEoI_csv_filename]

  # Initialize a list to store past dataframes
  all_pEoI <- list()

  # Read each past file and store the dataframes in a list
  for (EoI_file in EoI_list) {
    message(paste0('Checking for duplicates in ',EoI_file,' on these columnns:'))
    print(column_names)
    # Read in the past EoI file
    pEoI <- read.csv(paste0(cEoI_directory, '/Inputs/', EoI_file), header = TRUE)
    all_pEoI[[EoI_file]] <- pEoI
    # Add a column to store the file name
    pEoI$EoI_file <- EoI_file
    all_pEoI[[EoI_file]] <- pEoI
  }

  # Combine all past dataframes into one
  combined_pEoI <- do.call(rbind, all_pEoI)

  # Extract the specified columns as a subset df
  subset_cEoI <- cEoI_Val1[, column_names, drop = FALSE]
  subset_combined_pEoI <- combined_pEoI[, column_names, drop = FALSE]

  # Function to check for duplicates excluding blanks, 'NA', and 'N/A'
  is_duplicate <- function(col) {
    col <- as.character(col)
    valid <- !(col == "" | col == "NA" | col == "N/A")
    duplicated(col[valid]) | duplicated(col[valid], fromLast = TRUE)
  }

  # Identify the duplicated rows within cEoI_Val1
  duplicated_within_cEoI <- apply(subset_cEoI, 2, is_duplicate)
  duplicated_within_cEoI <- apply(duplicated_within_cEoI, 1, any)

  # Identify the duplicated rows between cEoI_Val1 and combined_pEoI
  duplicated_between_cEoI_pEoI <- apply(subset_cEoI, 1, function(row) {
    any(apply(subset_combined_pEoI, 1, function(x) {
      any(x == row & !(x == "" | x == "NA" | x == "N/A"))
    }))
  })

  # Combine both conditions to find all duplicates in cEoI
  all_duplicated_rows <- duplicated_within_cEoI | duplicated_between_cEoI_pEoI

  # Find the row indices where cEoI has these duplicated values
  matching_indices <- which(all_duplicated_rows)

  # Create a new data frame with the matching rows
  cEoI_Duplicates <- cEoI_Val1[matching_indices, , drop = FALSE]

  # Add a new column to indicate the EoI file
  cEoI_Duplicates$EoI_file <- ifelse(duplicated_within_cEoI[matching_indices], cEoI_csv_filename, combined_pEoI$EoI_file[matching_indices])
  # Change the row name to indicate where the duplicate came from
  rownames(cEoI_Duplicates) <- paste(matching_indices, cEoI_Duplicates$EoI_file, sep = "_")
  # Remove the EoI_file column
  cEoI_Duplicates$EoI_file <- NULL

  # Remove the matching rows from the original cEoI dataframe
  if (length(matching_indices) != 0) {
    cEoI_Val12 <- cEoI_Val1[!all_duplicated_rows, , drop = FALSE]
  } else {
    cEoI_Val12 <- cEoI_Val1
  }

  list(cEoI_Duplicates = cEoI_Duplicates,
       cEoI_Val12 = cEoI_Val12)

}

#############  val_check ----

val_check = function(cEoI_Val12,cEoI_NoConsent,cEoI_Duplicates){

  # Calculate the number of rows across the 3 dataframes
  total_rows_split <- nrow(cEoI_Val12) + nrow(cEoI_NoConsent) + nrow(cEoI_Duplicates)

  # Calculate the number of rows in the original dataframe
  rows_cEoI <- nrow(cEoI)

  # Compare the sum to the number of rows in the original dataframe
  if (total_rows_split == rows_cEoI) {
    message("Great! The number of rows in the split dataframes adds up to the number of rows in the original dataframe.\n")
  } else {
    stop("Oh no! The number of rows in the split dataframes does NOT add up to the number of rows in the original dataframe.\n")
  }

}

#############  tidy_up ----

tidy_up = function (cEoI_df, cEoI_Val12, cEoI_Duplicates, cEoI_NoConsent) {
  # Create a list of the 3 dataframes we've created
  dataframes_list <- list(cEoI_Val12, cEoI_Duplicates, cEoI_NoConsent)

  for (i in seq_along(dataframes_list)) {
    cEoI_df <- dataframes_list[[i]]

    # a - Replace '.' with a space
    colnames(cEoI_df) <- gsub("\\.\\.", ",", colnames(cEoI_df))
    colnames(cEoI_df) <- gsub("\\.", " ", colnames(cEoI_df))

    # b - Rename some specific columns
    colnames(cEoI_df)[colnames(cEoI_df) == "Please choose which option best describes what sort of company or organisation is seeking support "] <- "Organisation Stage"
    colnames(cEoI_df)[colnames(cEoI_df) == "Agriculture and food processing"] <- "SECTOR: Agriculture & food processing"
    colnames(cEoI_df)[colnames(cEoI_df) == "Construction"] <- "SECTOR: Construction"
    colnames(cEoI_df)[colnames(cEoI_df) == "Creative Industries"] <- "SECTOR: Creative Industries"
    colnames(cEoI_df)[colnames(cEoI_df) == "Software technology development,AI ML "] <- "SECTOR: Software technology development (AI/ML)"
    colnames(cEoI_df)[colnames(cEoI_df) == "Transportation,including logistics and warehousing"] <- "SECTOR: Transportation, including logistics & warehousing"
    colnames(cEoI_df)[colnames(cEoI_df) == "Other,1 "] <- "SECTOR: Other"
    colnames(cEoI_df)[colnames(cEoI_df) == "Company culture,approach to innovation"] <- "BARRIER: Company culture, approach to innovation"
    colnames(cEoI_df)[colnames(cEoI_df) == "Data quality,data sharing and or data management issues"] <- "BARRIER: Data quality, sharing and/or management"
    colnames(cEoI_df)[colnames(cEoI_df) == "Costs and complexity"] <- "BARRIER: Costs & complexity"
    colnames(cEoI_df)[colnames(cEoI_df) == "Lack of strategy and clear objectives"] <- "BARRIER: Lack of strategy and clear objectives"
    colnames(cEoI_df)[colnames(cEoI_df) == "Ethical,regulatory and compliance"] <- "BARRIER: Ethical, regulatory & compliance"
    colnames(cEoI_df)[colnames(cEoI_df) == "Process deficiencies and storage"] <- "BARRIER: Process deficiencies & storage"
    colnames(cEoI_df)[colnames(cEoI_df) == "Other,2 "] <- "BARRIER: Other"
    colnames(cEoI_df)[colnames(cEoI_df) == "Data scientists"] <- "CURRENT: Data scientists"
    colnames(cEoI_df)[colnames(cEoI_df) == "Machine learning experts"] <- "CURRENT: Machine learning experts"
    colnames(cEoI_df)[colnames(cEoI_df) == "Software engineers"] <- "CURRENT: Software engineers"
    colnames(cEoI_df)[colnames(cEoI_df) == "Data engineers"] <- "CURRENT: Data engineers"
    colnames(cEoI_df)[colnames(cEoI_df) == "Data analysts"] <- "CURRENT: Data analysts"
    colnames(cEoI_df)[colnames(cEoI_df) == "Statisticians"] <- "CURRENT: Statisticians"

    # c - add in some new (empty) columns
    new_column_names <- c('Fit to BridgeAI - Y/N/Maybe',
                          'Fit to Turing offerings - Y/N/Maybe',
                          'Suitability - ISA - Y/N/Maybe',
                          'Rationale',
                          'Suggested way forward',
                          'Notes',
                          'Partnerships contact (to provide 2nd opinion / further qualification)',
                          'Additional notes',
                          'Category',
                          'Mapping to ISA Lead (initial)')

    # c - add new columns to the data frame
    for (column_name in new_column_names) {
      if (nrow(cEoI_df) == 0) {
        cEoI_df[[column_name]] <- character()  # Initialize with an empty character vector
      } else {
        cEoI_df[[column_name]] <- 'TO FILL'  # Initialize with the default value
      }
    }

    # d - remove some columns from the data frame
    consent_col_indices <- grep("Please.tick.to", colnames(cEoI_df))
    cols_to_remove <- c("ID", "Date","IP Address","URL","User Agent")
    cols_to_remove_combined <- c(which(names(cEoI_df) %in% cols_to_remove), consent_col_indices)
    cEoI_df <- cEoI_df[, -cols_to_remove_combined]

    # Update the dataframe in the list, with the above changes
    dataframes_list[[i]] <- cEoI_df
  }

  # Extract the modified dataframes back to their original variables
  cEoI_Val12 <- dataframes_list[[1]]
  cEoI_Duplicates <- dataframes_list[[2]]
  cEoI_NoConsent <- dataframes_list[[3]]

  list(cEoI_df = cEoI_df,
       cEoI_Val12 = cEoI_Val12,
       cEoI_Duplicates = cEoI_Duplicates,
       cEoI_NoConsent = cEoI_NoConsent)

}

#############  save_to_excel ----

save_to_excel = function(raw_cEoI,cEoI_Val12,cEoI_NoConsent,cEoI_Duplicates,
                         cEoI_csv_filename,output_dir){

  # Load specific library needed for this code chunk
  library(openxlsx)

  # Transpose the dataframe (this means turn columns into rows)
  cEoI_T <- as.data.frame(t(raw_cEoI))
  colnames(cEoI_T) <- NULL
  cEoI_Val12_T <- as.data.frame(t(cEoI_Val12))
  cEoI_NoConsent_T <- as.data.frame(t(cEoI_NoConsent))
  cEoI_Duplicates_T <- as.data.frame(t(cEoI_Duplicates))

  # Create a new workbook
  wb <- createWorkbook()

  # Define a list of worksheet names and corresponding data frames
  worksheets <- list(
    "Raw" = cEoI_T,
    "Validated" = cEoI_Val12_T,
    "NoConsent" = cEoI_NoConsent_T,
    "Duplicates" = cEoI_Duplicates_T
  )

  # Create a bold text & shaded style
  BorderStyle <- createStyle(
    fgFill = "#F0F0F0",
    wrapText = TRUE,
    border = "TopBottomLeftRight",
    halign = "left"
  )

  NonBorderStyle <- createStyle(
    halign = "left"
  )

  # Add worksheets, write dataframes to them, and apply styles
  for (sheet_name in names(worksheets)) {
    data <- worksheets[[sheet_name]]

    # Add worksheet
    addWorksheet(wb, sheet_name)

    # Write data to worksheet
    writeData(wb, sheet_name, data, rowNames = TRUE)

    # Apply BorderStyle style to the first row
    addStyle(wb, sheet_name, style = BorderStyle, rows = 1, cols = 1:ncol(data) + 1, gridExpand = TRUE)
    # Apply BorderStyle to the first column
    addStyle(wb, sheet_name, style = BorderStyle, rows = 1:(nrow(data) + 1), cols = 1, gridExpand = TRUE)
    # Set non-BorderStyle to all other rows and columns
    addStyle(wb, sheet_name, style = NonBorderStyle, rows = 2:nrow(data) + 1, cols = 2:ncol(data) + 1, gridExpand = TRUE)
    # Set the width of the first column
    setColWidths(wb, sheet_name, cols = 1, widths = 30)  # Adjust the width as needed
  }

  # Save the workbook
  in_filename <- tools::file_path_sans_ext(basename(cEoI_csv_filename)) # Extract the file name without extension
  out_filename <- file.path(paste0(in_filename, "_formatted.xlsx")) # Construct the output file path with the new extension
  saveWorkbook(wb, paste0(output_dir,'/',out_filename), overwrite = TRUE)
  message(paste0('Output file has been saved here:\n\n',output_dir,'/',out_filename))
}



