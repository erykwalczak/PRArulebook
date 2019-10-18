#' Scrape the Rulebook content (text)
#'
#' @return Data frame
#' @export
#'
#' @examples
get_content_text <- function() {
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
