#' Scrape sector structure
#'
#' @param x String. Top URL.
#'
#' @return Data frame with scraped sector structure.
#' @export
#'
#' @examples
#' \dontrun{
#' scrape_sector_structure("http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007")
#' }
scrape_sector_structure <- function(x) {
  cat("--- Scraping SECTORS ---")
  cat("\n")
  sectors <- scrape_menu(x, ".nav-child a")
  colnames(sectors) <- c("sector_name", "sector_url", "rulebook_url")
  return(sectors)
}
