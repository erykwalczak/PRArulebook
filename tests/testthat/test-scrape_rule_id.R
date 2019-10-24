test_that("scrape_rule_id works", {
  # check inputs
  expect_error(scrape_rule_id())
  expect_error(scrape_rule_id("a"))
  expect_error(scrape_rule_id("http"))
})
