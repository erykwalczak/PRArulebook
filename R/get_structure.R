#' Scrape the Rulebook structure
#'
#' High-level function to scrape the rulebook structure.
#'
#' @param date Date of the rulebook. Use dd-mm-yyyy format.
#' @param layer Text. Can be: all (default), sector, part, chapter, or rule.
#'
#' @return Data frame with the rulebook structure.
#' @export
#'
#' @examples
#' \dontrun{
#' get_structure("16-11-2007")
#' get_structure("16-11-2007", layer = "sector")
#' get_structure("16-11-2007", layer = "part")
#' get_structure("16-11-2007", layer = "chapter")
#' }
get_structure <- function(date, layer = "chapter") {
  # assign the error message
  date_error_message <- "Provide a correct date in dd-mm-yyyy format. From '01-01-2005' till today."

  # check the arguments
  if (missing(date)) {
    stop(date_error_message)
  }

  # validate the input format
  #library(lubridate) # TODO suppress messages
  # TODO: import functions from packages
  if (!lubridate::is.Date(as.Date(date, format = "%d-%m-%Y"))) {
    stop(date_error_message)
  }

  # validate type
  if (!(layer %in% c("rule", "chapter", "part", "sector"))) {
    stop("Provide a layer to scrape. Available options: rule, chapter, part, sector.")
  }

  # full URL example: http://www.prarulebook.co.uk/rulebook/Content/Part/216145/16-11-2007
  # home: http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007

  # check date - if lower than x then change '/rulebook' to '/handbook'
  # first date of 'Rulebook': http://www.prarulebook.co.uk/rulebook/Home/Rulebook/29-08-2015
  cutoff_date <- as.Date("29-08-2015", format = "%d-%m-%Y")
  date_date <- as.Date(date, format = "%d-%m-%Y")

  #regulation_type <-
  if (date_date < cutoff_date) {
    rule_type <- "Handbook"
  }
  if (date_date >= cutoff_date) {
    rule_type <- "Rulebook"
  }

  # validate available date ranges
  # first version of the handbook in the current form
  oldest_handbook <- as.Date("01-01-2005", format = "%d-%m-%Y")
  # today's date
  latest_handbook <- as.Date(Sys.Date(), format = "%d-%m-%Y")
  #
  if (date_date < oldest_handbook | date_date > latest_handbook) {
    stop(date_error_message)
  }

  # message
  cat(paste("You are requesting the", rule_type, "as of", date))
  cat("\n")

  # top URL
  base_url <- "http://www.prarulebook.co.uk"
  top_url <- paste0(base_url, "/rulebook/Home/", rule_type, "/", date)

  ################
  ### SECTORS ###
  ##############
  # cat("--- Scraping SECTORS ---")
  # cat("\n")
  # sectors <- scrape_menu(top_url, ".nav-child a")
  # colnames(sectors) <- c("sector_name", "sector_url", "rulebook_url")

  if (layer == "sector") {
    sector_structure <- scrape_sector_structure(top_url)
    return(sector_structure)
  }

  ##############
  ### PARTS ###
  ############

  if (layer == "part") {
    sector_structure <- scrape_sector_structure(top_url)
    part_structure <- scrape_part_structure(sector_structure)
    return(part_structure)
  }

  #################
  ### CHAPTERS ###
  ###############
  # cat("--- Scraping CHAPTERS ---")
  # cat("\n")
  # chapters <- lapply(parts$part_url, scrape_menu, selector = ".Chapter a")
  # chapters <- dplyr::bind_rows(chapters)
  # colnames(chapters) <- c("chapter_name", "chapter_url", "part_url")
  #
  # # clean the chapter names
  # chapters$chapter_name <- gsub("[\r\n]", " ", chapters$chapter_name)
  # chapters$chapter_name <- trimws(gsub("\\s+", " ", chapters$chapter_name))
  #
  # # join chapters to parts and sectors
  # chapters_parts_sectors <- dplyr::left_join(chapters, parts_sectors)

  # TODO figure out return options. use lists to return everything ?
  if (layer == "chapter") {
    sector_structure <- scrape_sector_structure(top_url)
    part_structure <- scrape_part_structure(sector_structure)
    chapter_structure <- scrape_chapter_structure(part_structure)
    return(chapter_structure)
  }

  if (layer == "rule") {
    ##############
    ### RULES ###
    ############

    cat("--- Scraping RULES ---")
    cat("\n")
    rules <- lapply(chapters$chapter_url, scrape_menu, selector = ".rule-number")
    rules <- dplyr::bind_rows(rules)
    # rename
    colnames(rules) <- c("rule_name", "rule_url", "chapter_url")

    # join chapters to parts and sectors
    # TODO find why duplicated created in 2007
    # TODO join on chapter URL !!! not name
    rules_chapters_parts_sectors <- dplyr::left_join(rules, chapters_parts_sectors)

    return(rules)
  }

}

########## TEMP TESTS #########
# # base_url <- "http://www.prarulebook.co.uk"

#top_url <- paste0(base_url, "/rulebook/Home/", "Handbook", "/", "16-11-2007")
#
# chapters_list <- lapply(parts$part_url, scrape_menu, selector = ".Chapter a")
# chapters_df <- bind_rows(chapters_list)


# # temporary fix for 2007 handbook - missing URL from the chapters
# handbook_2007_relevant <- readRDS("C:\\Users\\328254\\Desktop\\Code\\PRA_complexity_SWP\\handbook_2007_relevant.Rds")
#
# #
# #handbook_2007_relevant$Part_url
# missing_URLs <- lapply(handbook_2007_relevant$Part_url, scrape_menu, selector = ".Chapter a")
# missing_df <- dplyr::bind_rows(missing_URLs)
# #missing_df$text <- trimws(missing_df$text)
# colnames(missing_df) <- c("Chapter_name", "Chapter_url", "Part_url")
# saveRDS(missing_df, "handbook_2007_relevant_chapter_URLs_fixed.Rds")

### TODO fix rules > chapter JOIN - to remove duplicates
