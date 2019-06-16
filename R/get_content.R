#' Scrape the Rulebook content
#'
#' Extract the full text or links from the PRA Rulebook given the URL.
#'
#' @param x Text. URL to scrape.
#'
#' @return Data frame with URLs and corresponding text.
#' @export
#'
#' @examples
#' \dontrun{
#' get_content("http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007")
#' get_content("http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007", "links")
#' }
get_content <- function(x, type = "text") {

  if (!startsWith(x, "http")) {
    stop("Provide a valid URL.")
  }

  # TODO check the URL type?

  # CSS selectors
  #selector_rule <- ".rule-number"
  selector_rule <- ".col1"
  selector_text <- ".col3"
  selector_links <- ".col3 a"

  # TODO return NA when selectors are not present

  # wrap in a function
  pull_nodes <- function(node_to_pull) {

    nodes_only <- httr::GET(x) %>%
      read_html() %>%
      html_nodes(node_to_pull)

    return(nodes_only)
  }

  # pull text
  if (type == "text") {

    nodes_only_text <- pull_nodes(selector_text)
    nodes_text <- nodes_only_text %>% html_text()
    #return(nodes_text)
    # TODO pull rule names/turn into df/clean
    # pull rules
    nodes_only_rule <- pull_nodes(selector_rule)
    nodes_rule <- nodes_only_rule %>% html_text()
    nodes_rule <- nodes_rule[-1] # remove the first one to equalise the length of text and rules

    if (length(nodes_text) == length(nodes_rule)) {
      rule_text_df <- data.frame(rule_rule = nodes_rule,
                                 rule_text = nodes_text,
                                 stringsAsFactors = FALSE)
      # TODO clean rule_text_df - remove blanks /n etc
      # TODO split rule into date rule etc.
      return(rule_text_df)

      # TODO when NA or unequal return a list?
    }
  }

  # pull links
  if (type == "links") {

    # extract the links
    nodes_only_links <- pull_nodes(selector_links)
    nodes_links_text <- nodes_only_links %>% html_text()
    nodes_links <- nodes_only_links %>% html_attr("href")

    # turn into a DF
    links_df <- data.frame(link_text = nodes_links_text,
                           link_link = nodes_links,
                           url = x,
                           stringsAsFactors = FALSE)
    # TODO add the full URL to link_link if starts with /rulebook/
    return(links_df)
  }
}



########## tests
#
# url_to_scrape <- "http://www.prarulebook.co.uk/rulebook/Content/Chapter/216146/16-11-2007"
#
# url_to_scrape <- "http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007"
#
# # CSS selectors
# #selector_rule <- ".rule-number"
# selector_rule <- ".col1"
# selector_text <- ".col3"
# selector_links <- ".col3 a"
#
# nodes_only_text <- httr::GET(url_to_scrape) %>%
#   read_html() %>%
#   html_nodes(selector_text)
#
# nodes_only_rule <- httr::GET(url_to_scrape) %>%
#   read_html() %>%
#   html_nodes(selector_rule)
#
#
# ### TODO - put into the function ^
# # pull text
# nodes_text <- nodes_only_text %>% html_text()
# # pull rules
# nodes_rule <- nodes_only_rule %>% html_text()
# nodes_rule <- nodes_rule[-1] # remove the first one to equalise the length of text and rules
#
# if (length(nodes_text) == length(nodes_rule)) {
#   rule_text_df <- data.frame(rule_rule = nodes_rule,
#                              rule_text = nodes_text,
#                              stringsAsFactors = FALSE)
#   # TODO clean rule_text_df - remove blanks /n etc
#   # TODO split rule into date rule etc.

# }
