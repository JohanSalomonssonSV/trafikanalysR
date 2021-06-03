#' @title varufloden_ow
#' @importFrom magrittr "%>%"
#' @param URL url to API
#' @export
varufloden_ow <- function(URL) {
  Comb_selection <-
    readr::read_csv("https://raw.githubusercontent.com/JohanSalomonssonSV/trafikanalysR/master/varufloden.csv")


  Variable_df  <- lapply(unique(Comb_selection$Short), function(i) {
    TABLE_OF_INTEREST <-
      Comb_selection %>% dplyr::filter(Short == i) %>% .$Code_snippet
    LINK <- paste0(URL, TABLE_OF_INTEREST)
    raw_res <- httr::GET(LINK)
    text_content <- httr::content(raw_res, as = "text")
    text_content_json <- text_content %>% jsonlite::fromJSON()

    temp_data <-
      text_content_json$Header$Column[c("Name", "Value", "Type")] %>% dplyr::mutate(DATA =
                                                                               paste0("Data: ", i),
                                                                             InData =
                                                                               1) %>% dplyr::rename("Var_desc" = Value)
    temp_data
  })

  t <- plyr::ldply(Variable_df, rbind)
  t <- t %>% dplyr::mutate(
    Var_desc = forcats::fct_reorder(Var_desc, InData, sum),
    Name = forcats::fct_reorder(Name, InData, sum),
    DATA = forcats::fct_reorder(DATA, -readr::parse_number(DATA))
  )
  t

}


