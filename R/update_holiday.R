#' Update Chinese holidays
#'
#' This function will be used to update Chinese holidays in the data folder.
#'
update_holiday <- function() {
  holiday_zh_list <- list()
  for (year in 2013:as.numeric(format(Sys.time(), "%Y")) + 1) {
    Sys.sleep(sample(seq(from = 1, to = 3, by = 1), size = 1))
    url <- sprintf("https://timor.tech/api/holiday/year/%d", year)
    response <- httr::GET(url, httr::add_headers(`User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/237.84.2.178 Safari/537.36"))
    data <- httr::content(response, as = "text", encoding = "UTF-8")
    data_json <- jsonlite::fromJSON(data)
    holiday_zh <- data_json$holiday |>
      dplyr::bind_rows()
    holiday_zh$rest <- NULL
    holiday_zh_list[[length(holiday_zh_list) + 1]] <- holiday_zh
  }

  holiday_zh_new <- do.call(rbind, holiday_zh_list)
  load("data/holiday_zh.rda")
  holiday_zh <- rbind(holiday_zh, holiday_zh_new) |>
    dplyr::distinct() |> dplyr::mutate(update_time = Sys.time())
  write.csv(holiday_zh,'./inst/extdata/holiday_zh.csv', row.names = FALSE)
  usethis::use_data(holiday_zh, overwrite = TRUE)
  
}
update_holiday()
