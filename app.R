#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(plotly)
library(RMariaDB)
library(Rcpp)
library(glue)
library(DT)
library(dplyr)
library(tidyr)
library(htmltools)
library(reactable)
library(shinybusy)


# Define UI for application that draws a histogram
ui <- navbarPage("Next Pitch",

    # Application title
    

   
    tabPanel("Simulator",
        # Show a plot of the generated distribution
        tabPanel("simulator",
          column(width=4,
          selectizeInput('pitcher_select', 'Select a Pitcher:', choices = c("Stephen Strasburg", "Max Scherzer", "Jose Berrios"), selected = NULL, multiple = FALSE,
                         options = NULL),
           #plotOutput("diamond", click = "diamond_click"),
           #verbatimTextOutput("info"),
           #verbatimTextOutput("testing"),
           plotly::plotlyOutput("diamond_plotly")
          )
          ,
          column(width = 3,
                 radioButtons("balls", label = h3("Balls"),
                              choices = list("0" = 0, "1" = 1, "2" = 2, "3" = 3), 
                              selected = NULL),
          radioButtons("strikes", label = h3("Strikes"),
                       choices = list("0" = 0, "1" = 1, "2" = 2), 
                       selected = NULL),
          radioButtons("outs", label = h3("Outs"),
                       choices = list("0" = 0, "1" = 1, "2" = 2), 
                       selected = NULL),
          actionButton("runit",label="Run Algorithm",  icon("running"), 
                       style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
          )
          
          ,
          column(width = 5,
                h3("Reserved Space for Model Output"),
                #dataTableOutput("outputtable"),
                reactableOutput("pitchprob"),
                h3("Current Parameters"),
                verbatimTextOutput("parms"),
                verbatimTextOutput("parms2"),
                verbatimTextOutput("parms3"),
                verbatimTextOutput("parms4")
                )
        ),
        
    ),
    tabPanel("Help",
             # Show a plot of the generated distribution
             mainPanel(
               
             )
             
    )
    
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  

  
  colorvec <- reactiveValues(colors =  c("black","black","black","black","black"))
  #colorvec <- reactive({
  #  c("black","black","black","black","black")
  #})
    
  observeEvent(input$runit,{
    
    #show_modal_spinner()
               print("you clicked runnit")
    
    
    
  
      
      db_name <- "stats_main"
      db_user <- "admin"
      db_password <- "cSe6242!"
      db_host <- "baseball.cfape4saa0af.us-east-1.rds.amazonaws.com"
      db_port <- 3306
      
      balls <- isolate(input$balls)
      strikes <- isolate(input$strikes)
      outs <- isolate(input$outs)
      
    
      
      if (colorvec$colors[2] == "red")
      {
        runneronfirst = 1
      }
      else{runneronfirst = 0}
      
      if (colorvec$colors[3] == "red")
      {
        runneronsecond = 1
      }
      else{runneronsecond = 0}
      if (colorvec$colors[4] == "red")
      {
        runneronthird = 1
      }
      else{runneronthird = 0}
      
      
      
      print('runner first')
      print(runneronfirst)
      
      con <- dbConnect(
        MariaDB(),
        dbname = db_name,
        username = db_user,
        password = db_password,
        host = db_host,
        port = db_port
      )
    
      
      sql <- glue_sql("
      SELECT *
      FROM predictions
      WHERE balls = {balls} and strikes = {strikes} and outs = {outs} 
      and runner1 = {runneronfirst} and runner2 = {runneronsecond} and runner3 = {runneronthird}
    ", .con = con)
      rs <- dbSendQuery(con, sql)
      d1 <- dbFetch(rs) # extract data
      dbHasCompleted(rs)
      
      dbClearResult(rs)
      dbListTables(con)
      # clean up
      dbDisconnect(con)
      
      #print(d1)
      
      df.long <- pivot_longer(d1, cols=10:14, names_to = "Pitch", values_to = "Probability") %>%
        select(Pitch, Probability)
      
      bar_chart <- function(label, width = "100%", height = "16px", fill = "#00bfc4", background = NULL) {
        bar <- div(style = list(background = fill, width = width, height = height))
        chart <- div(style = list(flexGrow = 1, marginLeft = "8px", background = background), bar)
        div(style = list(display = "flex", alignItems = "center"), label, chart)
      }
      
      
      
      #output$outputtable <- DT::renderDataTable({
      #  DT::datatable(df.long)
        
      output$pitchprob <- renderReactable({
        
        reactable(df.long,
                  columns = list(
                    Probability = colDef(name = "Probability", align = "left", cell = function(value) {
                      width <- paste0(value /.01, "%")
                      bar_chart(value, width = width, background = "#e1e1e1")
                    })
                  )
        )
        
        })
      
   # })
    
               
            
      #remove_modal_spinner()             
               
}
               )
               
  
   
      
    output$diamond_plotly <- renderPlotly({
      
      bases =data.frame(x=c(0, 30, 0, -30, 0),
                        y=c(0,75, 150, 75, 0)
      )
      #print (colorvec())
      #colorsel <- c("black","black","red","red","black")
      bases$colorsel <- colorvec$colors

      
    
      fig <- plot_ly(data = bases, x = ~x, y = ~y, source = "diamond_c",
                     
                     marker = list(size = 14,
                                   symbol = 'square',
                                   color = ~colorsel,
                                   line = list(color = 'black',
                                               width = 2))) %>%
        layout(xaxis = list(title = '',
                            showgrid = F,
                            showline = FALSE,
                            showticklabels = FALSE,
                            fixedrange = TRUE,
                            zerolinecolor = '#ffff') 
        ) %>%
        layout(yaxis = list(title = '',
                            showgrid = F,
                            showline = FALSE,
                            showticklabels = FALSE,
                            fixedrange = TRUE,
                            zerolinecolor = '#ffff')
        ) %>%
        config(displayModeBar = FALSE)
      
      fig <- fig %>% add_trace(name = 'trace 0',mode = 'lines') %>%  config(displayModeBar = FALSE)
      
      print("did i get here")
      fig
      
      
      
      
      
 
      
      
      
      
      
    })
    
    
    observeEvent(event_data("plotly_click", source = "diamond_c", priority = "event"),{
      
      event.data <- event_data("plotly_click", source = "diamond_c", priority = "event")
      
      print(event.data)

    
        if (event.data$x == 30 &&  event.data$y == 75)
        {
          tt <- colorvec$colors
          
          #print(tt[2])
          if (tt[2] == "black")
          {
            tt[2]<- "red"
          }
          else
          {
            tt[2] <-"black"
          }
          #tempcolor <- c("black","red","black","black","black")
          colorvec$colors <- tt}

        else if (event.data$x == 0 &&  event.data$y == 150)
        {
          tt <- colorvec$colors
          
          #print(tt[2])
          if (tt[3] == "black")
          {
            tt[3]<- "red"
          }
          else
          {
            tt[3] <-"black"
          }
          #tempcolor <- c("black","red","black","black","black")
          colorvec$colors <- tt}

        else if (event.data$x == -30 &&  event.data$y == 75)
        {
          tt <- colorvec$colors
          
          #print(tt[2])
          if (tt[4] == "black")
          {
            tt[4]<- "red"
          }
          else
          {
            tt[4] <-"black"
          }
          #tempcolor <- c("black","red","black","black","black")
          colorvec$colors <- tt}

      

    })
    
    observe({
      
      print("in the observe")
      abc <- (paste0("strikes: ", input$strikes, "  ", "balls: ",input$balls, "  ", "outs: ",input$outs))
      output$parms <- renderPrint(abc)
      
      if (colorvec$colors[2] == "red")
      {
      output$parms2 <- renderPrint("Runner on First")
      }
      else { output$parms2 <- renderPrint("")}
      
      if (colorvec$colors[3] == "red")
      {
        output$parms3 <- renderPrint("Runner on Second")
      }
      else { output$parms3 <- renderPrint("")}
      if (colorvec$colors[4] == "red")
      {
        output$parms4 <- renderPrint("Runner on Third")
      }
      else { output$parms4 <- renderPrint("")}
      
      })
    
 
}
# Run the application 
shinyApp(ui = ui, server = server)
