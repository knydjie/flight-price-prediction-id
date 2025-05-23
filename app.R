# Import libraries
library(shiny)
library(profvis)
library(shinythemes)
library(data.table)
library(RCurl)
library(randomForest) 
library(rpart)       # performing regression trees
library(rpart.plot)  # plotting regression trees
library(ipred)       # bagging
library(caret)       # bagging
library(parallelMap)
library(parallel)
library(doParallel)
#runApp('D:/UPH/SMT 13/TA2/R Shiny/PrediksiHargaTiketPesawat')
# ##### MODELS #####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

rt_cgksub = readRDS("rt_cgksub.rda")
brt_cgksub = readRDS("brt_cgksub23.rda")
rf_cgksub = readRDS("rf_cgksub.rda")

rt_cgkmdc = readRDS("rt_cgkmdc.rda")
brt_cgkmdc = readRDS("brt_cgkmdc.rda")
rf_cgkmdc = readRDS("rf_cgkmdc.rda")

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

##### UI SUB #####
sidebarPanelSUB <- sidebarPanel(h3("INPUT PARAMETERS"),
                                # AIRLINE
                                selectInput("airline", label = "Airline:", 
                                            choices = list("Batik Air" = "Batik Air",
                                                           "Citilink" = "Citilink",
                                                           "Garuda Indonesia" = "Garuda Indonesia",
                                                           "Lion Air" = "Lion Air",
                                                           "NAM Air" = "NAM Air",
                                                           "Super Air Jet" = "Super Air Jet"), 
                                            selected = "Batik Air"),
                                
                                # DEPARTURE
                                fluidRow(
                                  column(5,
                                         selectInput("departure_hour", label = "Departure:", 
                                                     choices = list("00"="0", "01"="1",
                                                                    "02"="2", "03"="3",
                                                                    "04"="4", "05"="5", 
                                                                    "06"="6", "07"="7", 
                                                                    "08"="8", "09"="9", 
                                                                    "10"="10", "11"="11", 
                                                                    "12"="12", "13"="13",
                                                                    "14"="14", "15"="15",
                                                                    "16"="16", "17"="17",
                                                                    "18"="18", "19"="19",
                                                                    "20"="20", "21"="21",
                                                                    "22"="22", "23"="23"),
                                                     selected = "7"
                                         )),
                                  column(2, h3(":")),
                                  column(5,
                                         selectInput("departure_minute", label = " ", 
                                                     choices = list("00"="0", "05"="5",
                                                                    "10"="10", "15"="15",
                                                                    "20"="20", "25"="25", 
                                                                    "30"="30", "35"="35", 
                                                                    "40"="40", "45"="45", 
                                                                    "50"="50", "55"="55"),
                                                     selected = "30"
                                         ))),
                                
                                # ARRIVAL
                                fluidRow(
                                  column(5,
                                         selectInput("arrival_hour", label = "Arrival:", 
                                                     choices = list("00"="0", "01"="1",
                                                                    "02"="2", "03"="3",
                                                                    "04"="4", "05"="5", 
                                                                    "06"="6", "07"="7", 
                                                                    "08"="8", "09"="9", 
                                                                    "10"="10", "11"="11", 
                                                                    "12"="12", "13"="13",
                                                                    "14"="14", "15"="15",
                                                                    "16"="16", "17"="17",
                                                                    "18"="18", "19"="19",
                                                                    "20"="20", "21"="21",
                                                                    "22"="22", "23"="23"),
                                                     selected = "9"
                                         )),
                                  column(2, h3(":")),
                                  column(5,
                                         selectInput("arrival_minute", label = " ", 
                                                     choices = list("00"="0", "05"="5",
                                                                    "10"="10", "15"="15",
                                                                    "20"="20", "25"="25", 
                                                                    "30"="30", "35"="35", 
                                                                    "40"="40", "45"="45", 
                                                                    "50"="50", "55"="55"),
                                                     selected = "0"
                                         ))),
                                
                                # TRANSIT
                                sliderInput("transit", "Transit:",
                                            min = 0, max = 1,
                                            value = 0, step = 1),
                                
                                # DAY OF WEEK
                                selectInput("day_of_week", label = "Day of Week:", 
                                            choices = list("Sun" = "1",
                                                           "Mon" = "2",
                                                           "Tue" = "3",
                                                           "Wed" = "4",
                                                           "Thu" = "5",
                                                           "Fri" = "6",
                                                           "Sat" = "7"
                                            ),
                                            selected = "2"),
                                
                                # HOLIDAY
                                selectInput("holiday", label = "Holiday:", 
                                            choices = list("Yes" = "TRUE",
                                                           "No" = "FALSE"),
                                            selected = "FALSE"),
                                
                                # DAYS LEFT UNTIL DEPARTURE
                                textInput("days_left_until_departure", "Days Left Until Departure:", value = 23),
                                
                                # DURATION
                                #textInput("duration", "Duration:", value = 1.5),
                                
                                # SCRAPE DAY
                                selectInput("scrape_day", label = "Today:", 
                                            choices = list("Sun" = "1",
                                                           "Mon" = "2",
                                                           "Tue" = "3",
                                                           "Wed" = "4",
                                                           "Thu" = "5",
                                                           "Fri" = "6",
                                                           "Sat" = "7"
                                            ),
                                            selected = "Mon"),
                                
                                # SCRAPE HOLIDAY
                                selectInput("scrape_holiday", label = "Holiday (Today):", 
                                            choices = list("Yes" = "TRUE",
                                                           "No" = "FALSE"),
                                            selected = "TRUE"),
                                
                                # SUBMIT BUTTON
                                actionButton("submitbutton", "Submit", class = "btn btn-primary")
) # sidebarPanel

# mainPanelSUB <- mainPanel(h3("OUTPUT:"), verbatimTextOutput("txtout"))
mainPanelSUB <- mainPanel(
  #tags$label(h3('Duration Calc')), verbatimTextOutput("txtout"),
  tags$label(h3('Status/Output')), # Status/Output Text Box
  verbatimTextOutput('contents'),
  tableOutput('tabledata') # Prediction results table
  
)

#### UI MDC ####
sidebarPanelMDC <- sidebarPanel(h3("INPUT PARAMETERS"),
                                # AIRLINE
                                selectInput("airline_cgkmdc", label = "Airline:", 
                                            choices = list("Batik Air" = "Batik Air",
                                                           "Citilink" = "Citilink",
                                                           "Garuda Indonesia" = "Garuda Indonesia",
                                                           "Lion Air" = "Lion Air"), 
                                            selected = "Batik Air"),
                                
                                # DEPARTURE
                                fluidRow(
                                  column(5,
                                         selectInput("departure_hour_cgkmdc", label = "Departure:", 
                                                     choices = list("00"="0", "01"="1",
                                                                    "02"="2", "03"="3",
                                                                    "04"="4", "05"="5", 
                                                                    "06"="6", "07"="7", 
                                                                    "08"="8", "09"="9", 
                                                                    "10"="10", "11"="11", 
                                                                    "12"="12", "13"="13",
                                                                    "14"="14", "15"="15",
                                                                    "16"="16", "17"="17",
                                                                    "18"="18", "19"="19",
                                                                    "20"="20", "21"="21",
                                                                    "22"="22", "23"="23"),
                                                     selected = "7"
                                         )),
                                  column(2, h3(":")),
                                  column(5,
                                         selectInput("departure_minute_cgkmdc", label = " ", 
                                                     choices = list("00"="0", "05"="5",
                                                                    "10"="10", "15"="15",
                                                                    "20"="20", "25"="25", 
                                                                    "30"="30", "35"="35", 
                                                                    "40"="40", "45"="45", 
                                                                    "50"="50", "55"="55"),
                                                     selected = "30"
                                         ))),
                                
                                # ARRIVAL
                                fluidRow(
                                  column(5,
                                         selectInput("arrival_hour_cgkmdc", label = "Arrival:", 
                                                     choices = list("00"="0", "01"="1",
                                                                    "02"="2", "03"="3",
                                                                    "04"="4", "05"="5", 
                                                                    "06"="6", "07"="7", 
                                                                    "08"="8", "09"="9", 
                                                                    "10"="10", "11"="11", 
                                                                    "12"="12", "13"="13",
                                                                    "14"="14", "15"="15",
                                                                    "16"="16", "17"="17",
                                                                    "18"="18", "19"="19",
                                                                    "20"="20", "21"="21",
                                                                    "22"="22", "23"="23"),
                                                     selected = "9"
                                         )),
                                  column(2, h3(":")),
                                  column(5,
                                         selectInput("arrival_minute_cgkmdc", label = " ", 
                                                     choices = list("00"="0", "05"="5",
                                                                    "10"="10", "15"="15",
                                                                    "20"="20", "25"="25", 
                                                                    "30"="30", "35"="35", 
                                                                    "40"="40", "45"="45", 
                                                                    "50"="50", "55"="55"),
                                                     selected = "0"
                                         ))),
                                
                                # TRANSIT
                                sliderInput("transit_cgkmdc", "Transit:",
                                            min = 0, max = 4,
                                            value = 2, step = 1),
                                
                                # DAY OF WEEK
                                selectInput("day_of_week_cgkmdc", label = "Day of Week:", 
                                            choices = list("Sun" = "1",
                                                           "Mon" = "2",
                                                           "Tue" = "3",
                                                           "Wed" = "4",
                                                           "Thu" = "5",
                                                           "Fri" = "6",
                                                           "Sat" = "7"
                                            ),
                                            selected = "2"),
                                
                                # HOLIDAY
                                selectInput("holiday_cgkmdc", label = "Holiday:", 
                                            choices = list("Yes" = "TRUE",
                                                           "No" = "FALSE"),
                                            selected = "FALSE"),
                                
                                # DAYS LEFT UNTIL DEPARTURE
                                textInput("days_left_until_departure_cgkmdc", "Days Left Until Departure:", value = 23),
                                
                                # DURATION
                               # textInput("duration_cgkmdc", "Duration:", value = 1.5),
                                
                                # SCRAPE DAY
                                selectInput("scrape_day_cgkmdc", label = "Today:", 
                                            choices = list("Sun" = "1",
                                                           "Mon" = "2",
                                                           "Tue" = "3",
                                                           "Wed" = "4",
                                                           "Thu" = "5",
                                                           "Fri" = "6",
                                                           "Sat" = "7"
                                            ),
                                            selected = "Mon"),
                                
                                # SCRAPE HOLIDAY
                                selectInput("scrape_holiday_cgkmdc", label = "Holiday (Today):", 
                                            choices = list("Yes" = "TRUE",
                                                           "No" = "FALSE"),
                                            selected = "TRUE"),
                                
                                # SUBMIT BUTTON
                                actionButton("submitbutton_cgkmdc", "Submit", class = "btn btn-primary")
) # sidebarPanel

mainPanelMDC <- mainPanel(
  #tags$label(h3('Duration Calc')), verbatimTextOutput("txtout_cgkmdc"),
  tags$label(h3('Status/Output')), # Status/Output Text Box
  verbatimTextOutput('contents_cgkmdc'),
  tableOutput('tabledata_cgkmdc') # Prediction results table
  
)

#### UI ALL ####

ui <- fluidPage(theme = shinytheme("lumen"),
                navbarPage(
                  "Prediksi Harga Tiket Pesawat",
                  tabPanel("Jakarta-Surabaya", sidebarPanelSUB, mainPanelSUB), #tabPanel
                  tabPanel("Jakarta-Manado", sidebarPanelMDC, mainPanelMDC) # tabPanel
                ) # navbarPage
) # fluidPage

#### SERVER ####
server <- function(input, output, session) {
  
  # Input Data
  datasetInput <- reactive({  
    
    # data frame
    df <- data.frame(
      Name = c("airline", "departure", "arrival", "transit", "day_of_week", 
               "holiday", 
               "days_left_until_departure", "duration", "scrape_day",
               "scrape_holiday"
      ),
      Value = as.character(c(input$airline, (as.numeric(input$departure_hour)*60+as.numeric(input$departure_minute))/1440, 
                             (as.numeric(input$arrival_hour)*60+as.numeric(input$arrival_minute))/1440, input$transit, input$day_of_week, 
                             as.logical(input$holiday),
                             input$days_left_until_departure, (as.numeric(input$arrival_hour)*60+as.numeric(input$arrival_minute)-(as.numeric(input$departure_hour)*60+as.numeric(input$departure_minute)))/60, input$scrape_day,
                             as.logical(input$scrape_holiday)
      )),
      stringsAsFactors = FALSE)
    
    price <- ""
    df <- rbind(df, price)
    input <- transpose(df)
    write.table(input,"input.csv", sep=",", quote = FALSE, row.names = FALSE, col.names = FALSE)
    
    test <- read.csv(paste("input", ".csv", sep=""), header = TRUE)
    
    test$airline <- factor(test$airline, levels = c("Batik Air", "Citilink", "Garuda Indonesia", "Lion Air", "NAM Air", "Super Air Jet"))
    test$day_of_week <- factor(test$day_of_week, levels = c(1,2,3,4,5,6,7))
    test$scrape_day <- factor(test$scrape_day, levels = c(1,2,3,4,5,6,7))
    
    Output <- data.frame("Regression Tree"=formatC(predict(rt_cgksub,test), format = "d", big.mark = ","), 
                         "Bagging Regression Tree"=formatC(predict(brt_cgksub,test), format = "d", big.mark = ","),
                         "Random Forest"=formatC(predict(rf_cgksub,test), format = "d", big.mark = ","))
    #Output <- data.frame(Prediction=predict(m1,test))
    
    print(Output)
    
  })
  datasetInput_cgkmdc <- reactive({  
    
    # data frame
    df <- data.frame(
      Name = c("airline", "departure", "arrival", "transit", "day_of_week", 
               "holiday", 
               "days_left_until_departure", "duration", "scrape_day",
               "scrape_holiday"
      ),
      Value = as.character(c(input$airline_cgkmdc, (as.numeric(input$departure_hour_cgkmdc)*60+as.numeric(input$departure_minute_cgkmdc))/1440, 
                             (as.numeric(input$arrival_hour_cgkmdc)*60+as.numeric(input$arrival_minute_cgkmdc))/1440, input$transit_cgkmdc, input$day_of_week_cgkmdc, 
                             as.logical(input$holiday_cgkmdc),
                             input$days_left_until_departure_cgkmdc, (as.numeric(input$arrival_hour_cgkmdc)*60+as.numeric(input$arrival_minute_cgkmdc)-(as.numeric(input$departure_hour_cgkmdc)*60+as.numeric(input$departure_minute_cgkmdc)))/60, input$scrape_day_cgkmdc,
                             as.logical(input$scrape_holiday_cgkmdc)
      )),
      stringsAsFactors = FALSE)
    
    price <- ""
    df <- rbind(df, price)
    input <- transpose(df)
    write.table(input,"input.csv", sep=",", quote = FALSE, row.names = FALSE, col.names = FALSE)
    
    test <- read.csv(paste("input", ".csv", sep=""), header = TRUE, stringsAsFactors = FALSE) #tambah stringAsFactors
    
    test$airline <- factor(test$airline, levels = c("Batik Air", "Citilink", "Garuda Indonesia"))
    test$day_of_week <- factor(test$day_of_week, levels = c(1,2,3,4,5,6,7))
    test$scrape_day <- factor(test$scrape_day, levels = c(1,2,3,4,5,6,7))
    
    Output <- data.frame("Regression Tree"=formatC(predict(rt_cgkmdc,test), format = "d", big.mark = ","), 
                         "Bagging Regression Tree"=formatC(predict(brt_cgkmdc,test), format = "d", big.mark = ","),
                         "Random Forest"=formatC(predict(rf_cgkdmc,test), format = "d", big.mark = ","))
    print(Output)
    
  })
  
  # Status/Output Text Box
  output$contents <- renderPrint({
    if (input$submitbutton>0) { 
      isolate("Calculation complete.") 
    } else {
      return("Server is ready for calculation.")
    }
  })
  output$contents_cgkmdc <- renderPrint({
    if (input$submitbutton_cgkmdc>0) { 
      isolate("Calculation complete.") 
    } else {
      return("Server is ready for calculation.")
    }
  })
  
  # Prediction results table
  output$tabledata <- renderTable({
    if (input$submitbutton>0) { 
      isolate(datasetInput()) 
    } 
  })
  output$tabledata_cgkmdc <- renderTable({
    if (input$submitbutton_cgkmdc>0) { 
      isolate(datasetInput_cgkmdc()) 
    } 
  })
  
  # Duration Calc
  output$txtout <- renderText({paste(
    (as.numeric(input$arrival_hour)*60+as.numeric(input$arrival_minute)-(as.numeric(input$departure_hour)*60+as.numeric(input$departure_minute)))/60
  )
  })
  output$txtout_cgkmdc <- renderText({paste(
    (as.numeric(input$arrival_hour_cgkmdc)*60+as.numeric(input$arrival_minute_cgkmdc)-(as.numeric(input$departure_hour_cgkmdc)*60+as.numeric(input$departure_minute_cgkmdc)))/60
  )
  })
  
}

#### Create Shiny object ####
shinyApp(ui = ui, server = server)

# #################
# #
# # This is a Shiny web application. You can run the application by clicking
# # the 'Run App' button above.
# #
# # Find out more about building applications with Shiny here:
# #
# #    http://shiny.rstudio.com/
# #
# 
# library(shiny)
# 
# # Define UI for application that draws a histogram
# ui <- fluidPage(
#   
#   # Application title
#   titlePanel("Old Faithful Geyser Data"),
#   
#   # Sidebar with a slider input for number of bins 
#   sidebarLayout(
#     sidebarPanel(
#       sliderInput("bins",
#                   "Number of BINSSS:",
#                   min = 1,
#                   max = 50,
#                   value = 30)
#     ),
#     
#     # Show a plot of the generated distribution
#     mainPanel(
#       plotOutput("distPlot")
#     )
#   )
# )
# 
# # Define server logic required to draw a histogram
# server <- function(input, output) {
#   
#   output$distPlot <- renderPlot({
#     # generate bins based on input$bins from ui.R
#     x    <- faithful[, 2]
#     bins <- seq(min(x), max(x), length.out = input$bins + 1)
#     
#     # draw the histogram with the specified number of bins
#     hist(x, breaks = bins, col = 'darkgray', border = 'white')
#   })
# }
# 
# # Run the application 
# shinyApp(ui = ui, server = server)
