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
# ui.R is responsible for the look of the dashboard including the sliders and 
# text boxes for user input, displaying the maximum property price based on
# user inputs, and displaying the map
#
# Version 1.0
# Date: April 17, 2026
#-----------------------------------------

library(shiny)

# Define UI for application----
fluidPage(
  
  ##Application title----
  h2("What Can I Afford? - Simple Affordability Property Dashboard", align="center"),
  h6("Note: This assumes you have no debt, your groceries are paid for, and someone else is paying property taxes", align="center"),
  
  ##Top 1/3 ----
  fluidRow(
    column(
      3,
      #Max house price
      div(
        style = "
          border: 1px solid #ccc;
          border-radius: 10px;
          padding: 12px;
          background-color: #f9f9f9;
          height: 125px;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          text-align: center;
        ",
        div(
          style = "font-size: 16px; margin-bottom: 8px;",
          "The maximum property price is"
        ),
        div(
          style = "font-size: 30px; font-weight: bold;",
          textOutput("maxPrice", inline = TRUE)
        )
      )
    ),
    
    column(
      3,
      # Down Payment %
      div(
        style = "
        border: 1px solid #ccc;
        border-radius: 10px;
        padding: 12px;
        background-color: #f9f9f9;
        height: 125px;
      ",
        sliderInput("downPayment", 
                    "Down Payment (%)", 
                    min = 5, max = 99, value = 20)
      )
      
    ),
    
    column(
      3,
      # Number of years of Mortgage
      div(
        style = "
        border: 1px solid #ccc;
        border-radius: 10px;
        padding: 12px;
        background-color: #f9f9f9;
        height: 125px;
      ",
        
      sliderInput("yrsMortgage", 
                  "Mortgage Period (Years)", 
                  min = 5, max = 30, value = 25) 
      )
    ),
    
    column(
      3,
      #Gross Household Income
      div(
        style = "
        border: 1px solid #ccc;
        border-radius: 15px;
        padding: 12px;
        background-color: #f9f9f9;
        height: 125px;
      ",
        
        numericInput( 
          "grossIncome", 
          "Gross Annual Household Income (CAD)", 
          value = 100000, 
          min = 1
        ) 
      )
    ),
  ),
  
  ##Bottom 2/3----
  fluidRow(
    style = "margin-top: 20px;",
    column(3,
           #Min income 
           fluidRow(
             div(
               style = "text-align: center; 
                 font-size: 14px; 
                 padding: 12px;"
                 ,
               "Did you know? You would need",
               strong(textOutput("minIncome", inline = TRUE)),
               "gross annual income to afford any property you want!"
             ),
           ),
           #Average bedrooms table
            tableOutput("summaryTable"),
           #House type table
            tableOutput("countTable"),
           
           #Download Button
           downloadButton(
               outputId = "download_summary",
               label = "Want to save your results? Click here for the CSV", width = "100%"
             ),
           
           #Sources
           h6("Housing data source: ",
              a("zillow.com", 
              href= "https://www.zillow.com/ottawa-on/",
              target = "_blank",
              style = "color: blue; text-decoration: underline;"),
              align="center"),
           h6("Map data source: ", 
              a("open.ottawa.ca", 
                href= "https://open.ottawa.ca/datasets/8973061e1b0c4cd09b4495088c04c310_0/explore?location=45.249380%2C-75.801082%2C1",
                target = "_blank",
                style = "color: blue; text-decoration: underline;"),
              align="center")
          ),
        
    
    column(9,
           #Map
           leafletOutput("map", height = "650px")
           )
  ),
  
)
