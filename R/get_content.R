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
  x <- x
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
  # pull_nodes to zzz.R

  # pull text
  if (type == "text") {
    # works on a chapter level

    # display
    cat(".")
    cat("\n")

    # call the helper function to scrape text
    get_content_text(x, selector_text, selector_rule, selector_date)

  }

  # pull links
  if (type == "links") {

    # display
    cat(".")
    cat("\n")

    get_content_links()

}
}
