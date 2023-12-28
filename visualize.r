library(DT)
library(shiny)
library(ggplot2)
library(dplyr)
# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Hello Shiny!"),
  sidebarLayout(
    sidebarPanel(
      radioButtons("File", "select data",
                   choices = c("historytrial2037.csv", "historytrialdir2037.csv"),
                   selected = "historytrial2037.csv"),
    ),
    # Main panel for displaying outputs ----
    mainPanel(
      plotOutput("plot"),
      textOutput("label"),
      DT::dataTableOutput("table2")
    )
  )
  
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  observeEvent(input$File, {
    file_path <- switch(input$File,
      "historytrial2037.csv" = "./Data/historytrial2037.csv",
      "historytrialdir2037.csv" = "./Data/historytrialdir2037.csv"
    )
    data = read.csv(file_path)
    data$Start.Time <- as.POSIXct(data$Start.Time)
    data$SearchTime <- format(as.Date(data$Start.Time), "%Y-%m-%d")
    
    plot_data <- data %>%
      group_by(User, SearchTime) %>%
      summarise(Search_count = n(), .groups = 'drop')
    output$plot <- renderPlot({
      ggplot(plot_data, aes(x = as.Date(SearchTime), y = Search_count, fill = User)) +
        geom_bar(position="stack", stat="identity") +
        theme_minimal() +
        scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 day") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1))  +
        labs(x = "", y = "", title = "Bar plot")
    })
    output$label <- renderText({"Table summary:"})
    table <- data %>%
      group_by(" " = as.Date(SearchTime)) %>%
      summarise("number of user" = n_distinct(User), "number of search" = n(), .groups = 'drop')
    
    output$table2 <- DT::renderDataTable(
      datatable(table, rownames = FALSE)
    )
  })
  
}

shinyApp(ui = ui, server = server)