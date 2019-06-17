#' Scrape the menu
#'
#' Scrapes names and URLs from the PRA rulebook menu. The menu is on the left-hand side of the rulebook website.
#'
#' @param url Full URL to scrape
#' @param selector CSS selector to scrape. Use Chrome with SelectorGadget to find the relevant selector.
#' @param structure_type Type of structure to scrape: text, url, both.
#'
#' @return Data frame with text, url, or both.
#' @export
#'
#' @examples
#' \dontrun{
#' scrape_menu("http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007", ".nav-child a")
#' scrape_menu("http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007", ".nav-child a", "text")
#' }
scrape_menu <- function(url, selector, structure_type = "both") {

  # TODO add to onLoad
  base_url <- "http://www.prarulebook.co.uk"

  # show progress
  cat(".")

  # pull the html nodes
  nodes_only <- httr::GET(url) %>%
    xml2::read_html() %>%
    rvest::html_nodes(selector)

  # pull text
  nodes_text <- nodes_only %>% rvest::html_text()
  # check if element is effective
  # e.g. "http://www.prarulebook.co.uk/rulebook/Content/Part/229754/16-11-2007"
  if (length(nodes_text) == 0) {
    nodes_text <- NA
  }

  # pull url
  nodes_url <-
    nodes_only %>%
    rvest::html_attr("href") %>%
    paste0(base_url, .)
  # check if element is effective
  # nodes have no text then this element is not effective
  if (is.na(nodes_text)) {
    nodes_url <- NA
  }

  # rules have no URLs when scraped from the chapter level
  if (selector == ".rule-number") {
    nodes_url <- NA
  }

  # combine vectors
  nodes_df <- data.frame(name = nodes_text,
                         menu_url = nodes_url,
                         provided_url = rep(url, length(nodes_text)),
                         stringsAsFactors = FALSE)

  # TODO rename nodes_df columns if one of the selectors used

  if (structure_type == "both") {
    return(nodes_df)
  }

  if (structure_type == "text") {
    return(nodes_text)
  }

  if (structure_type == "url") {
    return(nodes_url)
  }

}
