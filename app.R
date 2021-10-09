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

# Define UI for application that draws a histogram
ui <- navbarPage("Next Pitch",

    # Application title
    

   
    tabPanel("Simulator",
        # Show a plot of the generated distribution
        mainPanel(
          selectizeInput('pitcher_select', 'Select a Pitcher:', choices = c("Stephen Strasburg", "Max Scherzer", "Jose Berrios"), selected = NULL, multiple = FALSE,
                         options = NULL),
           #plotOutput("diamond", click = "diamond_click"),
           #verbatimTextOutput("info"),
           #verbatimTextOutput("info2"),
           plotly::plotlyOutput("diamond_plotly")
          
        )
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
                            zerolinecolor = '#ffff')
        ) %>%
        layout(yaxis = list(title = '',
                            showgrid = F,
                            showline = FALSE,
                            showticklabels = FALSE,
                            zerolinecolor = '#ffff')
        )
      
      fig <- fig %>% add_trace(name = 'trace 0',mode = 'lines')
      
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
    
 
}
# Run the application 
shinyApp(ui = ui, server = server)
