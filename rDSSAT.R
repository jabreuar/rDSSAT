library(httr)
library(jsonlite)

baseUrl <- "http://localhost:3000/api/"

install <- function(workDirectory="") {
  #create working directory
  createPathCommand <- paste("mkdir", workDirectory, sep=" ")
  shell(shQuote(createPathCommand, type = c("cmd")))
  
  #clone repo from git
  cloneRepositoryCommand <- paste("cd", workDirectory, "&&", "git", "clone", "https://github.com/jabreuar/jdssat.git", sep = " ")
  shell(shQuote(cloneRepositoryCommand, type = c("cmd")))
  
  jdssatPath = paste(workDirectory, "\\jdssat", sep = "")
  
  #install dependencies
  npmInstallCommand <- paste("cd", jdssatPath, "&&", "npm", "install", sep = " ")
  shell(shQuote(npmInstallCommand, type = c("cmd")))  
}

startApi <- function(workDirectory="") {
  jdssatPath = paste(workDirectory, "\\jdssat", sep = "")
  #start api
  fullServerPath = paste(jdssatPath, "\\jdssat-server.js", sep = "")
  startAPICommand <- paste("node", fullServerPath)
  shell(shQuote(startAPICommand, type = c("cmd")))  
}

experiments <- function(crop="") {
  url <- paste("http://localhost:3000/api/experiments/", crop, sep = "")
  response <- GET(url)
  result <- content(response, "text")
  #json <- toJSON(result, pretty=TRUE)
  return(result)
}

treatments <- function(crop="", experiments=NULL) {
  expJson <- toJSON(experiments)
  url <- paste("http://localhost:3000/api/treatments/", crop, "/", expJson, sep = "")
  response <- GET(url)
  result <- content(response, "text")
  #json <- toJSON(result, pretty=TRUE)
  return(result)
}

getOutputFiles <- function(crop="") {
  url <- paste("http://localhost:3000/api/outfiles/", crop, sep = "")
  response <- GET(url)
  result <- content(response, "text")
  #json <- toJSON(result, pretty=TRUE)
  return(result)
}

openExternalTool <- function(tool="") {
  url <- paste(baseUrl, "tool/?tool=", tool, sep = "")
  response <- GET(url)
  result <- content(response, "raw")
  return(result)
}

configuration <- function(config="") {
  url <- paste(baseUrl, "config/?config=", config, sep = "")
  response <- GET(url)
  result <- content(response, "text")
  return(result)
}

runSimulation <- function(crop="", experiments) {
  experimentsJson <- toJSON(experiments)
  url <- paste(baseUrl, "runSimulation/", crop, "/", experimentsJson, sep = "")
  URLEncoded = URLencode(url, reserved = FALSE, repeated = FALSE)
  response <- GET(URLEncoded)
  result <- content(response, "text")
  return(result)
}

getOutputResult <- function(crop="", file="") {
  url <- paste(baseUrl, "out/", crop, "/", file, sep = "")
  response <- GET(url)
  result <- content(response, "text")
  return(result)
}

outputResult <- function(filep="") {
  if(!file.exists(filep)) {
    print("Forcing return from read_file...") 
    return(NULL)
  }
  print(paste0("Loading file: ",filep))
  suppressMessages({fOUT = readLines(filep)})
  nottrashLines = grep(pattern = '[^ ]', fOUT)[!(grep(pattern = '[^ ]', fOUT) %in% 
                                                   c(grep(pattern = '^\\$', fOUT), 
                                                     grep(pattern = '^\\*', fOUT),
                                                     grep(pattern = '.+:', fOUT),
                                                     grep(pattern = '^\\!', fOUT)))]
  treatmentsLines<-grep(pattern = '.+TREATMENT', fOUT)
  treatments<-sapply(treatmentsLines,function(v){scan(text = fOUT[v], what = "")[2]})
  fOUT_clean = fOUT[nottrashLines]
  print(head(fOUT_clean, n=7))
  trtHeaders=which(grepl(pattern = '^@', fOUT_clean))
  print(class(trtHeaders))
  if(length(trtHeaders)<=0) {
    print("Forcing return from read_file... No Headers") 
    return(NULL)
  }
  varN = lapply(trtHeaders, function(i) {
    make.names(scan(text = gsub(pattern = '^@', 
                                replacement = '',fOUT_clean[i]),
                    what = character()))
  })
  pos <- c(trtHeaders,length(fOUT_clean)+1)
  tmpA = lapply(seq(1,length(pos)-1), function(w) {
    res<-read.table(text = fOUT_clean[seq(from=pos[w], length.out = pos[w+1]-pos[w])],
                    skip = 1, 
                    col.names = varN[[w]],
                    na.strings = c('-99', '-99.0', '-99.'))
    res$TRT <- treatments[w]
    res
  })
  data <- do.call("rbind",tmpA)
  data <- data[c('TRT',varN[[1]])]
  print(head(data))
  return(data)
}