#' Scrape the Rulebook content
#'
#' Extract the full text or links from the PRA Rulebook given the URL.
#'
#' @param x String. URL to scrape.
#' @param type String. Type of information to scrape. "text" or "links".
#' @param single_rule_selector String. Optional. CSS selector for individual rules.
#'
#' @return Data frame with URLs and corresponding text.
#' @export
#'
#' @examples
#' \dontrun{
#' get_content(
#' "http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007")
#' get_content(
#' "http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007",
#' "links")
#' get_content(
#' "http://www.prarulebook.co.uk/rulebook/Content/Rule/211145/18-06-2019#211145",
#' "text",
#' single_rule_selector = "yes")
#' }
get_content <- function(x, type = "text", single_rule_selector = NULL) {

  if (!startsWith(x, "http")) { # TODO or WWW / prarulebook.co.uk
    stop("Provide a valid URL.")
  }

  # TODO check the URL type?

  # CSS selectors
  #selector_rule <- ".rule-number"
  selector_rule <- ".col1"
  selector_text <- ".col3"
  #selector_date <- ".effective-date"
  #selector_label <- ".rule-labels li"
  selector_links <- ".col3 a"

  # check correct argument
  if (!is.null(single_rule_selector)) {
    if (single_rule_selector != "yes") {
      stop("Use 'single_rule_selector' set to 'yes' if you want to scrape single rules.")
    }
    # get the rule ID
    rule_id <- sub(".*#", "", x)
    # create a selector for rule text
    selector_text <- paste0("#", rule_id, "+ .div-row .col3")
    # and rule
    selector_rule <- paste0("#", rule_id, "+ .div-row .col1")
    # links - TODO: check
    selector_links <- paste0("#", rule_id, "+ .div-row .col3 a")
  }

  # TODO return NA when selectors are not present

  # wrap in a function
  # TODO - export to helper functions, add x to arg, double-check all calls
  pull_nodes <- function(node_to_pull) {

    nodes_only_get <- httr::GET(x)

    # check if part is effective
    if (httr::status_code(nodes_only_get) == 200) {

      nodes_only <- nodes_only_get %>%
        xml2::read_html() %>%
        rvest::html_nodes(node_to_pull)

      return(nodes_only)
    }
    # if not 200 then return NA
    # e.g. http://www.prarulebook.co.uk/rulebook/Content/Part/229754/16-11-2007
    nodes_only <- NA
    return(nodes_only)
  }

  # pull text
  if (type == "text") {
    # works on a chapter level

    # display
    cat(".")
    cat("\n")

    # function to extract text
    extract_node_text <- function(y) {

      nodes_text <-
        ifelse(is.na(y) | length(y) == 0,
               NA,
               y %>% rvest::html_text() %>% trimws())
      return(nodes_text)
    }

    # scrape
    nodes_only_text <- pull_nodes(selector_text)
    nodes_text <- extract_node_text(nodes_only_text)

    # pull rules
    nodes_only_rule <- pull_nodes(selector_rule)
    nodes_rule <- extract_node_text(nodes_only_rule)
    # remove the first element to equalise the length of text and rules
    # TODO fails for non-rules !!!!!!!!!!!!
    if (is.null(single_rule_selector)) {
      nodes_rule <- nodes_rule[2:length(nodes_rule)]
    }

    # test DATE and LABEL
    # TODO turn into a function
    # nodes_only_date <- pull_nodes(selector_date)
    # nodes_date <- extract_node_text(nodes_only_date)
    # nodes_date <- nodes_date[-1]

    # check if content is available, i.e. chapter/part was effective
    if (length(nodes_only_text) > 0 & !is.na(nodes_only_text)) {

      # check if length if equal
      if (length(nodes_text) == length(nodes_rule)) {

        rule_text_df <-
          data.frame(rule_number = nodes_rule,
                     rule_text = nodes_text,
                     #rule_date = nodes_date,
                     url = x,
                     stringsAsFactors = FALSE)
        # TODO clean rule_text_df
        # TODO rename 'url' based on the input type: chapter/rule etc.

        # deleted rules
        # e.g. MAR 4.1.3 http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007#242057
        rule_text_df$active <-
          !stringr::str_detect(rule_text_df$rule_number, "Inactive date")

        # TODO split rule into date rule etc.
        return(rule_text_df)
      }
    }
    else {
      #display info
      print(paste0("Check the quality of ", x))

      rule_text_df <- data.frame(rule_number = NA,
                                 rule_text = NA,
                                 url = x,
                                 active = NA,
                                 stringsAsFactors = FALSE)
      return(rule_text_df)
    }
  }

  # pull links
  if (type == "links") {

    # display
    cat(".")
    cat("\n")

    # extract the links
    nodes_only_links <- pull_nodes(selector_links)

    # assign NAs if there are no links
    if (length(nodes_only_links) == 0) {

      nodes_links_text <- NA
      nodes_links <- NA

    }

    if (length(nodes_only_links) != 0) {

      nodes_links_text <-
        nodes_only_links %>%
        rvest::html_text() %>%
        trimws()

      nodes_links <-
        nodes_only_links %>%
        rvest::html_attr("href")
    }

    # turn into a DF
    # checks are added to deal with empty XML (nodes_only_links)
    links_df <- data.frame(from = x,
                           to = nodes_links,
                           to_text = nodes_links_text,
                           stringsAsFactors = FALSE)

    # run the link type assignment
    links_df$to_type <- PRArulebook:::assign_link_type(links_df$to)

    # apply the cleaning function only on non-NA url
    links_df$to <- ifelse(is.na(links_df$to),
                          links_df$to,
                          PRArulebook:::clean_to_link(links_df$to))

    # return data frame with links
    return(links_df)
  }
}
