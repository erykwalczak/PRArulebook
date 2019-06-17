#' Scrape sector structure
#'
#' @param x String. Top URL.
#'
#' @return Data frame with scraped sector structure.
#'
#' @examples
scrape_sector_structure <- function(x) {
  cat("--- Scraping SECTORS ---")
  cat("\n")
  sectors <- scrape_menu(x, ".nav-child a")
  colnames(sectors) <- c("sector_name", "sector_url", "rulebook_url")
  return(sectors)
}
