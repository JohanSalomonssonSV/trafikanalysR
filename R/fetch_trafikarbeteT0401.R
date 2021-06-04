#' @title fetch_trafikarbeteT0401
#' @importFrom magrittr "%>%"
#' @importFrom readr read_csv parse_number
#' @importFrom dplyr mutate filter mutate_if as_tibble relocate bind_rows
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom tidyr spread
#' @param URL url to API
#' @param DATA_SELECTION number from 1 to N
#' @export
#'
fetch_trafikarbeteT0401 <- function(URL, DATA_SELECTION) {
  Comb_selection <-
    readr::read_csv("https://raw.githubusercontent.com/JohanSalomonssonSV/trafikanalysR/master/data/trafikarbeteT0401.csv")
  TABLE_OF_INTEREST <-
    Comb_selection %>% dplyr::filter(Short == DATA_SELECTION) %>% .$Code_snippet
  LINK <- paste0(URL, TABLE_OF_INTEREST)
  raw_res <- httr::GET(LINK)
  text_content <- httr::content(raw_res, as = "text")
  text_content_json <- text_content %>% jsonlite::fromJSON()

  numeric_varibles <-
    text_content_json$Header$Column[c("Name", "Type")] %>% dplyr::filter(Type == "M") %>% .$Name

  t <- lapply(1:length(text_content_json$Rows$IsTotal), function(i) {
    as.data.frame(cbind(Column = text_content_json[["Rows"]][["Cell"]][[i]][["Column"]],
                        Value = text_content_json[["Rows"]][["Cell"]][[i]][["Value"]],
                        IsTotal=text_content_json$Rows$IsTotal[i]
    )) %>%
      dplyr::mutate(Value = gsub(",", ".", Value))  %>%
      tidyr::spread(Column , Value) %>%
      dplyr::mutate_if(names(.) %in% numeric_varibles, as.numeric)
  })

  df <-
    dplyr::bind_rows(t) %>% dplyr::as_tibble() %>%  dplyr::relocate(where(is.numeric), .after = where(is.character))
  df
}
