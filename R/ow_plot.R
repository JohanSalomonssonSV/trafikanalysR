#' @title ow_plot
#' @importFrom magrittr "%>%"
#' @importFrom ggplot2 ggplot geom_point theme element_text labs scale_color_manual aes
#' @param URL x a OW data object
#' @export

ow_plot<-function(x){
  p<-x %>% ggplot2::ggplot( ggplot2::aes(Name  ,DATA, color=Type
  )
  ) +
    ggplot2::geom_point(size=2)+
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, vjust = 1, hjust=1, size = 9),
      axis.text.y = ggplot2::element_text( size = 8)
    )+
    ggplot2::labs(x="", y="Data Combinations", color="Dim/Metric"
    )+
    ggplot2::scale_color_manual(values = c("M"= "red", "D"="blue"))
  p
}
