library(dplyr)
library(cartogram)
library(parlitools)
library(htmlwidgets)
library(sf)
library(leaflet)

##########
# GET DATA
##########

# Get local authority hexagon map
map.westminster <- parlitools::west_hex_map
# inspect
map.westminster

# Get up-to-date info on MPs
mps <- mps_on_date("2018-02-14")

# Get official HEX colors of each party 
# spell colours with u to showcase your British patriotism...
party_colours <- parlitools::party_colour
# inspect
party_colours

###########
# JOIN DATA
###########

# Join council data with colors
mp_colors <- left_join(mps, party_colours, by = "party_id")

# Create Hexagonal map of local party control
map.westminster <- left_join(map.westminster, mp_colors, by = "gss_code")
# inspect
map.westminster

####################
# CREATE LEAFLET MAP
####################

# Format map labels
map.labels <- paste0("<strong>", map.westminster$constituency_name, "</strong>",  # district name
                     "</br>",
                     "Party: ", map.westminster$party_name, 
                     "</br>",
                     "MP: ", map.westminster$display_as,
                     "</br>",
                     "Most Recent Result: ", map.westminster$result_of_election, 
                     "</br>",
                     "Current Majority: ", map.westminster$majority, " votes") %>%
  lapply(htmltools::HTML)

# Create leaflet map
m <- leaflet(options = leafletOptions(dragging = FALSE,
                                      zoomControl = FALSE,
                                      tap = FALSE,
                                      minZoom = 6,
                                      maxZoom = 6,
                                      maxBounds = list(list(2.5, -7.75), 
                                                       list(58.25, 50.0)),
                                      attributionControl = FALSE),
             map.westminster) %>%
  addPolygons(color = "grey",
              weight= 0.75,
              opacity = 0.5,
              fillOpacity = 1,
              fillColor = ~party_colour,
              label = map.labels) %>%
  htmlwidgets::onRender("function(x, y) {
                        var myMap = this;
                        myMap._container.style['background'] = '#fff';
                        }") 
# save plot
saveWidget(m, 'mapping-uk-by-mp-party.html')
