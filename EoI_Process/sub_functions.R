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
  demo_EoI <- read.csv('Demo/Inputs/EoI_Demo_B1.csv', header = TRUE)

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

val_1 <- function(cEoI_df) {

  # Find the column indices for rows with partial name matches
  consent_col_indices <- grep("Please.tick.to", colnames(cEoI_df))
  # Identify the rows where any of the identified columns contain 'No' (partial match)
  rows_with_no_consent_indices <<- apply(cEoI_df[, consent_col_indices], 1, function(row) any(grepl("No", row)))

  # Initialize an empty data frame to store the message
  consent_message <- data.frame(message = character(), stringsAsFactors = FALSE)

  # Check if all elements are FALSE
  if (all(!rows_with_no_consent_indices)) {
    message_text <- "Consent boxes ticked for all companies."
  } else {
    # Extract the indices and names of companies that did not tick all consent boxes
    companies_with_no_consent <- which(rows_with_no_consent_indices)
    company_names <- cEoI_df$Organisation.Name[companies_with_no_consent]
    company_info <- paste(companies_with_no_consent, " (", company_names, ")", sep = "", collapse = ", ")
    message_text <- paste("Warning! These companies (", company_info, ") did not tick all the consent boxes. Please check!", sep = "")
  }

  # Store the message in the data frame
  consent_message <- rbind(consent_message, data.frame(message = message_text, stringsAsFactors = FALSE))

  # Print the message
  message(consent_message$message)

  consent_message
}

#############  val_2 ----

val_2 <- function(cEoI_directory, cEoI_csv_filename) {
  # Define the column names to check for duplicates on
  column_names <- c('Organisation.Name', 'Companies.House.Registration.no.', 'Website', 'Email.address')

  # List all files in the directory, excluding the reference csv (cEoI)
  EoI_list <- list.files(paste0(cEoI_directory, '/Inputs'))

  # Initialize a list to store past dataframes
  all_EoI <- list()

  # Read each past file and store the dataframes in a list
  for (EoI_file in EoI_list) {
    # Read in the past EoI file
    EoI <- read.csv(paste0(cEoI_directory, '/Inputs/', EoI_file), header = TRUE)
    # Add columns to store the file name and original row number
    EoI$EoI_file <- EoI_file
    EoI$EoI_row <- seq_len(nrow(EoI))
    all_EoI[[EoI_file]] <- EoI
  }

  # Combine all past dataframes into one without using row names
  combined_EoI <- do.call(rbind, all_EoI)
  rownames(combined_EoI) <- NULL

  # Initialize an empty data frame to store messages
  duplicate_message <- data.frame(message = character(), stringsAsFactors = FALSE)

  # Loop through each column in combined_EoI
  for (column in column_names) {
    # Get the column data
    col_subset <- combined_EoI[, c(column, 'EoI_file', 'EoI_row')]

    # Check for blank or NaN values and print a statement
    blank_or_nan_indices <- which(is.na(col_subset) | col_subset == "" | col_subset == "N/A")
    if (length(blank_or_nan_indices) > 0) {
      for (index in blank_or_nan_indices) {
        message <- paste0("\n[Blank] or [NA] or [N/A] found in [", col_subset$EoI_file[index], "] on column [", column, "]")
        # Add the message to the data frame
        duplicate_message <- rbind(duplicate_message, data.frame(message = message, stringsAsFactors = FALSE))
      }
    }

    # Remove blank, N/A, and NA values
    col_subset <- col_subset[!(is.na(col_subset[[column]]) | col_subset[[column]] == "N/A" | col_subset[[column]] == ""), ]

    # Find duplicates
    duplicate_indices <- which(duplicated(col_subset[[column]]) | duplicated(col_subset[[column]], fromLast = TRUE))

    if (length(duplicate_indices) != 0) {
      for (index in duplicate_indices) {
        duplicate_value <- col_subset[[column]][index]
        duplicate_rows <- which(col_subset[[column]] == duplicate_value)
        if (length(duplicate_rows) > 1) {
          duplicate_files <- col_subset$EoI_file[duplicate_rows]
          message <- paste0("\nDuplicate found for [", paste(duplicate_files, collapse = " and "),
                            "] on column [", column, "]: ", duplicate_value)
          # Add the message to the data frame
          duplicate_message <- rbind(duplicate_message, data.frame(message = message, stringsAsFactors = FALSE))
        }
      }

      # Remove duplicate messages
      duplicate_message <- unique(duplicate_message)
    }
  }

  # Print all unique messages
  message(duplicate_message$message)

  return(duplicate_message)
}
#############  tidy_up ----

tidy_up <- function(cEoI_df) {
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
  cols_to_remove <- c("ID", "Date", "IP Address", "URL", "User Agent")
  cols_to_remove_combined <- c(which(names(cEoI_df) %in% cols_to_remove), consent_col_indices)
  cEoI_df <- cEoI_df[, -cols_to_remove_combined]

  return(cEoI_df)
}

#############  save_to_excel ----

save_to_excel = function(raw_cEoI,tidy_cEoI,all_messages,cEoI_csv_filename,output_dir){

  # Load specific library needed for this code chunk
  library(openxlsx)

  # Transpose the tidy dataframe (this means turn columns into rows)
  tidy_cEoI_T <- as.data.frame(t(tidy_cEoI))

  # Rename the column headers to be sequential numbers
  colnames(tidy_cEoI_T) <- seq_len(ncol(tidy_cEoI_T))

  # Create a new workbook
  wb <- createWorkbook()

  # Define a list of worksheet names and corresponding data frames
  worksheets <- list(
    "Raw" = raw_cEoI,
    "Formatted" = tidy_cEoI_T,
    "Messages" = all_messages
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

  # Add worksheets and write dataframes to them
  for (sheet_name in names(worksheets)) {
    data <- worksheets[[sheet_name]]

    # Add worksheet
    addWorksheet(wb, sheet_name)

    # Write data to worksheet
    if (sheet_name == "Messages") {
      writeData(wb, sheet_name, data, rowNames = FALSE, colNames = FALSE)
    } else {
      writeData(wb, sheet_name, data, rowNames = TRUE)
    }
  }


  # Formatted tab: Apply BorderStyle style to the first row
  addStyle(wb, 'Formatted', style = BorderStyle, rows = 1, cols = 1:ncol(tidy_cEoI_T) + 1, gridExpand = TRUE)
  # Formatted tab: Apply BorderStyle to the first column
  addStyle(wb, 'Formatted', style = BorderStyle, rows = 1:(nrow(tidy_cEoI_T) + 1), cols = 1, gridExpand = TRUE)
  # Formatted tab: Set non-BorderStyle to all other rows and columns
  addStyle(wb, 'Formatted', style = NonBorderStyle, rows = 2:nrow(tidy_cEoI_T) + 1, cols = 2:ncol(tidy_cEoI_T) + 1, gridExpand = TRUE)
  # Formatted tab: Set the width of the first column
  setColWidths(wb, 'Formatted', cols = 1, widths = 30)  # Adjust the width as needed

  # Save the workbook
  in_filename <- tools::file_path_sans_ext(basename(cEoI_csv_filename)) # Extract the file name without extension
  out_filename <- file.path(paste0(in_filename, "_formatted.xlsx")) # Construct the output file path with the new extension
  saveWorkbook(wb, paste0(output_dir,'/',out_filename), overwrite = TRUE)
  message(paste0('Output file has been saved here:\n\n',output_dir,'/',out_filename))
}



