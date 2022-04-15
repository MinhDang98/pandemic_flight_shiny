library(shiny)
library(shinydashboard)
library(mapdeck)
library(dplyr)


# UI
header <- dashboardHeader(title='Pandemic Flight')

sidebar <- dashboardSidebar(
  sidebarMenu(menuItem('Explorations', tabName = 'explorations', icon = icon('search')),
    menuItem('Results', tabName = 'result', icon = icon('poll')),
    menuItem('Comparisons', tabName = 'comparisons', icon = icon('compress')),
    menuItem('Conclusions', tabName = 'conclusions', icon = icon('terminal'))))

body <- dashboardBody(
  tabItems(
    # 1st tab
    tabItem(tabName = 'explorations',
            box(width=12,
                column(width=3,
                        selectInput(inputId='year',
                                    label='Select Year',
                                    list('2020', '2021'))),
                column(width=3,
                        selectInput(inputId='origin',
                                     label='Select Original State',
                                     list('All',
                                          'AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT',
                                          'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 
                                          'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD',
                                          'ME', 'MI', 'MN', 'MO', 'MS', 'MT', 'NC',
                                          'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY',
                                          'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC',
                                          'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA',
                                          'WI', 'WV', 'WY'))),
                column(width=3,  
                       actionButton('search_map', 'Apply filter'),
                       style = 'margin-top: 25px;')
            ),
            box(width = 12,
                mapdeckOutput(outputId = 'map',
                              height = '800px')
                )
    ),
    
    # 2nd tab
    tabItem(tabName = 'result',
            h2('result')),
    
    # 3rd tab
    tabItem(tabName = 'comparisons',
            h2('comparisons')
    ),
    
    # 4th tab
    tabItem(tabName = 'conclusions',
            h2('conclusions'))
  )
)
  
ui <- dashboardPage(header, sidebar, body)

# SERVER
server <- function(input, output) {
  # set your mapbox token here
  mapkey = "pk.eyJ1IjoicmFqZXNoMTIza3VuYWwiLCJhIjoiY2wxeDR2cTBsMDBjeTNpbnpxcHViNHRpaiJ9.JSxaLmgNMV6FZT25dXTsqg"
  set_token(mapkey) 
  
  # load data
  flights_2020 = read.csv('flight_details_2020.csv', header=TRUE, sep=',')
  flights_2021 = read.csv('flight_details_2021.csv', header=TRUE, sep=',')
  
  # initialize a map
  output$map <- renderMapdeck({
    mapdeck(style = mapdeck_style('dark'), 
            location = c(-97, 38), 
            zoom = 4, 
            pitch = 45)})
  
  # map event
  data = ''
  observeEvent(input$search_map, {
    # get the input data
    if(input$year == '2020') {
      data = flights_2020
    } else {
      data = flights_2021
    }
    
    if(input$origin != 'All') {
      data = filter(data, ORIGIN_STATE_ABR == input$origin)
    }
    
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
  
  
}

shinyApp(ui, server)
