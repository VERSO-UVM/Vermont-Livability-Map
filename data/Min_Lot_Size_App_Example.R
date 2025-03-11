library(shiny)
library(tidyverse)

# Sample dataset (replace with your actual dataset)
geo_data2 <- read.csv("geo_data.csv")

ui <- fluidPage(
  titlePanel("Minimum Lot Sizes by Jurisdiction"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("selected_jurisdiction", 
                  "Choose a Jurisdiction:", 
                  choices = unique(geo_data2$Jurisdiction), 
                  selected = "Windham")
      
    ),
    mainPanel(
      plotOutput("lot_size_plot")
    )
  )
)

server <- function(input, output) 
{
  filtered_data <- reactive({
    geo_data2 |> 
      pivot_longer(
        cols = c(F1_Family_Min__Lot, F2_Family_Min__Lot, F3_Family_Min__Lot, F4__Family_Min__Lot),
        names_to = "Min_Lot_F_num", 
        values_to = "Min_Lot_Size"
      ) |> 
      dplyr::filter(Jurisdiction == input$selected_jurisdiction & Overlay != "Yes") |> 
      select(County, Jurisdiction, Full_District_Name, Min_Lot_F_num, Min_Lot_Size) |> 
      mutate(Min_Lot_Size = as.numeric(Min_Lot_Size))
  })
  
  output$lot_size_plot <- renderPlot({
    filtered_data() |> 
      ggplot(aes(x = Full_District_Name, y = Min_Lot_Size, fill = Min_Lot_F_num)) +
      geom_col(show.legend = TRUE) + 
      labs(
        title = "Minimum Lot Sizes by District",
        subtitle = paste("For", input$selected_jurisdiction, "Jurisdiction"),
        x = "District",
        y = "Minimum Lot Size",
        fill = "Lot Size Type"
      ) +
      theme_light() +
      theme(
        plot.title = element_text(size = 14, hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.y = element_text(size = 12),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank()
      ) +
      scale_y_continuous(expand = c(0, 0, 0, 0.05))
    
  })
}


shinyApp(ui, server)
