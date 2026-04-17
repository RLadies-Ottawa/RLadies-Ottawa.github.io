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
# server.R is responsible for the logic of the app including:
# - Determining maximum property price based on the user's income, mortgage period,
# and down payment % inputs
# - Calculates the minimum income required to purchase the maximum property price
# based on user defined mortgage period and down payment %
# - Creating a table for the summary statistics including counts and averages
# - Displaying and updating the map based on user inputs
# - Functionality for downloading the filtered property list
#
# Version 1.0
# Date: April 17, 2026
#-----------------------------------------

#Start of the application ----
library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {
  ##Get user inputs----
  downPayment_input <- reactive({
    input$downPayment
  })

  yrsMortgage_input <- reactive({
    input$yrsMortgage
  })

  grossIncome_input <- reactive({
    input$grossIncome
  })
  

  ##Get the maximum housing price based on User inputs----
  ###Constants----
  annualInterestRate = 5.25
  monthlyInterestRate = annualInterestRate/100/12
  GDS_Ratio = 0.39
  
  ###Calculation for max price----
  maxPaymentDollar <- reactive({
    
    grossIncomeMonthly = grossIncome_input()/12
    mortgagePayment = GDS_Ratio*grossIncomeMonthly

    numMonthlyPayments = yrsMortgage_input()*12

    mortgageNumerator = ((1+monthlyInterestRate)^numMonthlyPayments)-1
    mortgageDenominator = monthlyInterestRate*((1+monthlyInterestRate)^numMonthlyPayments)

    mortgage = mortgagePayment*mortgageNumerator/mortgageDenominator

    maxPropertyDollar = mortgage/(1-(downPayment_input()/100))
    
    maxPropertyDollar
  })
  
  output$maxPrice <- renderText({
    paste0("$", formatC(maxPaymentDollar(), format = "f", digits = 2, big.mark = ","))
  })
  
  ###Calculation for min income ----
  minIncomeDollar <- reactive ({

    maxPropertyDollar2 = max(all_listings_1$price, na.rm = TRUE)
    
    mortgage2 = maxPropertyDollar2 - (downPayment_input()/100*maxPropertyDollar2)
    
    numMonthlyPayments2 = yrsMortgage_input()*12
    
    mortgageNumerator2 = monthlyInterestRate*((1+monthlyInterestRate)^numMonthlyPayments2)
    mortgageDenominator2 = ((1+monthlyInterestRate)^numMonthlyPayments2)-1
    
    mortgagePayment2 = mortgage2*mortgageNumerator2/mortgageDenominator2
    
    grossIncomeMonthly2 = mortgagePayment2/GDS_Ratio
    minIncome2 = grossIncomeMonthly2*12
    
    minIncome2
    
  })
  
  output$minIncome <- renderText({
    paste0("$", formatC(minIncomeDollar(), format = "f", digits = 2, big.mark = ","))
  })
  
  
  ##Filter for the list of property with maximum----
  filtered_points <- reactive({
    pts <- points_sf %>%
      filter(price <= maxPaymentDollar())
    pts
  })
  
  ##Tables----
  ###Summary Table ----
  summaryTable <- reactive ({
    df <- data.frame(
      statistic = c("Average Bedrooms", 
                    "Average Bathrooms"),
      value = c(floor(mean(filtered_points()$beds, na.rm = TRUE)),
                floor(mean(filtered_points()$baths, na.rm = TRUE)))
    )
    
    df
  })
  
  output$summaryTable <- renderTable(summaryTable(), 
                                     striped = TRUE, 
                                     width = "100%", 
                                     colnames=FALSE, 
                                     digits=0) 
  
  ###Count Table ----
  countTable <- reactive ({
    df <- data.frame(
      statistic = c("Apartments", 
                    "Condos", 
                    "Manufactured",
                    "Multi-Family", 
                    "Single-Family", 
                    "Townhouse"),
      value = c(sum(filtered_points()$type == "APARTMENT", na.rm = TRUE),
                sum(filtered_points()$type == "CONDO", na.rm = TRUE),
                sum(filtered_points()$type == "MANUFACTURED", na.rm = TRUE),
                sum(filtered_points()$type == "MULTI FAMILY", na.rm = TRUE),
                sum(filtered_points()$type == "SINGLE FAMILY", na.rm = TRUE),
                sum(filtered_points()$type == "TOWNHOUSE", na.rm = TRUE))
    )
    
    df
  })
  
  output$countTable <- renderTable(countTable(), striped = TRUE, width = "100%", colnames=FALSE) 
  
  ##Reactive Map----
  map_medians_reactive <- reactive({
    pts <- filtered_points()
    
    #making sure the app doesn't close if the table is empty
    if (nrow(pts) == 0) {
      out <- wards
      out$median_price <- NA_real_
      return(out)
    }
    
    #Join the name of the ward to the listings dataset
    result <- st_join(filtered_points(),wards["NAME"],join = st_within) %>%
      st_drop_geometry()
    
    #making sure the app doesn't close if the table is empty
    if (nrow(result) == 0) {
      out <- wards
      out$median_price <- NA_real_
      return(out)
    }
    
    #Get the medians for colouring the map
    medians <- result %>%
      group_by(NAME) %>%
      summarise(
        median_price = median(price, na.rm = TRUE),
        .groups = "drop"
      )
    
    #Join the medians to the wards dataset
    wards %>%
      left_join(medians, by = "NAME")
  })
  
  pal_reactive <- reactive({
    vals <- map_medians_reactive()$median_price
    
    if (all(is.na(vals))) {
      colorNumeric(
        palette = c("green", "yellow", "red"),
        domain = c(0, 1),
        na.color = "transparent"
      )
    } else {
      colorNumeric(
        palette = c("green", "yellow", "red"),
        domain = vals,
        na.color = "transparent"
      )
    }
  })
  
  #plot the map 
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      fitBounds(
        lng1 = st_bbox(wards)$xmin,
        lat1 = st_bbox(wards)$ymin,
        lng2 = st_bbox(wards)$xmax,
        lat2 = st_bbox(wards)$ymax
      )%>%
      setView(lng = -75.79, lat = 45.25, zoom = 10)
  })
  
  #Update map based on use inputs
  observe({
    #load map and datapoints
    map_data <- map_medians_reactive()
    pts <- filtered_points()
    
    proxy <- leafletProxy("map", data = map_medians_reactive()) %>%
      #Clear everything
      clearShapes() %>%
      clearMarkers() %>%
      clearControls() %>%
      
      #Add polygon shape of the wards
      addPolygons(
        fillColor = ~pal_reactive()(median_price),
        fillOpacity = 0.7,
        color = "black",
        weight = 1,
        
        #Add popup info
        popup = ~paste0(
          "<b>Ward:</b> ", NAME, "<br>",
          "<b>Median price:</b> ",
          ifelse(
            is.na(median_price),
            "No listings",
            paste0("$", format(round(median_price, 0), big.mark = ",", scientific = FALSE))
          )
        )
      ) 
    
    #If points table is not empty
    if (nrow(pts) > 0) {
      proxy <- proxy %>%
        addCircleMarkers(
          data = filtered_points(),
          radius = 3,
          color = "black",
          fillOpacity = 1,
          stroke = FALSE,
          popup = ~paste0(
            "<b>Price:</b> $", format(price, big.mark = ",", scientific = FALSE), "<br>",
            "<b>Address:</b> ", address, "<br>",
            "<b>Bedrooms:</b> ", beds, "<br>",
            "<b>Bathrooms:</b> ", baths, "<br>",
            "<b>House Type:</b> ", type
          )
        )
    }
     
    vals <- map_data$median_price
    
    #If median price is not empty
    if(!all(is.na(vals))){
      proxy <- proxy%>%
        addLegend(
        position = "bottomright",
        pal = pal_reactive(),
        values = ~median_price,
        data = map_medians_reactive(),
        title = "Median price",
        labFormat = labelFormat(prefix = "$", big.mark = ",", digits = 0)
      )
    }
  })
  
  
  #Download CSV button----
  output$download_summary <- downloadHandler(
    filename = function() {
      paste("house_listings.csv", sep = "")
    },
    content = function(file) {
      write.csv(filtered_points(), file)
    }
  )
}
