#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("TESTING.  DOES THIS WORK TEAM?"),

    # Sidebar with a slider input for number of bins 
   
        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("diamond")
        )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  bases =data.frame(x=c(0, 90/sqrt(2), 0, -90/sqrt(2), 0),
                    y=c(0, 90/sqrt(2), 2*90/sqrt(2), 90/sqrt(2), 0)
  )
  

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
    
    output$diamond <- renderPlot({
      
      ggplot(bases, aes(x,y)) + 
        geom_point(shape = 22, colour = "black",fill="black", size = 5, stroke = 5) +
        geom_path(aes(x=x, y=y), data=bases)
      
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
