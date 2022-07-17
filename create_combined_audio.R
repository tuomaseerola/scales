#' Return pairwise comparisons
#'
#' This function combines the all files for a pairwise comparison experiment
#' without self-comparisons and upper triangle. The order of the pairs 
#' is random.
#' 
#' @param filenames filenames to be processed
#' @param silence Instrument to be processed
#' @return strings
#' @export
#' @import combinat

create_combined_audio <-
  function(filenames = NULL,
           IOI_file = 'silence1000ms.wav') {
    # T. Eerola, Durham University, Scales project
    # 17/7/2022
    
#    filenames = p$combinedfilenames
#    IOI_file = 'silence1000ms.wav'
  
    cmd <- list()  
    for (k in 1:length(filenames)) {
      FN <- strsplit(filenames[k],' ')
      fn <- FN[[1]]
      outputfn <- fn[1]
      outputfn2 <- gsub(pattern = "\\....$", "_", outputfn)
      cmd[[k]] <- paste0('sox ',' www/',fn[1],' www/',IOI_file,' www/',fn[2],' www/','tmp_',outputfn2,fn[2])
    }
#    return <- cmd
    for (k in 1:length(cmd)) {
      system(cmd[[k]], wait = TRUE, timeout = 1)
    }
  }
