test_that("scrape_menu_rule works", {
  # check inputs
  expect_error(scrape_menu_rule())
  expect_error(scrape_menu_rule("a", "b", "c"))
})
