
#' @export
tag<- function(code, jiebar) {
  
  if (!is.character(code) || length(code) != 1) 
    stop("Argument 'code' must be an string.")
  if (file.exists(code)) {
    encoding<-jiebar$Encoding
    if(jiebar$DetectEncoding==T)  encoding<-filecoding(code)
    FILESMODE <- T
    tagl(code = code, jiebar=jiebar,symbol = jiebar$Symbol, lines = jiebar$ReadLines, 
         output = jiebar$OutputPath, encoding = encoding, write_file= jiebar$WriteFile,FILESMODE = FILESMODE)
  } else {
    FILESMODE <- F
    tagw(code = code, jiebar=jiebar,symbol=jiebar$Symbol, 
         FILESMODE = FILESMODE)
  }
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
          
          if (.Platform$OS.type == "windows") {
            writeBin(charToRaw(paste(out.lines, collapse = " ")), output.w)
          } else {
            writeLines(paste(out.lines, collapse = " "), output.w)
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
    code <- gsub("[^\u4e00-\u9fa5a-zA-Z0-9]", " ", code)
  } 
  code <- gsub("^\\s+|\\s+$", "", gsub("\\s+", " ", code))
  if(FILESMODE==T ){
  result <- jiebar$Worker$file(code)
  } else{
    result <- jiebar$Worker$tag(code)
  }
  
  if (symbol == F && FILESMODE  ==F) {
    result <- grep("[^[:space:]]", result, value = T)
  }
  if (.Platform$OS.type == "windows" && FILESMODE == F) {
    
    return(iconv(result, "UTF-8", "GBK"))
  }
  return(result)
} 