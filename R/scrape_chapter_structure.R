#' Scrape chapter structure
#'
#' @param df Data frame with part URLs. Output of \code{"scrape_part_structure"}.
#'
#' @return Data frame with scraped chapter structure.
#' @export
#'
#' @examples
#' \dontrun{
#' sectors <- scrape_sector_structure("http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007")
#' parts <- scrape_part_structure(sectors)
#' scrape_chapter_structure(parts)
#' }
scrape_chapter_structure <- function(df) {
  cat("\n")
  cat("--- Scraping CHAPTERS ---")
  cat("\n")
  # get all chapters and append to a data frame
  chapters <-
    purrr::map_df(df[["part_url"]],
                  scrape_menu, selector = ".Chapter a")

  colnames(chapters) <- c("chapter_name", "chapter_url", "part_url")

  # clean the chapter names
  chapters$chapter_name <- gsub("[\r\n]", " ", chapters$chapter_name)
  chapters$chapter_name <- trimws(gsub("\\s+", " ", chapters$chapter_name))

  # deleted chapters are still scraped - remove them
  # e.g. comment out the filter line below to see NAs included
  # chapters_test <- get_structure("16-11-2007", layer = "chapter")
  # chapters_test$chapter_url[90:92]
  chapters <- chapters %>% dplyr::filter(!is.na(chapter_url))

  # join chapters to parts and sectors
  chapters_parts_sectors <-
    dplyr::left_join(chapters, df, by = "part_url")

  return(chapters_parts_sectors)
}
