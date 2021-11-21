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
library(shinyjs)


# Define UI for application that draws a histogram
ui <- navbarPage("Next Pitch",

    # Application title
    

   
    tabPanel("Simulator",
        # Show a plot of the generated distribution
        tabPanel("simulator",
         mainPanel(
          column(width=8,
          selectizeInput('pitcher_select', 'Select a Pitcher:', choices = c("Jon Lester"), selected = NULL, multiple = FALSE,
                         options = NULL),
          selectizeInput('previous_pitch', 'Select a Previous Pitch:', choices = c("None" = 0, "Fastball"=1, "Offspeed" = 2, "Breaking" = 3), selected = NULL, multiple = FALSE,
                         options = NULL),
           #plotOutput("diamond", click = "diamond_click"),
           #verbatimTextOutput("info"),
           #verbatimTextOutput("testing"),
           plotly::plotlyOutput("diamond_plotly")
          )
          ,
          column(
            
            
            width = 4,
            
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
         )
          
          ,
         sidebarPanel(
          #column(width = 5,
                #h3("Reserved Space for Model Output"),
                #dataTableOutput("outputtable"),
                uiOutput("initial_message"),
                uiOutput("initial_message2"),
                uiOutput("pitchprobtitle"),
                reactableOutput("pitchprob"),
                br(),
                br(),
                plotlyOutput("example_heat"),
                br(),
                br(),
                br(),
                uiOutput("modelparms"),
                uiOutput("modelparmsballs"),
                uiOutput("modelparmsstrikes"),
                uiOutput("modelparmsouts"),
                uiOutput("modelparmsprev")
                #h3("This is just an example heat map"),
                #h4("This is getting busy, need to clean"),
                
                #h3("Current Parameters"),
                
                #verbatimTextOutput("parms2"),
                #verbatimTextOutput("parms3"),
                #verbatimTextOutput("parms4")
               # )
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
  
  #observe({
   # hide(id = "initial_message", condition = input$runit)
  #})
    
  observeEvent(input$runit,{
    
    #show_modal_spinner()
               print("you clicked runnit")
    
    #shinyjs:: hide(id = "#initial_message.shiny-html-output.shiny-bound-output")
    output$initial_message <- renderUI(h3(""))
    output$initial_message2 <- renderUI(h3(""))
    output$pitchprobtitle <- renderUI(h4("Probability of Next Pitch:"))
   
      db_name <- "stats_main"
      db_user <- "admin"
      db_password <- "cSe6242!"
      db_host <- "baseball.cfape4saa0af.us-east-1.rds.amazonaws.com"
      db_port <- 3306
      
      balls <- isolate(input$balls)
      strikes <- isolate(input$strikes)
      outs <- isolate(input$outs)
      previouspitch = isolate(input$previous_pitch)
      
     
    
      
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
      
      
      output$modelparms <- renderUI("The model was executed with the following parameters:")
      output$modelparmsballs <- renderUI(paste0("Balls: ", balls))
      output$modelparmsstrikes <- renderUI(paste0("Strikes: ", strikes)) 
      output$modelparmsouts <- renderUI(paste0("Outs: ", outs))
      output$modelparmsprev <- renderUI(paste0("Previous Pitch: ", previouspitch))
      
      
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
      and previouspitch = {previouspitch}
    ", .con = con)
      rs <- dbSendQuery(con, sql)
      d1 <- dbFetch(rs) # extract data
      dbHasCompleted(rs)
      
      dbClearResult(rs)
      dbListTables(con)
      # clean up
      dbDisconnect(con)
      
      #print(d1)
      
      df.long <- pivot_longer(d1, cols=10:12, names_to = "Pitch", values_to = "Probability") %>%
        select(Pitch, Probability)
      
      bar_chart <- function(label, width = "100%", height = "16px", fill = "#00bfc4", background = NULL) {
        bar <- div(style = list(background = fill, width = width, height = height))
        chart <- div(style = list(flexGrow = 1, marginLeft = "8px", background = background), bar)
        div(style = list(display = "flex", alignItems = "center"), label, chart)
      }
      
      #print(df.long)
      df.long$Pitch <- gsub("(?<=\\b)([a-z])", "\\U\\1", tolower(df.long$Pitch), perl=TRUE)
      df.long$Probability <- round(df.long$Probability,3)
      
      #output$outputtable <- DT::renderDataTable({
      #  DT::datatable(df.long)
        
      output$pitchprob <- renderReactable({
        
        
        
        reactable(df.long,
                  defaultColDef = colDef(
                    header = function(value) gsub(".", " ", value, fixed = TRUE),
                    cell = function(value) format(value, nsmall = 1),
                    align = "center",
                    minWidth = 70,
                    headerStyle = list(background = "#a8a8ad")
                  ),
                  columns = list(
                    Probability = colDef(name = "Probability", align = "left", cell = function(value) {
                      width <- paste0(value/.01 , "%")
                      bar_chart(value, width = width, background = "#e1e1e1")
                    })
                  ),
                  bordered = TRUE,
                  highlight = TRUE
        )
        
        })
      
      output$example_heat <- renderPlotly({
        strike_zones <- data.frame(
          x1 = rep(-1.5:0.5, each = 3),
          x2 = rep(-0.5:1.5, each = 3),
          y1 = rep(1.5:3.5, 3),
          y2 = rep(2.5:4.5, 3),
          z = factor(c(7, 4, 1, 8, 5, 2, 9, 6, 3))
        )
        
        strike_zones$labcol <- c("red","red","yellow","orange","orange","red","yellow","red","red")
        
        abc <- ggplot() +
          xlim(-3, 3) + xlab("") +
          ylim(0, 6) + ylab("") +
          geom_rect(data = strike_zones,
                    aes(xmin = x1, xmax = x2, ymin = y2, ymax = y1), fill = strike_zones$labcol, color = "grey20") +
          geom_text(data = strike_zones,
                    aes(x = x1 + (x2 - x1)/2, y = y1 + (y2 - y1)/2, label = z),
                    size = 7, fontface = 2, color = I("grey20")) +
          theme_bw() + theme(legend.position = "none")
        
        
        ggplotly(abc)
      }
      )
      
   # })
    
               
            
      #remove_modal_spinner()             
               
}
               )
               
  
   
      
    output$diamond_plotly <- renderPlotly({
      
      bases =data.frame(x=c(0, 30, 0, -30, 0),
                        y=c(0,75, 150, 75, 0),
                        z =c("Home", "First Base", "Second Base", "Third Base", "Home")
      )
      #print (colorvec())
      #colorsel <- c("black","black","red","red","black")
      bases$colorsel <- colorvec$colors

      print(bases)
    
      fig <- plot_ly(data = bases, x = ~x, y = ~y, text=~z, hoverinfo = 'text', source = "diamond_c",
                     
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
    
    
    output$initial_message <- renderUI(h3("Select Parameters"))
    output$initial_message2 <- renderUI(h3("Click Run Algorithm"))
   
}
# Run the application 
shinyApp(ui = ui, server = server)
