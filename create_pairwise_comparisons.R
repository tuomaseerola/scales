#' Return pairwise comparisons
#'
#' This function combines the all files for a pairwise comparison experiment
#' without self-comparisons and upper triangle. The order of the pairs 
#' is random.
#' 
#' @param filenames filenames to be processed
#' @param random_order Instrument to be processed
#' @return strings
#' @export
#' @import combinat

create_pairwise_comparisons <-
  function(filenames = NULL,
           random_order = TRUE) {
    # T. Eerola, Durham University, Scales project
    # 17/7/2022
    
    p <- combinat::combn(filenames, 2)
    df<- data.frame(nro=1:ncol(p),t(p))
    df
  
    # random_order  
    if(random_order==TRUE){
      r_order <- runif(nrow(df),0,1) >= 0.5
      df$reverse<-r_order # reverse
      df
      df$combinedfilenames<-''
      for (k in 1:nrow(df)) {
        if(df$reverse[k]==TRUE){
          df$combinedfilenames[k] <- paste(df$X2[k],df$X1[k])
        }
        else {
          df$combinedfilenames[k] <- paste(df$X1[k],df$X2[k])
        }
      }
    }
    else {
      df$reverse <- FALSE
      df$combinedfilenames <- ''
      df$combinedfilenames <- paste(df$X1,df$X2)
    }

    # create a new filename
    df$created_files<-NULL
    for (l in 1:nrow(df)) {
      FN <- strsplit(df$combinedfilenames[l],' ')
      fn <- FN[[1]]
      outputfn <- fn[1]
      outputfn2 <- gsub(pattern = "\\....$", "_", outputfn)
      df$created_files[l] <- paste0('tmp_',outputfn2,fn[2])
    }
    
    return <- df
  }
