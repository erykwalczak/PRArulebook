#' Scrape the Rulebook content (text)
#'
#' @param x
#' @param selector_text
#' @param selector_rule
#' @param selector_date
#'
#' @return Data frame
#' @export
#'
#' @examples
get_content_text <- function(x, selector_text, selector_rule, selector_date) {

  # define functions
  # main function that check the page status and extracts the nodes
  pull_nodes <- function(node_to_pull) {
    status_check <- httr::GET(x) %>% httr::status_code()

    if (status_check != 200) {
      nodes_only <- NA
      return(nodes_only)
    } else {
      # pull text from selectors
      pull200 <- function(x) {
        xml200 <- httr::GET(x) %>% xml2::read_html()
        list200 <- xml200 %>% rvest::html_nodes(., node_to_pull)
        html200text <- rvest::html_text(list200) %>% trimws() # breaks when "links" pulled
        return(html200text)
      }

      # check if page is active/effective
      # e.g. http://www.prarulebook.co.uk/rulebook/Content/Part/229754/16-11-2007 is not effective (code 410)
      nodes_only <- pull200(x)
      return(nodes_only)
    }
  }

  # scrape
  nodes_text <- pull_nodes(selector_text)
  nodes_text <- rvest::html_text(nodes_text) %>% trimws()


  # TODO pull rule names/turn into df/clean
  # pull rules
  nodes_rule <- pull_nodes(selector_rule)
  nodes_rule <- rvest::html_text(nodes_rule) %>% trimws()
  # remove the first element to equalise the length of text and rules
  nodes_rule <- nodes_rule[-1]

  # test DATE and LABEL
  # TODO turn into a function
  nodes_date <- pull_nodes(selector_date)
  nodes_date <- nodes_date[-1]

  # check if content is available, i.e. chapter/part was effective
  if (length(nodes_text) > 0) {

    if (length(nodes_text) == length(nodes_rule)) {

      rule_text_df <-
        data.frame(rule_number = trimws(nodes_rule),
                   rule_text = trimws(nodes_text),
                   #rule_date = trimws(nodes_date),
                   url = x,
                   stringsAsFactors = FALSE)
      # TODO clean rule_text_df

      # deleted rules
      # e.g. MAR 4.1.3 http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007#242057
      rule_text_df$active <- !stringr::str_detect(rule_text_df$rule_number, "Inactive date")

      # TODO split rule into date rule etc.
      return(rule_text_df)

      # TODO when NA or unequal return a list?
    }
  } else {
    rule_text_df <- data.frame(rule_number = NA,
                               rule_text = NA,
                               url = x)
    return(rule_text_df)
  }
}
