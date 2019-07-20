# helper functions

# in get_content
# TODO reorder to speed up checks
assign_link_type <- function(x) {
  ifelse(is.na(x), NA,
         ifelse(grepl("Content/Part", x), "Part",
                ifelse(grepl("Content/Chapter", x), "Chapter",
                       ifelse(grepl("Content/Rule", x), "Rule",
                              ifelse(grepl("Content/Sector", x), "Sector",
                                     ifelse(grepl("LegalInstrument", x), "Legal",
                                            ifelse(grepl("/Glossary", x), "Glossary",
                                                   "Other")))))))
}
