#' Scrape part structure
#'
#' @param df Data frame with sector URLs. Output of \code{"scrape_sector_structure"}.
#'
#' @return Data frame with scraped part structure.
#'
#' @examples
scrape_part_structure <- function(df) {
  cat("\n")
  cat("--- Scraping PARTS ---")
  cat("\n")
  parts <- lapply(df[["sector_url"]], scrape_menu, selector = ".Part a")
  parts <- dplyr::bind_rows(parts)
  colnames(parts) <- c("part_name", "part_url", "sector_url")
  # clean the part names
  parts$part_name <- trimws(parts$part_name)
  # join sector names to 'parts'
  parts_sectors <- dplyr::left_join(parts, df)
  return(parts_sectors)
}
