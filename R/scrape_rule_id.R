#' Scrape rule ID
#'
#' @param rule_urls Data frame with rule url. Output of \code{"scrape_rule_structure"}.
#' @param type String. Type of data to scrape: text or links.
#'
#' @return Data frame with rule text and links.
#' @export
#'
#' @examples
#' \dontrun{
#' chapters_df <- get_structure("16-11-2007", layer = "chapter")
#' rules12 <- scrape_rule_structure(chapters_df[1:2,], "16-11-2007")
#' scrape_rule_id(rules12[1,])
#' }
scrape_rule_id <- function(rule_urls, type = "text") {

  # TODO check if ruleURL provided

  rules_html <-
    httr::GET(rule_urls[["rule_url"]]) %>%
    xml2::read_html()

  # pull text
  if (type == "text") {

  cat(".")

  rule_urls$rule_number <-
    rules_html %>%
    rvest::html_nodes(rule_urls[["rule_number_sel"]]) %>%
    rvest::html_text()

  rule_urls$rule_text <-
    rules_html %>%
    rvest::html_nodes(rule_urls[["rule_text_sel"]]) %>%
    rvest::html_text()

  return(rule_urls)

  }

  # pull links
  if (type == "links") {

    cat(".")

  }

  # This is an examples of a rule that linked to from MAR 4.1.1 - text FROM link (MAR 4.4.1 R)
  # url FROM http://www.prarulebook.co.uk/rulebook/Content/Rule/242070/16-11-2007#242070
  # url changes to http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007#242070

  ##= use the following form (first number is ID); last is standard selector
  ## works with: .col1, .col3, .rule-label, .rule-number, .effective-date
}

###
## works on single url
#rules12_new <- scrape_rule_id(rules12[1,])
## TODO fix vectorization - see scrape_menu
#rules12_new_all <- purrr::map_df(rules12, scrape_rule_id)
