library(shiny)
library(shinydashboard)
library(mapdeck)
library(dplyr)
require(tidyverse)
library(slickR)

style = "font-family: 'times'; font-size: 18pt"
h1_style = "font-family: 'times'; color:black; font-weight: bold;"
h2_style = "font-family: 'times'; color:black; font-style: italic;"
cm_size = '33%'

# UI
header <- dashboardHeader(title='Pandemic Flight')

sidebar <- dashboardSidebar(
  sidebarMenu(id = 'tabs',
              menuItem('Explorations', tabName = 'explorations', icon = icon('search')),
              menuItem('Methods', tabName = 'methods', icon = icon('poll')),
              menuItem('Results', tabName = 'results', icon = icon('lightbulb')),
              menuItem('Conclusions', tabName = 'conclusions', icon = icon('terminal'))))

body <- dashboardBody(
  tabItems(
    # explorations tab
    tabItem(tabName = 'explorations',
            style='overflow-y:scroll; height:90vh;',
            box(width=12, 
                h1('Summary', style=h1_style),
                p('- Our main goal is to find a solution to decrease the number 
                  of flights to a minimum per state utilising only those airports 
                  with most recurring and frequent flights so that travelers can 
                  reach their desired destinations, while lowering the spread of Covid-19.',
                  style=style),
                p('- After exploring our data, we found out that:', style=style),
                tags$ol(
                  tags$li('In 2020, there are 142 airports and there are 224 distinct 
                          flights from these airports consider as important.', style=style), 
                  tags$li('In 2021, there are 143 airports and there are 214 distinct 
                          flights from these airports consider as important.', style=style)
                )
            ),
            box(width=12,
                h1('Visualization', style=h1_style),
                column(width=3,
                       selectInput(inputId='year',
                                   label='Select Year',
                                   list('2020', '2021'))),
                column(width=3,
                       selectInput(inputId='origin',
                                   label='Select Original State',
                                   list('AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 
                                        'CT', 'FL', 'GA', 'HI', 'IA', 'ID',
                                        'IL', 'IN', 'KS', 'KY', 'LA', 'MA',
                                        'MD', 'ME', 'MI', 'MN', 'MO', 'MS',
                                        'MT', 'NC', 'ND', 'NE', 'NH', 'NJ',
                                        'NM', 'NV', 'NY', 'OH', 'OK', 'OR',
                                        'PA', 'PR', 'RI', 'SC', 'SD', 'TN',
                                        'TX', 'UT', 'VA', 'VT', 'WA', 'WI',
                                        'WV', 'WY'))),
                column(width=3,  
                       actionButton('search_map', 'Apply filter'),
                       style = 'margin-top: 25px;')
            ),
            box(width = 12,
                mapdeckOutput(outputId = 'map',
                              height = '530px')
            )
    ),
    
    # methods tab
    tabItem(tabName = 'methods',
            style='overflow-y:scroll; height:90vh;',
            box(width=12, 
                h1('Data Cleaning', style=h1_style),
                p('- The training features includes:', style=style),
                tags$ol(
                  tags$li('AIR_TIME', style=style), 
                  tags$li('DISTANCE', style=style)
                ),
                p('- These features are the most useful quantitative features within
                the dataset.', style=style),
                p('- We drop the other qualitative features because they
                are not meaningful. (Airport ID, Year, etc.)', style=style),
            ),
            box(width=12, 
                h1('Training Methods', style=h1_style),
                p('- We focus on using the SVM, Decision Tree, and Random Forest
                models to build our classifiers.', style=style),
                
                h2('Data Sub-sampling', style=h2_style),
                p('- Our data has a huge imbalance of important and non-important
                flights (36622 vs 458142).', style=style),
                p('- We come up with an idea to sub-sample the data to 
                train the model more efficiently.', style=style),
                p('- Here is an example of a 10000 sub-sample data with a 30%
                test data distribution.', style=style),
                img(src='Train-Test-Distribution.png', align = 'center'),
                
                h2('Hyper-parameters Tuning', style=h2_style),
                h3('1. Decision Tree', style=style),
                p('- We use grid search method to find the best max_depth 
                parameter.', style=style),
                p('- The higher the max_depth the higher the accuracy, however,
                it can lead to overfit.', style=style),
                
                h3('2. Random Forest Tree', style=style),
                p('- We use grid search method to find the best max_samples 
                parameter.', style=style),
                p('- Max_samples indicates the number of samples to draw from X
                to train each base estimator.', style=style),
            )
    ),
    
    # results tab
    tabItem(tabName = 'results',
            style='overflow-y:scroll; height:90vh;',
            box(width=12,
                h1('Score', style=h1_style),
                dataTableOutput('results_table'),
            ),
      
            box(width=12,
                h1('ROC and Confusion Matrix', style=h1_style),
                slickROutput('slickr', height='90%')
            ),
            
    ),
    
    # conclusions tab
    tabItem(tabName = 'conclusions',
            box(width=12, 
                h1('Important Points', style=h1_style),
                p('- SVM performs poorly in unbalance dataset.', style=style),
                p('- We drop the other qualitative features because they
                are not meaningful. (Airport ID, Year, etc.)', style=style),
                p('- We drop the other qualitative features because they
                are not meaningful. (Airport ID, Year, etc.)', style=style)),
            
            box(width=12, 
                h1('Limitations', style=h1_style),
                p('- The imbalance nature of the data can greatly affect the model
                  performance.', style=style),
                p('- Missing the cost of the flights, which can be used to verify
                  the actual profit of the predicted flights.', style=style),
                p('- We drop the other qualitative features because they
                are not meaningful. (Airport ID, Year, etc.)', style=style)),
            
            box(width=12, 
                h1('Again', style=h1_style),
                p('- The imbalance nature of the data can greatly affect the model
                  performance.', style=style),
                p('- Missing the cost of the flights, which can be used to verify
                  the actual profit of the predicted flights.', style=style),
                p('- We drop the other qualitative features because they
                are not meaningful. (Airport ID, Year, etc.)', style=style)),
                
    )
  )
)

ui <- dashboardPage(header, sidebar, body)

# SERVER
server <- function(input, output, session) {
  # set your mapbox token here
  mapkey = "pk.eyJ1IjoicmFqZXNoMTIza3VuYWwiLCJhIjoiY2wxeDR2cTBsMDBjeTNpbnpxcHViNHRpaiJ9.JSxaLmgNMV6FZT25dXTsqg"
  set_token(mapkey) 
  
  # initialize a map
  output$map <- renderMapdeck({
    mapdeck(style = mapdeck_style('dark'), 
            location = c(-97, 38), 
            zoom = 4, 
            pitch = 45)})
  
  # map event
  observeEvent(input$search_map, {
    # get the input data
    if(input$year == '2020') {
      data = read.csv('www/flight_details_2020.csv', header=TRUE, sep=',')
    } else {
      data = read.csv('www/flight_details_2021.csv', header=TRUE, sep=',')
    }
    
    data = filter(data, ORIGIN_STATE_ABR == input$origin)
    
    # initialize a map
    output$map <- renderMapdeck({
      mapdeck_update(map_id = "map") %>%
        add_arc(data = data, origin = c('ORIGIN_LONG', 'ORIGIN_LAT'),
                destination = c('DEST_LONG', 'DEST_LAT'),
                layer_id = 'arcs',
                stroke_from_opacity = 100,
                stroke_to_opacity = 100,
                stroke_width = 5,
                stroke_from = 'ORIGIN_STATE_ABR',
                stroke_to = 'DEST_STATE_ABR',
                update_view = FALSE)
    })
  })

  # result tab event
  observeEvent(input$tabs, {
    if (input$tabs == 'results') {
      result_csv = read.csv('www/results.csv', header=TRUE, sep=',')
      output$results_table <- renderDataTable(result_csv)
    }
  })
  
  output$slickr <- renderSlickR({
    imgs = 'www/ROC.png'
    cm_imgs = list.files("www/cm/", pattern=".png", full.names = TRUE)
    imgs <- append(imgs, cm_imgs)
    slickR(imgs)
  })
}

shinyApp(ui, server)