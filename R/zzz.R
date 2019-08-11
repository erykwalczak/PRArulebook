# helper functions
#' @importFrom httr GET
#' @importFrom httr warn_for_status
#' @importFrom httr status_code
#'
extract_results <- function(x) {
  httr::warn_for_status(x)
  # if response is correct then return the page
  if (httr::status_code(x) == 200) {
    return(x)
  }
  # otherwise display the page and status code
  else {
    print(x)
    return(NULL)
  }
}
# to use in 'get_content()'
# TODO reorder to speed up checks
assign_link_type <- function(x) {
  ifelse(is.na(x), NA,
         ifelse(grepl("Content/Part", x), "Part",
                ifelse(grepl("Content/Chapter", x), "Chapter",
                       ifelse(grepl("Content/Rule", x), "Rule",
                              ifelse(grepl("Content/Sector", x), "Sector",
                                     ifelse(grepl("LegalInstrument", x), "Legal",
                                            ifelse(grepl("/Glossary", x), "Glossary",
                                                   "Other")))))))
}
