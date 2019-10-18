#' Scrape the Rulebook content
#'
#' Extract the full text or links from the PRA Rulebook given the URL.
#'
#' @param x String. URL to scrape.
#' @param type String. Type of information to scrape. "text" or "links".
#' @param single_rule_selector String. Optional "yes". CSS selector for individual rules.
#'
#' @return Data frame with URLs and corresponding text.
#' @export
#'
#' @examples
#' \dontrun{
#' get_content("http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007")
#' get_content("http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007", "links")
#' get_content("http://www.prarulebook.co.uk/rulebook/Content/Rule/216149/16-11-2007#216149",
#' "links", "yes")
#' }
get_content <- function(x, type = "text", single_rule_selector = NULL) {

  if (!startsWith(x, "http")) { # or WWW / prarulebook.co.uk
    stop("Provide a valid URL.")
  }

  # TODO check the URL type?

  # CSS selectors
  #selector_rule <- ".rule-number"
  selector_rule <- ".col1"
  selector_text <- ".col3"
  selector_date <- ".effective-date"
  selector_label <- ".rule-label"

  # rules require specific selector
  if (is.null(single_rule_selector)) {
    selector_links <- ".col3 a"
  }

  # extract rules
  if (!is.null(single_rule_selector) && single_rule_selector == "yes") {
    # get the rule ID
    # TODO write a more robust regex
    rule_id <- stringr::str_sub(x, start = -6)
    # create the selector
    selector_links <- paste0("#", rule_id, "+ .div-row a")
  }

  # return NA when selectors are not present
  pull_nodes <- function(node_to_pull) {
    status_check <- httr::GET(x) %>% httr::status_code()

    # pull text from selectors
    pull200 <- function(x) {
      xml200 <- httr::GET(x) %>% xml2::read_html()
      list200 <- xml200 %>% rvest::html_nodes(., node_to_pull)
      #html200text <- rvest::html_text(list200) %>% trimws() # breaks when "links" pulled
      return(list200)
    }

    # check if page is active/effective
    # e.g. http://www.prarulebook.co.uk/rulebook/Content/Part/229754/16-11-2007 is not effective (code 410)
    nodes_only <- ifelse(status_check == 200,
                         pull200(x),
                         NA)
    return(nodes_only)
  }

  # pull text
  if (type == "text") {
    # works on a chapter level

    # display
    cat(".")
    cat("\n")

    # call the helper function to scrape text
    get_content_text()

  }

  # pull links
  if (type == "links") {

    # display
    cat(".")
    cat("\n")

    get_content_links()

}
