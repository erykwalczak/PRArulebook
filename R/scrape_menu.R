#' Scrape the menu
#'
#' Scrapes names and URLs from the PRA rulebook menu. The menu is on the left-hand side of the rulebook website.
#'
#' @param url Full URL to scrape
#' @param selector String. CSS selector to scrape. Use Chrome with SelectorGadget to find the relevant selector.
#' @param date String. Optional date. Needed only for rule ID scraping.
#'
#' @return Data frame with text, url, or both.
#' @export
#'
#' @examples
#' \dontrun{
#' scrape_menu("http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007", ".nav-child a")
#' scrape_menu("http://www.prarulebook.co.uk/rulebook/Home/Handbook/16-11-2007", ".nav-child a", "text")
#' scrape_menu("http://www.prarulebook.co.uk/rulebook/Content/Chapter/242047/16-11-2007", "a", date = "16-11-2007")
#' }
scrape_menu <- function(url, selector, date) {

  # TODO add to onLoad
  base_url <- "http://www.prarulebook.co.uk"

  # show progress
  cat(".")

  # pull the html nodes
  # TODO add ua
  # TODO test return values
  nodes_only <- httr::GET(url) %>%
    xml2::read_html() %>%
    rvest::html_nodes(selector)

  # pull text
  nodes_text <- nodes_only %>% rvest::html_text()
  # check if element is effective
  # e.g. "http://www.prarulebook.co.uk/rulebook/Content/Part/229754/16-11-2007"
  if (length(nodes_text) == 0) {
    nodes_text <- NA
  }

  # pull url
  nodes_url <-
    nodes_only %>%
    rvest::html_attr("href") %>%
    paste0(base_url, .)
  # check if element is effective
  # nodes have no text then this element is not effective
  nodes_url <- ifelse(is.na(nodes_text), NA, nodes_url)

  # rules have no URLs when scraped from the chapter level
  if (selector == ".rule-number") {
    nodes_url <- NA
  }

  # combine vectors
  nodes_df <- data.frame(name = nodes_text,
                         menu_url = nodes_url,
                         provided_url = rep(url, length(nodes_text)),
                         stringsAsFactors = FALSE)

  # scrape rule IDs and create URLs from them
  if (selector == "a") {
    IDs <- nodes_only %>% rvest::html_attr("id") %>% na.omit()

    # test if empty
    # e.g. http://www.prarulebook.co.uk/rulebook/Content/Chapter/302933/16-11-2017

    if (length(IDs) > 0) {
      # keep only those with numbers
      # TODO fix warning - suppressMessages() didn't work
      # .Warning message:
      # In scrape_menu(URL, : NAs introduced by coercion
      IDs <- as.numeric(gsub("([0-9]+).*$", "\\1", IDs))
      IDs <- IDs[!is.na(IDs)]
      # turn into string to count the characters
      # IDs have 6 characters
      IDs <- as.character(IDs)
      IDs <- ifelse(nchar(IDs) == 6, IDs, NA)

      # create actual URLs
      rule_urls <-
        paste0("http://www.prarulebook.co.uk/rulebook/Content/Rule/",
               IDs,
               "/",
               date,
               "#",
               IDs)

      # create selectors for rules
      rule_no_selector <-
        paste0("#", IDs, "+ .div-row .rule-number")
      rule_text_selector <-
        paste0("#", IDs, "+ .div-row .col3")
      rule_link_selector <-
        paste0("#", IDs, "+ .div-row a")

    } else {

      IDs <- NA
      rule_urls <- NA
      rule_no_selector <- NA
      rule_text_selector <- NA
      rule_link_selector <- NA

    }

    # # pull content
    # TODO turn into a function and map
    # rule_number <-
    #   httr::GET(rule_urls) %>%
    #   xml2::read_html() %>%
    #   rvest::html_nodes(rule_no_selector) %>%
    #   rvest::html_text()
    #
    # rule_text <-
    #   httr::GET(rule_urls) %>%
    #   xml2::read_html() %>%
    #   rvest::html_nodes(rule_text_selector) %>%
    #   rvest::html_text()

    # httr::GET("http://www.prarulebook.co.uk/rulebook/Content/Rule/242070/16-11-2007#242070") %>%
    #   xml2::read_html() %>% html_nodes("#242070+ .div-row .col3 p") %>% html_text()

    # make a df with rule URLs and add IDs
    rule_IDs <-
      data.frame(rule_url = rule_urls,
                 rule_id = IDs,
                 rule_number_sel = rule_no_selector,
                 rule_text_sel = rule_text_selector,
                 rule_link_sel = rule_link_selector,
                 chapter_url = url,
                 stringsAsFactors = FALSE)

    # assign the IDs
    nodes_df <- rule_IDs
  }

  # TODO rename nodes_df columns if one of the selectors used ?
  return(nodes_df)

}
