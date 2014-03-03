#to make sure you have cutting edge dev of rCharts
#require(devtools)
#install_github("rCharts","ramnathv",ref="dev")


toObj2 <- function(x){
  gsub('\"#!([.,[space]]*?)!#\"', "\\1", x)
}

require(rCharts)
options(viewer = NULL)

pTab <- rCharts$new()
pTab$setLib(".")
pTab$setTemplate(chartDiv = "<div></div>")
pTab$setTemplate(
  afterScript = "<script></script>"
)

#get data like you would in R rather than
#using handy url feature of pivot.js
pivotData <- read.csv("./lib/csv/demo.csv",stringsAsFactors=F)

pTab$set(
  fields = list(
    # filterable fields
    list(name= 'last_name',         type= 'string', filterable= TRUE, filterType= 'regexp'),
    list(name= 'first_name',        type= 'string', filterable= TRUE),
    list(name= 'state',             type= 'string', filterable= TRUE),
    list(name= 'employer',          type= 'string', filterable= TRUE),
    list(name= 'city',              type= 'string', filterable= TRUE),
    list(name= 'invoice_date',      type= 'date',   filterable= TRUE),
    
    # psuedo fields
    list(name= 'invoice_mm',  type= 'string', filterable= TRUE, pseudo= TRUE,
     pseudoFunction= "#! function(row){
       var date = new Date(row.invoice_date);
       return pivot.utils().padLeft((date.getMonth() + 1),2,'0')
      } !#"
    )
  )
)

,
list(name= 'invoice_yyyy_mm', type= 'string', filterable= TRUE, pseudo= TRUE,
     pseudoFunction= " function((row) {
     var date = new Date(row.invoice_date);
     return date.getFullYear() + '_' + pivot.utils().padLeft((date.getMonth() + 1),2,'0')
     }"
    ),
list(name= 'invoice_yyyy', type= 'string', filterable= TRUE, pseudo= TRUE, columnLabelable= TRUE,
     pseudoFunction= " function((row) {
     return new Date(row.invoice_date).getFullYear() )}"
),
list(name= 'age_bucket', type= 'string', filterable= TRUE, columnLabelable= TRUE, pseudo= TRUE, dataSource= 'last_payment_date', pseudoFunction= "
     function ageBucket(row, field){
     var age = Math.abs(((new Date().getTime()) - row[field.dataSource])/1000/60/60/24);
     switch (true){
     case (age < 31):
     return '000 - 030'
     case (age < 61):
     return '031 - 060'
     case (age < 91):
     return '061 - 090'
     case (age < 121):
     return '091 - 120'
     default:
     return '121+'
     }
     };"),
    

# summary fields
list(name= 'billed_amount',     type= 'float',  rowLabelable= FALSE, summarizable= 'sum', displayFunction= " function(value){ return accounting.formatMoney(value)}"),
list(name= 'payment_amount',    type= 'float',  rowLabelable= FALSE, summarizable= 'sum', displayFunction= " function(value){ return accounting.formatMoney(value)}"),
list(name= 'balance', type= 'float', rowLabelable= FALSE, pseudo= TRUE,
     pseudoFunction= " function(row){ return row.billed_amount - row.payment_amount ) }",
     summarizable= 'sum', displayFunction= " function(value) { return accounting.formatMoney(value)) } "
),
list(name= 'last_payment_date',  type= 'date',  filterable= TRUE)


pTab$params$data = pivotData
pTab
