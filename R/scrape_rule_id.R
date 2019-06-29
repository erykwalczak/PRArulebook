#' Scrape rule ID
#'
#' @param rule_urls Data frame with rule url. Output of \code{"scrape_rule_structure"}.
#' @param selector_rule_no Rule number CSS selector
#' @param selector_rule_text Rule text CSS selector
#' @param type String. Type of data to scrape: text or links.
#'
#' @return Data frame with rule text and links.
#' @export
#'
#' @examples
#' \dontrun{
#' chapters_df <- get_structure("16-11-2007", layer = "chapter")
#' rules12 <- scrape_rule_structure(chapters_df[1:2,], "16-11-2007")
#' scrape_rule_id(rules12$rule_url[1], rules12$rule_number_sel[1], rules12$rule_text_sel[1])
#' }
scrape_rule_id <- function(url, selector_rule_no, selector_rule_text, type = "text") {

  if (!startsWith(url, "http")) { # or WWW / prarulebook.co.uk
    stop("Provide a valid URL.")
  }

  rules_html <-
    httr::GET(url) %>%
    xml2::read_html()

  # pull text
  if (type == "text") {

    cat(".")

    # TODO add tryCatch - otherwise fails on rules12[2,]
    rule_number_content <-
      rules_html %>%
      rvest::html_nodes(selector_rule_no) %>%
      rvest::html_text() %>%
      {ifelse(length(.) == 0, NA, .)}

    rule_text_content <-
      rules_html %>%
      rvest::html_nodes(selector_rule_text) %>%
      rvest::html_text() %>%
      {ifelse(length(.) == 0, NA, .)}

    rules_content <-
      data.frame(rule_number = rule_number_content,
                 rule_text = rule_text_content,
                 rule_url = url,
                 stringsAsFactors = FALSE
                 )
    return(rules_content)

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


