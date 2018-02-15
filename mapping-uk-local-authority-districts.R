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
map.local_authority_districts <- parlitools::local_hex_map
# inspect
map.local_authority_districts

# Get council control by party
council_data <- parlitools::council_data
# inspect
council_data

# Get official HEX colors of each party 
# spell colours with u to showcase your British patriotism...
party_colours <- parlitools::party_colour
# inspect
party_colours

###########
# JOIN DATA
###########

# Join council data with colors
council_data <- left_join(council_data, party_colours, 
                          by = c("majority_party_id"="party_id", 
                                 "majority_party"="party_name"))

# Create Hexagonal map of local party control
map.hex <- left_join(map.local_authority_districts, council_data, by = "la_code")
# inspect
map.hex

####################
# CREATE LEAFLET MAP
####################

# Format map labels
map.labels <- paste0("<strong>", map.hex$name, "</strong>",  # district name
                     "</br>",
                     "Party: ", map.hex$majority_party, 
                     "</br>",
                     "Governing Coalition: ", map.hex$governing_coalition) %>%
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
        map.hex) %>%
  addPolygons(color = "grey",
    weight= 0.75,
    opacity = 0.5,
    fillOpacity = 1,
    fillColor = ~party_colour,
    label = map.labels) %>%
  htmlwidgets::onRender("function(x, y) {
           var myMap = this;
           myMap._container.style['background'] = '#fff';
  }") %>%
  mapOptions(zoomToLimits = "first")

# save plot
saveWidget(m, 'mapping-uk-local-authority-districts.html')
