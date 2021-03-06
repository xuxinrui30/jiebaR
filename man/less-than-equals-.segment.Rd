% Generated by roxygen2 (4.0.2): do not edit by hand
\name{<=.segment}
\alias{<=.segment}
\alias{[.segment}
\title{Text segmentation symbol}
\usage{
\method{<=}{segment}(jiebar, code)

\method{[}{segment}(jiebar, code)
}
\arguments{
\item{jiebar}{jiebaR Worker.}

\item{code}{A Chinese sentence or the path of a text file.}
}
\description{
Text segmentation symbol to cut words.
}
\examples{
\donttest{
words = "hello world"
test1 = worker()
test1 <= words}
}
\author{
Qin Wenfeng <\url{http://qinwenfeng.com}>
}

