#' Scrape the Rulebook content
#'
#' Extract the full text or links from the PRA Rulebook given the URL.
#'
#' @param x String. URL to scrape.
#' @param type String. Type of information to scrape. "Text" or "links".
#' @param selector_to_links String. Optional. CSS selector for individual rules.
#'
#' @return Data frame with URLs and corresponding text.
#' @export
#'
#' @examples
#' \dontrun{
#' get_content("http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007")
#' get_content("http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007", "links")
#' }
get_content <- function(x, type = "text", selector_to_links = NULL) {

  if (!startsWith(x, "http")) { # or WWW / prarulebook.co.uk
    stop("Provide a valid URL.")
  }

  # TODO check the URL type?

  # CSS selectors
  #selector_rule <- ".rule-number"
  selector_rule <- ".col1"
  selector_text <- ".col3"
  # rules require specific selector
  selector_links <-
    ifelse(is.null(selector_to_links), ".col3 a", selector_to_links)

  # TODO return NA when selectors are not present

  # wrap in a function
  pull_nodes <- function(node_to_pull) {

    nodes_only <- httr::GET(x) %>%
      xml2::read_html() %>%
      rvest::html_nodes(node_to_pull)

    return(nodes_only)
  }

  # pull text
  if (type == "text") {
    # works on a chapter level

    nodes_only_text <- pull_nodes(selector_text)
    nodes_text <- nodes_only_text %>% rvest::html_text()

    # TODO pull rule names/turn into df/clean
    # pull rules
    nodes_only_rule <- pull_nodes(selector_rule)
    nodes_rule <- nodes_only_rule %>% rvest::html_text()
    nodes_rule <- nodes_rule[-1] # remove the first one to equalise the length of text and rules

    if (length(nodes_text) == length(nodes_rule)) {
      rule_text_df <- data.frame(rule_rule = nodes_rule,
                                 rule_text = nodes_text,
                                 url = x,
                                 stringsAsFactors = FALSE)
      # TODO clean rule_text_df - remove blanks /n etc

      # deleted rules
      # e.g. MAR 4.1.3 http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007#242057
      rule_text_df$active <- !stringr::str_detect(rule_text_df$rule_rule, "Inactive date")

      # TODO split rule into date rule etc.
      return(rule_text_df)

      # TODO when NA or unequal return a list?
    }
  }

  # pull links
  if (type == "links") {

    # extract the links
    nodes_only_links <- pull_nodes(selector_links)
    nodes_links_text <- nodes_only_links %>% rvest::html_text()
    nodes_links <- nodes_only_links %>% rvest::html_attr("href")

    # turn into a DF
    # checks are added to deal with empty XML (nodes_only_links)
    links_df <- data.frame(link_text = nodes_links_text %>% {ifelse(length(.) == 0, NA, .)},
                           link_link = nodes_links %>% {ifelse(length(.) == 0, NA, .)},
                           url = x,
                           stringsAsFactors = FALSE)

    ### assign link type - used in cleaning the links (network_cleaning.R)
    assign_link_type <- function(x) {
      ifelse(is.na(x), NA,
      ifelse(grepl("Content/Part", x), "Part",
             ifelse(grepl("Content/Chapter", x), "Chapter",
                    ifelse(grepl("Content/Rule", x), "Rule",
                           ifelse(grepl("Content/Sector", x), "Sector",
                                  ifelse(grepl("LegalInstrument", x), "Legal",
                                         ifelse(grepl("/Glossary", x), "Glossary",
                                                "Other")))))))
    }
    # run the link type assignment
    links_df$link_type <- assign_link_type(links_df$link_link)

    # return data frame with links
    return(links_df)
  }
}
