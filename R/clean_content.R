#' Clean scraped content
#'
#' @param df Data frame with scraped content. Output of \code{"get_content"}.
#'
#' @return Data frame with cleaned content of scraped rules.
#' @export
#'
#' @examples
#' \dontrun{
#' chapter_content <- get_content("http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007")
#' clean_content(chapter_content)
#' }
clean_content <- function(df) {

  # remove carriage return
  df[["rule_rule"]] <-
    # remove leading and trailing whitespaces
    trimws(
      gsub("[\r\n]", "", df[["rule_rule"]]))

  ### assign a rule type ###
  # R - Rule, G - Guidance, D - Directions under FSMA,
  # E - Evidential Provisions - Rules but not binding in their own right; they bind in relation to another rule,
  # P - Principals, C - Conduct
  df$type <- trimws(stringr::str_extract(df[["rule_rule"]], " [A-Z]$"))

  # detect if it's a rule or note
  df$note <- stringr::str_detect(df$rule_rule, "^See Notes")

  return(df)
}


# clean_content(chapter_content_prin1)





# Rules = Rules + Evidential Provisions
# Guidance = Guidance + Directions under FSMA



############## add the full URL to link_link if starts with /rulebook/
#' example
#' assign full URL
#' links_df$link_link <- clean_rulebook_url(links_df$link_link)
clean_rulebook_url <- function(x) {
  rulebook_url_start <- "http://www.prarulebook.co.uk"
  # appends when the URL is incomplete
  if (stringr::str_detect(x, "^/rulebook/")) {
    x <- paste0(rulebook_url_start, x)
    return(x)
  }
  # returns the original when neither form of the URL
  else {
    return(x)
  }
}
