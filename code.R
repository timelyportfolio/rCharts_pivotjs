#to make sure you have cutting edge dev of rCharts
#require(devtools)
#install_github("rCharts","ramnathv",ref="dev")

require(rCharts)

pTab <- rCharts$new()
pTab$setLib(".")
pTab$setTemplate(
  afterScript = "<script></script>"
)
pTab