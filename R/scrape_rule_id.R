#' Scrape rule ID
#'
#' @param rule_urls Data frame with rule url. Output of \code{"scrape_rule_structure"}.
#' @param selector_rule_no Rule number CSS selector
#' @param selector_rule_text Rule text CSS selector
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
scrape_rule_id <- function(url, selector_rule_no, selector_rule_text) {

  rules_html <-
    httr::GET(url) %>%
    xml2::read_html()

  # pull text
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


