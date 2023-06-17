---
title: "Intro to Shiny"
runtime: shiny
output: html_document
---

Shiny is an <a href="http://shiny.rstudio.com/" target="_blank">R package by 
RStudio<a/> that enables you to create interactive graphs. RStudio has a <a 
href="http://shiny.rstudio.com/tutorial/" target="_blank">great tutorial</a> for 
building and deploying Shiny apps. This tutorial won't assume that you've already 
familiar with Shiny, but it's a good idea to utilize RStudio's resources on their 
website.

## Basics

To make a Shiny app you need to have two `.R` scripts in the same folder:

* a user-interface script (ui)
* a server script

## ui.R

The `ui.R` script determines the layout and look of your app. Let's look at the 
`ui.R` for the __Hello Shiny__ example from the RStudio tutorial:

```{r, eval=FALSE}
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Hello Shiny!"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))
```

## server.R

The `server.R` script is where you put the code that will build the app.

```{r, eval=FALSE}

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically
  #     re-executed when inputs change
  #  2) Its output type is a plot

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]  # Old Faithful Geyser data
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
  })

})
```

## Running the app locally

To run an app locally, use the `runApp()` function. The `ui.R` and `server.R`
scripts for the __Hello Shiny__ app are found in the `shiny` library, so you can
run this app by placing the directory in the first argument:

```{r, eval=FALSE}
folder <- system.file("examples/01_hello", package="shiny")

runApp(appDir = folder)
```

```{r, echo=FALSE}
shinyAppDir(
  system.file("examples/01_hello", package="shiny"),
  options=list(
    width="100%", height=550
  )
)
```

## Chicago Air

We'll make a simple app using the the `chicago_air` dataset. 

```{r, eval=FALSE}
library(shiny)

# Define UI for application that plots time series
shinyUI(fluidPage(

  # Application title
  titlePanel("Chicago Air"),

  # Sidebar with a dropdown for selecting parameter
  sidebarLayout(
    sidebarPanel(
      selectInput("parameter",
                  "Select Parameter:",
                  "Ozone" = "ozone",
                  "Temperature" = "temp",
                  "Solar Radiation" = "solar")
    ),

    # Show a plot of the time series
    mainPanel(
      plotOutput("timePlot")
    )
  )
))
```

```{r, eval=FALSE}

library(shiny)
library(region5air)
data(chicago_air)
chicago_air$date <- as.Date(chicago_air$date)

  # Define server logic required to plot the time series
shinyServer(function(input, output) {
  
  output$timePlot <- renderPlot({
    ggplot(chicago_air, aes_string("date", input$parameter)) + geom_line() 
  })
})
```

If we have the `ui.R` and `server.R` scripts in a folder called `ChicagoApp` in our working directory, then we would run the app with

```{r, eval=FALSE}
runApp("ChicagoApp")
```

```{r, echo=FALSE}
shinyAppDir(
  "MyApp",
  options=list(
    width="100%", height=550
  )
)
```