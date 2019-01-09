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

