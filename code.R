#to make sure you have cutting edge dev of rCharts
#require(devtools)
#install_github("rCharts","ramnathv",ref="dev")

require(rCharts)
options(viewer = NULL)

rCharts_pivot <- setRefClass(
  "rCharts_pivot",
  contains = "rCharts",
  methods = list(
    initialize = function(){
      callSuper(); 
    },
    render = function (chartId = NULL, cdn = F, static = T, standalone = F) {
      params$dom <<- chartId %||% params$dom
      template = read_file(templates$page)
      assets = Map(
        "c",
        get_assets(
          LIB, static = static, cdn = cdn),
        html_assets
      )
      html = render_template(
        template,
        list(
          params = params,
          assets = assets, 
          chartId = params$dom,
          script = .self$html(params$dom),
          CODE = srccode,
          lib = LIB$name,
          tObj = tObj,
          container = container
        ), 
        partials = list(
          chartDiv = templates$chartDiv,
          afterScript = templates$afterScript)
      )
      html = gsub(x=html,pattern='#!(.*?)!#',replacement="\\1")
      
      return(html)
    })
)

pTab <- rCharts_pivot$new()
pTab$setLib(".")
pTab$templates$page = system.file("rChart.html",package = "rCharts")
pTab$setTemplate(chartDiv = "<div></div>")

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
     pseudoFunction= "#!function(row){
       var date = new Date(row.invoice_date);
       return pivot.utils().padLeft((date.getMonth() + 1),2,'0')
      }!#"
    ),
  list(name= 'invoice_yyyy_mm', type= 'string', filterable= TRUE, pseudo= TRUE,
       pseudoFunction= "#!function(row) {
       var date = new Date(row.invoice_date);
       return date.getFullYear() + '_' + pivot.utils().padLeft((date.getMonth() + 1),2,'0')
       }!#"
      ),
  list(name= 'invoice_yyyy', type= 'string', filterable= TRUE, pseudo= TRUE, columnLabelable= TRUE,
       pseudoFunction= "#!function(row) {
        return new Date(row.invoice_date).getFullYear()
       }!#"
  ),
  list(name= 'age_bucket', type= 'string', filterable= TRUE, columnLabelable= TRUE, pseudo= TRUE, dataSource= 'last_payment_date', pseudoFunction= "#!function ageBucket(row, field){
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
       }!#"),
      
  
  # summary fields
  list(name= 'billed_amount',     type= 'float',  rowLabelable= FALSE, summarizable= 'sum', displayFunction= "#!function(value){ return accounting.formatMoney(value)}!#"),
  list(name= 'payment_amount',    type= 'float',  rowLabelable= FALSE, summarizable= 'sum', displayFunction= "#!function(value){ return accounting.formatMoney(value)}!#"),
  list(name= 'balance', type= 'float', rowLabelable= FALSE, pseudo= TRUE,
       pseudoFunction= "#! function(row){ return row.billed_amount - row.payment_amount }!#",
       summarizable= 'sum', displayFunction= "#!function(value) { return accounting.formatMoney(value) }!#"
  ),
  list(name= 'last_payment_date',  type= 'date',  filterable= TRUE)
))
#to set up an initial view as in original
pTab$set(
  filters = list(employer= 'Acme Corp'),
  rowLabels = "city",
  summaries = c("billed_amount", "payment_amount")
)
#use the data from the original but feed through rCharts
#we will use json so in pivot.js json:data rather than url: or csv:
pTab$set(data = pivotData)
pTab
