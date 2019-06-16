# helper functions and variables to be loaded with the package
base_url <- "http://www.prarulebook.co.uk"

### Helper functions for structure scraper (get_structure.R) ###
# sectors
scrape_sectors_structure <- function() {
  cat("--- Scraping SECTORS ---")
  cat("\n")
  sectors <- scrape_menu(top_url, ".nav-child a")
  colnames(sectors) <- c("sector_name", "sector_url", "rulebook_url")
  return(sectors)
}

# parts
scrape_parts_structure <- function() {
  cat("\n")
  cat("--- Scraping PARTS ---")
  cat("\n")
  parts <- lapply(sectors$sector_url, scrape_menu, selector = ".Part a")
  parts <- dplyr::bind_rows(parts)
  colnames(parts) <- c("part_name", "part_url", "sector_url")
  # clean the part names
  parts$part_name <- trimws(parts$part_name)

  # join sector names to 'parts'
  parts_sectors <- dplyr::left_join(parts, sectors)
  return(parts_sectors)
}

### END structure scrapers ###

