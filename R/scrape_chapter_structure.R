#' Scrape chapter structure
#'
#' @param df Data frame with part URLs. Output of \code{"scrape_part_structure"}.
#'
#' @return Data frame with scraped chapter structure.
#'
#' @examples
scrape_chapter_structure <- function(df) {
  cat("--- Scraping CHAPTERS ---")
  cat("\n")

  chapters <- lapply(df[["part_url"]], scrape_menu, selector = ".Chapter a")
  chapters <- dplyr::bind_rows(chapters)
  colnames(chapters) <- c("chapter_name", "chapter_url", "part_url")

  # clean the chapter names
  chapters$chapter_name <- gsub("[\r\n]", " ", chapters$chapter_name)
  chapters$chapter_name <- trimws(gsub("\\s+", " ", chapters$chapter_name))

  # join chapters to parts and sectors
  chapters_parts_sectors <-
    dplyr::left_join(chapters, df, by = "part_url")

  return(chapters_parts_sectors)
}
