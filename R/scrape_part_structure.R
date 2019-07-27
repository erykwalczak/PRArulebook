#' Scrape part structure
#'
#' @param df Data frame with sector URLs. Output of \code{"scrape_sector_structure"}.
#'
#' @return Data frame with scraped part structure.
#' @export
#'
#' @examples
#' \dontrun{
#' sectors <- scrape_sector_structure("http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007")
#' scrape_part_structure(sectors)
#' }
scrape_part_structure <- function(df) {
  cat("--- Scraping PARTS ---")
  cat("\n")
  # get all parts and append to a data frame
  parts <-
    purrr::map_df(df[["sector_url"]],
                  scrape_menu, selector = ".Part a")

  colnames(parts) <- c("part_name", "part_url", "sector_url")
  # clean the part names
  parts$part_name <- trimws(parts$part_name)
  # join sector names to 'parts'
  parts_sectors <-
    dplyr::left_join(parts, df, by = "sector_url")
  return(parts_sectors)
}
