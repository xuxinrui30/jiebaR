#' Speech Tagging
#' 
#' The function uses Speech Tagging worker to cut word and 
#' tags each word after segmentation using labels compatible with 
#' ictclas.  \code{dict} 
#' \code{hmm} and \code{user} should be provided when initializing 
#' jiebaR worker.
#' 
#' There is a symbol \code{<=} for this function.
#' @seealso \code{\link{<=.tagger}} \code{\link{worker}} 
#' @param code a Chinese sentence or the path of a text file
#' @param jiebar jiebaR Worker
#' @references  The ictclas speech tag : \url{http://t.cn/8FdDD3I}
#' @examples 
#' \donttest{
#' words = "hello world"
#' 
#' ### Speech Tagging 
#' tagger = worker("tag")
#' tagger <= words
#' }
#' @author Qin Wenfeng
#' @export
tagging<- function(code, jiebar) {
  stopifnot("tagger" %in% class(jiebar))
  if(jiebar$PrivateVarible$timestamp != TIMESTAMP){
    stop("Please create a new worker after jiebaR is reloaded.")
  }
  if (!is.character(code) || length(code) != 1) 
    stop("Argument 'code' must be an string.")
  
  if (file.exists(code)) {
    
    encoding<-jiebar$encoding
    
    if(is.null(jiebar$output)){
      basenames <- gsub("\\.[^\\.]*$", "", code)
      extnames  <- gsub(basenames, "", code, fixed = TRUE)
      output    <- paste(basenames, ".segment", as.numeric(Sys.time()), extnames, sep = "")
    }  else {
      output<-jiebar$output
    }
    
    if(jiebar$detect==T)  encoding<-filecoding(code)
    
    FILESMODE <- T
    
    tagl(code = code, jiebar=jiebar,symbol = jiebar$symbol, lines = jiebar$lines, 
         output = output, encoding = encoding, write_file= jiebar$write,FILESMODE = FILESMODE)
  } else {
    if (.Platform$OS.type == "windows") {
      code<-enc2utf8(code)
    }
    FILESMODE <- F
    
    tagw(code = code, jiebar=jiebar,symbol=jiebar$symbol, 
         FILESMODE = FILESMODE)
  }
}

#' @rdname tagging
#' @export
tag <- function(code, jiebar){
  warning("The tag() function is deprecated for shiny package. Please use tagging() instead.")
  tagging(code, jiebar)
}
  

tagl <- function(code, jiebar, symbol, lines, output, encoding, write_file,FILESMODE) {
  
  nlines <- lines
  
  input.r <- file(code, open = "r")
  
  if(write_file==T){
    
    if (.Platform$OS.type == "windows") {
      output.w <- file(output, open = "ab", encoding = "UTF-8")
    } else {
      output.w <- file(output, open = "a", encoding = "UTF-8")
    }
    OUT <- FALSE
    
    tryCatch({
      while (nlines == lines) {
        tmp.lines <- readLines(input.r, n = lines, encoding = encoding)
        nlines <- length(tmp.lines)
        tmp.lines <- paste(tmp.lines, collapse = " ")
        if (nlines > 0) {
          if (encoding != "UTF-8") {
            tmp.lines <- iconv(tmp.lines,encoding , "UTF-8")
          }
          out.lines <- tagw(code = tmp.lines, jiebar = jiebar, 
                            symbol = symbol, FILESMODE = FILESMODE)
          out.lines<-gsub("\\s x\\s","",paste(out.lines, collapse = " "))
          if (.Platform$OS.type == "windows") {
            writeBin(charToRaw(out.lines), output.w)
          } else {
            writeLines(out.lines, output.w)
          }
          
        } 
      } 
    }
    , finally = {
      try(close(input.r), silent = TRUE)
      try(close(output.w), silent = TRUE)
      
    })
    OUT <- TRUE
    cat(paste("Output file: ", output, "\n"))
    
  } else{
    result<-c()
    FILESMODE=F
    
    tryCatch({
      while (nlines == lines) {
        tmp.lines <- readLines(input.r, n = lines, encoding = encoding)
        nlines <- length(tmp.lines)
        tmp.lines <- paste(tmp.lines, collapse = " ")
        if (nlines > 0) {
          if (encoding != "UTF-8") {
            tmp.lines <- iconv(tmp.lines,encoding , "UTF-8")
          }
          out.lines <- tagw(code = tmp.lines, jiebar = jiebar, 
                            symbol = symbol, FILESMODE = FILESMODE)
          
          result<-c(result,out.lines)

        } 
      } 
    }
    , finally = {
      try(close(input.r), silent = TRUE)
      
    })
    
    return(result)
  }
  
}


tagw <- function(code, jiebar,  symbol, FILESMODE) {
  
  if (symbol == F) {
    code <- gsub("[^\u2e80-\u3000\u3021-\ufe4fa-zA-Z0-9]", " ", code)
  } 
#  code <- gsub("^\\s+|\\s+$", "", gsub("\\s+", " ", code))
  
  if(FILESMODE==T ){
    result <- tag_file(code, jiebar$worker)
  } else{
    result <- tag_tag(code, jiebar$worker)
  }
  
  if (symbol == F && FILESMODE  ==F) {
    result = result[ result != " "]
  }
  
  if (.Platform$OS.type == "windows") {
    Encoding(result)<-"UTF-8"
  }
  
  result
} 
