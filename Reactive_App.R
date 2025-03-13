#install.packages("dplyr")
library(shiny)
library(dplyr)

# UI Definition
ui <- fluidPage(
  titlePanel("Iris Dataset Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "species",
        label = "Choose a Species:",
        choices = levels(iris$Species)
      ),
      
      sliderInput(
        inputId = "sepal_length",
        label = "Sepal Length Range:",
        min = min(iris$Sepal.Length),
        max = max(iris$Sepal.Length),
        value = c(min(iris$Sepal.Length), max(iris$Sepal.Length))
      ),
      
      actionButton(
        inputId = "filter_data",
        label = "Filter Data"
      )
    ),
    
    mainPanel(
      tableOutput(outputId = "filtered_table")
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # 1. Reactive expression: Filter data by species
  filtered_by_species <- reactive({
    # We want the selection changes for the data set and to not depend on the filter button.
    
    req(input$species) # Make sure a species has been selected
    
    # It will print an error message in the UI if the species can not be found.
    #validate(
    # need(input$species %in% unique(iris$Species), "Species not found")
    #)
    
    # filter() is applied to the iris dataset to include only the rows
    iris %>%
      filter(Species == input$species) # Filters on the selected id.
  })
  
  # 2. Event reactive expression: Further filter by sepal length
  filtered_data <- eventReactive(input$filter_data, {
    # We want to control the data in this data set that takes both a filter button and a filter of the values within the range for sepal length.
    
    req(input$sepal_length) # Ensure a sepal length range has been selected
    req(filtered_by_species()) # Ensure the species has been already filtered.
    
    # Use of `validate()` to show error messages
    # validate(
    #  need(length(input$sepal_length) == 2, "Sepal Length range must be length 2"), # Checks for two points.
    #  need(input$sepal_length[1] <= input$sepal_length[2], "Min Sepal length must be less than the max"), # Is low/high correct order?
    #)
    
    # filter() is applied to the filtered_by_species() dataset,
    filtered_by_species() %>%
      filter( # filters on the selection range.
        Sepal.Length >= input$sepal_length[1] &
          Sepal.Length <= input$sepal_length[2]
      )
  })
  
  # 3. Observe species selection and print to console (a side effect)
  observe({
    # We do not want the other plots and reactive objects to have any impact and that is to just watch the selection.
    cat("Selected species:", input$species, "\n") # Cat prints to console.
  })
  
  # 4. Render the filtered data as a table
  output$filtered_table <- renderTable({
    # To help the app work we require an event before sending data
    req(filtered_data()) # Need requires the filtered_data for this to run, prevents crash.
    
    # Validated in code and that if you did not fill something it will return null value, so, what would happen if there is no available options?
    # validate(
    #  need(nrow(filtered_data()) > 0, "No data available for selected range.") # Prevents crashes from zero results from the filter
    #)
    # This ensures there are values, if not, then the UI returns a message.
    filtered_data() # returns the output
  })
}

# Run the application
shinyApp(ui = ui, server = server)