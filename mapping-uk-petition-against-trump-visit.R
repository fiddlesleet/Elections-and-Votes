# Mapping ‘Prevent Donald Trump from making a State Visit to the United Kingdom' petition support

library(dplyr)
library(cartogram)
library(parlitools)
library(htmlwidgets)
library(sf)
library(leaflet)
library(hansard)

#################################################################
# GET DATA
# - The UK Parliamentary Petition site has data for mapping which
#   parliamentary constituencies petition signatories live in.
#################################################################

# Get local authority hexagon map
map.westminster <- parlitools::west_hex_map
# inspect
map.westminster

# Get petition data
trump.petition <- hansard::epetition(ID = 648278, by_constituency=TRUE)
# inspect
trump.petition

###########
# JOIN DATA
###########

# Join MP district data with petition support
district_petition_support <- left_join(map.westminster, trump.petition, by = "gss_code")

####################
# CREATE LEAFLET MAP
####################

# Format map labels
map.labels <- paste0("<strong>", district_petition_support$constituency_name, "</strong>", 
                     "</br>",
                     "Signatures: ", district_petition_support$number_of_signatures) %>%
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
             district_petition_support) %>%
  addPolygons(color = "grey",
              weight= 0.75,
              opacity = 0.5,
              fillOpacity = 1,
              fillColor = ~pal(number_of_signatures),
              label = map.labels) %>%
  addLegend("topright", pal = colorNumeric("Blues", trump.petition$number_of_signatures), values = ~number_of_signatures,
            title = "Number of Signatures",
            opacity = 1)  %>% 
  htmlwidgets::onRender("function(x, y) {
                        var myMap = this;
                        myMap._container.style['background'] = '#fff';
                        }")
# save plot
saveWidget(m, 'mapping-uk-petition-against-trump-visit.html')
