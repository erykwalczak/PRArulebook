# helper functions
#' @importFrom httr GET
#' @importFrom httr warn_for_status
#' @importFrom httr status_code
#' @importFrom xml2 read_html
extract_results <- function(x) {
  httr::warn_for_status(x)

  if (httr::status_code(x) == 200) {
    html_result <- xml2::read_html(x)
    return(html_result)
  }
}

# in get_content
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
