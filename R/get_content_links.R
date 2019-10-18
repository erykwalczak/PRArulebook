get_content_links <- function() {
  # extract the links
  nodes_only_links <- pull_nodes(selector_links)

  # assign NAs if there are no links
  if (length(nodes_only_links) == 0) {

    nodes_links_text <- NA
    nodes_links <- NA

  }

  if (length(nodes_only_links) != 0) {

    nodes_links_text <-
      nodes_only_links # pulls residual from the old code

    # TODO fix - pull_nodes() extracts html_text
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

  ### assign link type - used in cleaning the links (network_cleaning.R)
  # assign_link_type moved to zzz.R

  # run the link type assignment
  links_df$to_type <- assign_link_type(links_df$to)

  # clean the links - append "http:" if it's a rulebook url
  # clean_to_link moved to zzz.R

  # apply the cleaning function only on non-NA url
  links_df$to <- ifelse(is.na(links_df$to),
                        links_df$to,
                        clean_to_link(links_df$to))


  # return data frame with links
  return(links_df)
}
