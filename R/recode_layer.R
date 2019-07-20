#' Recode layer of the rulebook
#'
#' @param from Source layer. Rule, chapter, part, sector.
#' @param to Target layer. Rule, chapter, part, sector.
#' @param structure_file Data frame. Output of \code{"get_structure"}.
#'
#' @return Data frame with recoded layers.
#' @export
#'
#' @examples
#' \dontrun{
#' rulebook_structure <- get_structure("16-11-2017")
#' recode_layer("http://www.prarulebook.co.uk/rulebook/Content/Chapter/211140/16-11-2017",
#' to = "all", structure_file = rulebook_structure)
#' }
recode_layer <- function(from, to = "all", structure_file) {

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

  from_type <- assign_link_type(from)
  from_type_url <- ifelse(from_type == "Sector", "sector_url",
                          ifelse(from_type == "Part", "part_url",
                                 ifelse(from_type == "Chapter", "chapter_url",
                                        ifelse(from_type == "Rule", "rule_url",
                                               stop("Incorrect URL")))))

  from_df <- data.frame(from, stringsAsFactors = FALSE)
  colnames(from_df) <- from_type_url

  # or find in data.frame if faster ???

  if (to == "all") {
    joined_layers <-
      dplyr::left_join(from_df, structure_file)
  } else {
    to_column <- "sector_url"
    joined_layers <-
      dplyr::left_join(from, structure_file[[c(from_column, to_column)]])
  }

  return(joined_layers)
  # TODO throw warnings
}
