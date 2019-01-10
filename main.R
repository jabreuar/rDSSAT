source('rDSSAT/rDSSAT.R', local = TRUE)

initJdssat <- install("c:\\temp\\dssat")
start <- startApi("c:\\temp\\dssat")
opentool <- openExternalTool("XBuild/XBuild.exe")
experimentsResponse <- experiments("Barley")
outfilesResponse <- getOutputFiles("Barley")

experimentsResponseObj <- fromJSON(txt=experimentsResponse)
document1 <- fromJSON(txt=outfilesResponse)

treatmentsSelected <- c("IEBR8201.BAX")
treatmentsResponse <- treatments("Barley", treatmentsSelected)
treatmentsResponseObj <- fromJSON(txt=treatmentsResponse)

configurationResponse <- configuration("path")
document3 <- toJSON(configurationResponse)

configurationResponse <- configuration("platform")
document4 <- toJSON(configurationResponse)

configurationResponse <- configuration("version")
document5 <- toJSON(configurationResponse)


simulation <- runSimulation("Barley", treatmentsResponseObj[1,])

outputResult = outputResult("/DSSAT47/Barley/PlantGro.OUT")

