#' Scrape rule structure
#'
#' @param df Data frame with chapter URLs. Output of \code{"scrape_chapter_structure"}.
#'
#' @return Data frame with scraped rule structure.
#' @export
#'
#' @examples
#' \dontrun{
#' sectors <- scrape_sector_structure("http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007")
#' parts <- scrape_part_structure(sectors)
#' chapters <- scrape_chapter_structure(parts)
#' scrape_rule_structure(chapters)
#' }
scrape_rule_structure <- function(df) {
  cat("\n")
  cat("--- Scraping RULES ---")
  cat("\n")
  # get all rules and append to a data frame
  rules <-
    purrr::map_df(df[["chapter_url"]],
                  scrape_menu, selector = ".rule-number")
  # rename
  colnames(rules) <- c("rule_name", "rule_url", "chapter_url")

  # join chapters to parts and sectors
  rules_chapters_parts_sectors <-
    dplyr::left_join(rules, df,
                     by = "chapter_url")

  return(rules_chapters_parts_sectors)
}
