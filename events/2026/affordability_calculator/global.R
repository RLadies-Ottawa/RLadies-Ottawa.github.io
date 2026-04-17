#-----------------------------------------
# What can I afford? - Affordability Calculator
#
# Author: Valerie Figuracion
#
# For the R-Ladies International Women's Day (IWD) Data Challenge - 2026
#
# A shiny app in where the user provides their annual income, down payment %,
# mortgage period, gets a personalized list of properties available at zillow.com
# at the time of the app launch.
#
# Note: For simplicity, debts, and other necessary expenses (eg groceries) are omitted
#
# App is segmented into 3 files, global.R, server.R, and ui.R
#
# global.R is responsible for gathering the data including:
# - Scraping zillow.com to get the housing data 
# - Using an API to pull Ottawa's ward data including the polygons for the shape
# of each ward
#
# Version 1.0
# Date: April 17, 2026
#-----------------------------------------


#Get the housing dataset----
# install.packages("rvest")
library(tidyverse)
library(rvest)
library(jsonlite)
library(httr)
library(shiny)

#Realtor website: Zillow
first_page <- "https://www.zillow.com/ottawa-on/?searchQueryState=%7B%22pagination%22%3A%7B%7D%2C%22isMapVisible%22%3Atrue%2C%22mapBounds%22%3A%7B%22west%22%3A-76.60332724414062%2C%22east%22%3A-74.99657675585937%2C%22south%22%3A44.87396387774735%2C%22north%22%3A45.62420973824204%7D%2C%22regionSelection%22%3A%5B%7B%22regionId%22%3A792772%2C%22regionType%22%3A6%7D%5D%2C%22filterState%22%3A%7B%22sort%22%3A%7B%22value%22%3A%22globalrelevanceex%22%7D%2C%22land%22%3A%7B%22value%22%3Afalse%7D%7D%2C%22isListVisible%22%3Atrue%2C%22usersSearchTerm%22%3A%22Ottawa%20ON%22%7D"

#Get the total result for Ottawa Homes on sale
result_count <- read_html(first_page) %>%
  html_element("h2.result-count") %>%
  html_text() %>%
  str_remove_all("[^0-9]") %>%
  as.numeric()

#Data frame of URLs
df_urls <- data.frame(
  page = 1,
  url = first_page,
  stringsAsFactors = FALSE
)

#Number of pages for the urls. The URLs follow a predictable pattern
pages <- 2:24 #For some reason there you can only access the first 24 pages in
#Zillow even though the number of result hits show that there should be more pages
urls <- paste0(
  "https://www.zillow.com/ottawa-on/",
  pages, "_p/?searchQueryState=%7B%22pagination%22%3A%7B%22currentPage%22%3A",
  pages,
  "%7D%2C%22isMapVisible%22%3Atrue%2C%22mapBounds%22%3A%7B%22west%22%3A-76.60332724414062%2C%22east%22%3A-74.99657675585937%2C%22south%22%3A44.87396387774735%2C%22north%22%3A45.62420973824204%7D%2C%22regionSelection%22%3A%5B%7B%22regionId%22%3A792772%2C%22regionType%22%3A6%7D%5D%2C%22filterState%22%3A%7B%22sort%22%3A%7B%22value%22%3A%22globalrelevanceex%22%7D%2C%22land%22%3A%7B%22value%22%3Afalse%7D%7D%2C%22isListVisible%22%3Atrue%2C%22usersSearchTerm%22%3A%22Ottawa%20ON%22%7D"
)

#Get all of the non-first page urls into a dataframe and append it to the first dataframe
df_later_urls <- data.frame(
  page = pages,
  url = urls,
  stringsAsFactors = FALSE
)

df_urls <- bind_rows(df_urls, df_later_urls)

#Initialize empty data frame for all of the listings and get all of the data of interest
all_listings = data.frame()

for(i in 1:nrow(df_urls)){
  page <- read_html(df_urls$url[i])

  json_data <- page %>%
    html_element("script#__NEXT_DATA__") %>%
    html_text()

  data <- fromJSON(json_data)

  listings <- data$props$pageProps$searchPageState$cat1$searchResults$listResults

  df_listing <- data.frame(
    # page = i,
    address = listings$address,
    lat = listings$latLong$latitude,
    long = listings$latLong$longitude,
    price = listings$unformattedPrice,
    beds = listings$beds,
    baths = listings$baths,
    type = listings$hdpData$homeInfo$homeType,
    link = listings$detailUrl
  )

  all_listings <- bind_rows(all_listings, df_listing)

  # Sys.sleep(1) #Just in case it thinks I'm a bot
}

all_listings <- unique(all_listings)%>%
  filter(price >= 100000)

#Remove underscores in type
all_listings$type <- gsub("_", " ", all_listings$type)

#Get missing lat/long
library(dplyr)
# install.packages("tidygeocoder")
library(tidygeocoder)

df_filtered <- all_listings %>%
  filter(is.na(lat)) %>%
  select(address) %>%
  geocode(address, method = "osm", lat = lat, long = long)

all_listings_1 <- all_listings %>%
  left_join(df_filtered %>% select(address, lat, long), by = "address", suffix = c("", "_df2")) %>%
  mutate(lat = coalesce(lat, lat_df2)) %>%
  mutate(long = coalesce(long, long_df2)) %>%
  select(-c(lat_df2, long_df2))

# Read the downloaded geoJson file from Open Ottawa with the sf library ----
# install.packages("sf")
library(sf)
library(dplyr)
library(leaflet)
wards <- st_read("https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Wards_2022_2026/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")

# Create the point from valid coordinates
points_valid <- all_listings_1 %>%
  filter(!is.na(long) & !is.na(lat))

# Convert points dataframe to sf and Match CRS with polygons
points_sf <- st_transform(st_as_sf(points_valid, coords = c("long", "lat"), crs = 4326),
                          st_crs(wards))

# Join each point to the polygon it falls in
result <- st_join(points_sf, wards["NAME"], join = st_within)%>%
  st_drop_geometry()

#Map count
# Count how many times each colA appears in final_result
medians <- result %>%
  group_by(NAME) %>%
  summarise(median_price = median(price, na.rm = TRUE))

# Join counts back to the map polygons
map_medians <- wards %>%
  left_join(medians, by = "NAME")
