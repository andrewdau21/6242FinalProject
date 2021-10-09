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
           verbatimTextOutput("info2"),
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
  

    
    output$diamond <- renderPlot({
      
      
      bases =data.frame(x=c(0, 30, 0, -30, 0),
                        y=c(0,75, 150, 75, 0)
      )
      
      
      ggplot(bases, aes(x,y)) + 
        geom_point(shape = 22, colour = "black",fill="black", size = 5, stroke = 5) +
        geom_path(aes(x=x, y=y), data=bases)
      
    })
    
    observeEvent(input$diamond_click,{
      
      output$info <- renderText({
        if (input$diamond_click$x > 28 && input$diamond_click$x < 32 && 
            input$diamond_click$y > 73 && input$diamond_click$y < 77)
        { paste0("You clicked on first base.")}
        
        else if (input$diamond_click$x > -2 && input$diamond_click$x < 2 && 
                 input$diamond_click$y > 148 && input$diamond_click$y < 152)
        { paste0("You clicked on second base.")}
        
        else if (input$diamond_click$x > -32 && input$diamond_click$x < -28 && 
                 input$diamond_click$y > 73 && input$diamond_click$y < 77)
        { paste0("You clicked on second base.")}
        
      })
      
    })
      
    output$diamond_plotly <- renderPlotly({
      
      bases =data.frame(x=c(0, 30, 0, -30, 0),
                        y=c(0,75, 150, 75, 0)
      )
      
    
      fig <- plot_ly(data = bases, x = ~x, y = ~y, source = "diamond_c",
                     marker = list(size = 10,
                                   symbol = 'square',
                                   color = 'black',
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
    
    
    observeEvent(event_data("plotly_click", source = "diamond_c"),{
      
      event.data <- event_data("plotly_click", source = "diamond_c")
      
      print(event.data)

      output$info2 <- renderText({
        if (event.data$x == 30 &&  event.data$y == 75)
        { paste0("You clicked on first base.")}

        else if (event.data$x == 0 &&  event.data$y == 150)
        { paste0("You clicked on second base.")}

        else if (event.data$x == -30 &&  event.data$y == 75)
        { paste0("You clicked on second base.")}

      })

    })
    
 
}
# Run the application 
shinyApp(ui = ui, server = server)
