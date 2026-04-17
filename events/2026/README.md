# What can I afford? - Affordability Calculator
### Author: Valerie Figuracion
### For the R-Ladies International Women's Day (IWD) Data Challenge - 2026
A shiny app in where the user provides their annual income, down payment %, mortgage period, gets a personalized list of properties available at zillow.com at the time of the app launch.
Note: For simplicity, debts, and other necessary expenses (eg groceries) are omitted.

App is segmented into 3 files, global.R, server.R, and ui.R

**global.R** is responsible for gathering the data including:
- Scraping zillow.com to get the housing data 
- Using an API to pull Ottawa's ward data including the polygons for the shape of each ward

**server.R** is responsible for the logic of the app including:
- Determining maximum property price based on the user's income, mortgage period, and down payment % inputs
- Calculates the minimum income required to purchase the maximum property price based on user-defined mortgage period and down payment %
- Creating a table for the summary statistics including counts and averages
- Displaying and updating the map based on user inputs
- Functionality for downloading the filtered property list

**ui.R** is responsible for the look of the dashboard including, the sliders and  text boxes for user input, displaying the maximum property price based on user inputs, and displaying the map

#### Version 1.0 - Date: April 17, 2026
