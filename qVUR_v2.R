library(shiny)
library(shinythemes)
library(readr)
library(markdown)
library(imager)
library(rsconnect)
library(ggplot2)
library(jpeg)
library(shinydashboard)
library(shinyWidgets)
library(base64enc)


####################################
# User Interface                   #
####################################
ui <- fluidPage(theme = shinytheme("cosmo"),
                useShinydashboard(),
                navbarPage("qVUR",
                           
                           tabPanel("VUR Determination",
                                    # Input values
                                    sidebarPanel(
                                      HTML("<h3>Patient Information</h4>"),
                                      fileInput("file1", "Input your 2D VCUG in .jpg or .png format.",
                                                accept = c('image/png', 'image/jpeg','image/jpg')),
                                      HTML("<h4> Steps </h2>"),
                                      HTML("<h5> 1. Select Tortuosity, and click through the midline of the ureter from the UPJ to the UVJ on the query side.</h1>"),
                                      HTML("<h5> 2. Select UPJ and then click on the edges of the UPJ. </h1>"),
                                      HTML("<h5> 3. Select UVJ, and then click on the edges of the UVJ. </h1>"),
                                      HTML("<h5> 4. Select Max. Ureter Width, and then click on the edges of the ureter at the position of max. ureter width.</h1>"),
                                      HTML("<h5> 5. Click <b>Grade VUR</b>. </h1>"),
                                      actionButton("submitbutton", 
                                                   "Grade VUR", 
                                                   class = "btn btn-primary"),
                                      radioButtons("pen", label = h4("Choose pen color"),
                                                   choices = list("Tortuosity" = 1, "UPJ" = 2, "UVJ" = 3, "Max. Ureter Width"=4), 
                                                   selected = 1),
                                      actionButton("resetbutton", 
                                                   "Reset", 
                                                   class = "btn btn-primary"),
                                    ),
                                    mainPanel(
                                      tags$label(h3('Patient VCUG')),
                                      plotOutput(outputId = "plot_image", click="plot_click"),
                                      
                                      fluidRow(
                                        valueBoxOutput("x", width=4),
                                        valueBoxOutput("y", width=4),
                                        valueBoxOutput("info", width=4),
                                      ),
                                      
                                      fluidRow(
                                        column(width = 10,
                                               infoBoxOutput("DistBlack", width=NULL),
                                               
                                               infoBoxOutput("DistRed", width=NULL),
                                               infoBoxOutput("DistBlue", width=NULL),
                                               infoBoxOutput("DistGreen", width=NULL),
                                        )),
                                      htmlOutput("grade")
                                    ),
                           ), 
                           tabPanel("About", 
                                    titlePanel("About"), 
                                    div(includeMarkdown("about.md"), 
                                        align="justify")
                           )))

####################################
# Server                           #
####################################
server <- function(input, output, session) {
  
  pathLength <- function(vals){
    
    pL<-0
    
    #calculates total distance of path
    for(i in 1:(nrow(vals$pt_x )-1)){
      if(nrow(vals$pt_x)<=1){
        pL = 0
      }else{
        pL = pL + sqrt((vals$pt_x$x[i]-vals$pt_x$x[i+1])^2 +(vals$pt_x$y[i]-vals$pt_x$y[i+1])^2)
      }
    }
    return(pL)
  }
  
  tau <- function(vals){
    
    pL<-0
    
    #calculates tortuosity
    for(i in 1:(nrow(vals$pt_x )-1)){
      if(nrow(vals$pt_x)<=1){
        pL = 0
        tau =0
      }else{
        pL = pL + sqrt((vals$pt_x$x[i]-vals$pt_x$x[i+1])^2 +(vals$pt_x$y[i]-vals$pt_x$y[i+1])^2)
        tau = pL/sqrt((vals$pt_x$x[i+1]-vals$pt_x$x[1])^2 + (vals$pt_x$y[i+1]-vals$pt_x$y[1])^2)
      }
    }
    return(tau)
  }
  
  normd <- function(vals){
    
    pL<-0
    
    #calculates tortuosity
    for(i in 1:(nrow(vals$pt_x )-1)){
      if(nrow(vals$pt_x)<=1){
        normd=0
      }else{
        normd = sqrt((vals$pt_x$x[i+1]-vals$pt_x$x[1])^2 +(vals$pt_x$y[i+1]-vals$pt_x$y[1])^2)
      }
    }
    return(normd)
  }
  
  
  observeEvent(input$resetbutton, {
    
    show_alert("The session will be refreshed")
    session$reload()
    
  })
  
  #for the initial line
  pts <- read_csv("data_array.csv")
  vals <- data.frame()
  vals <- reactiveValues(pt_x = pts[, c("x", "y")])
  
  
  
  #for secondary lines
  altvals1 <- data.frame()
  altvals1 <- reactiveValues(pt_x = pts[, c("x", "y")])
  
  altvals2 <- data.frame()
  altvals2 <- reactiveValues(pt_x = pts[, c("x", "y")])
  
  altvals3 <- data.frame()
  altvals3 <- reactiveValues(pt_x = pts[, c("x", "y")])
  
  #calculate score
  
  output$plot_image <- renderPlot({
    
    #ACTION <--- for loading the picture
    if(is.null(input$file1)){
      xray_test <- load.image("test_2.jpg")
      plot(xray_test, type= "l")
      lines(vals$pt_x)  
      lines(altvals1$pt_x, col="red")
      lines(altvals2$pt_x, col="blue")
      lines(altvals3$pt_x, col="green")
    }else{
      
      xray_test <- load.image(input$file1[[4]])
      plot(xray_test, type= "l")
      lines(vals$pt_x)  
      lines(altvals1$pt_x, col="red")
      lines(altvals2$pt_x, col="blue")
      lines(altvals3$pt_x, col="green")
    }
  })
  
  observeEvent(input$plot_click, {
    #if black pen is selected
    if(input$pen == 1){
      vals$pt_x <- rbind(vals$pt_x, data.frame(x = input$plot_click$x, y = input$plot_click$y))
    }
    #if red pen is selected
    if(input$pen == 2){
      if(nrow(altvals1$pt_x)<2){
        altvals1$pt_x <- rbind(altvals1$pt_x, data.frame(x = input$plot_click$x, y = input$plot_click$y))
      }
    }
    #if blue pen is selected
    if(input$pen == 3){
      if(nrow(altvals2$pt_x)<2){
        altvals2$pt_x <- rbind(altvals2$pt_x, data.frame(x = input$plot_click$x, y = input$plot_click$y))
      }
    }
    #if green pen is selected
    if(input$pen == 4){
      if(nrow(altvals3$pt_x)<2){
        altvals3$pt_x <- rbind(altvals3$pt_x, data.frame(x = input$plot_click$x, y = input$plot_click$y))
        
      }
    }
    
  })  
  
  output$x <- renderValueBox({
    valueBox(
      value = tags$p("X, Y (Pixels)", style = "font-size: 40%;"),  
      if(nrow(vals$pt_x)==0){
        paste0("")
      }else{
        paste0(formatC(vals$pt_x$x[nrow(vals$pt_x)]), ", ", formatC(vals$pt_x$y[nrow(vals$pt_x)]))
      }, 
      color = "black")
  })
  
  output$y <- renderValueBox({
    valueBox(
      value = tags$p("Path Length (Pixels)", style = "font-size: 40%;"),  
      if(nrow(vals$pt_x)==0){
        paste0("")
      }else{
        paste0(formatC(pathLength(vals)))
      }, 
      color = "black")
  })
  
  output$info <- renderValueBox({
    valueBox(
      value = tags$p("Grade", style = "font-size: 40%;"),  
      if(input$submitbutton>0){
        n_UPJ <- 100*pathLength(altvals1)/normd(vals)
        n_UVJ <- 100*pathLength(altvals2)/normd(vals)
        n_MUD <- 100*pathLength(altvals3)/normd(vals)
        
        if(tau(vals) < 1.2855 & n_MUD < 5.892 & n_UVJ < 2.994){score <- 2}
        if(tau(vals) < 1.2855 & n_MUD < 5.892 & n_UVJ > 2.994 & n_MUD < 3.153){score <- 2}
        if(tau(vals) < 1.2855 & n_MUD < 5.892 & n_UVJ > 2.994 & n_MUD > 3.153 & n_MUD < 3.917){score <- 3}
        if(tau(vals) < 1.2855 & n_MUD < 5.892 & n_UVJ > 2.994 & n_MUD > 3.153 & n_MUD > 3.917){score <- 2}
        if(tau(vals) < 1.2855 & n_MUD > 5.892 & n_MUD < 14 & n_UPJ < 7.7915){score <- 3}
        if(tau(vals) < 1.2855 & n_MUD > 5.892 & n_MUD < 14 & n_UPJ > 7.7915 & tau(vals) < 1.103){score <- 3}
        if(tau(vals) < 1.2855 & n_MUD > 5.892 & n_MUD < 14 & n_UPJ > 7.7915 & tau(vals) > 1.103){score <- 4}
        if(tau(vals) < 1.2855 & n_MUD > 5.892 & n_MUD > 14 & n_MUD < 17.055 & n_UVJ < 12.955){score <- 3}
        if(tau(vals) < 1.2855 & n_MUD > 5.892 & n_MUD > 14 & n_MUD < 17.055 & n_UVJ > 12.955){score <- 4}
        if(tau(vals) < 1.2855 & n_MUD > 5.892 & n_MUD > 14 & n_MUD > 17.055){score <- 4}
        if(tau(vals) > 1.2855 & tau(vals) < 1.6875 & n_MUD < 11.97){score <- 3}
        if(tau(vals) > 1.2855 & tau(vals) < 1.6875 & n_MUD > 11.97 & n_UPJ < 10.74){score <- 4}
        if(tau(vals) > 1.2855 & tau(vals) < 1.6875 & n_MUD > 11.97 & n_UPJ > 10.74){score <- 5}
        if(tau(vals) > 1.2855 & tau(vals) > 1.6875 & n_UPJ < 7.9065 & n_UPJ < 7.7975){score <- 5}
        if(tau(vals) > 1.2855 & tau(vals) > 1.6875 & n_UPJ < 7.9065 & n_UPJ > 7.7975){score <- 4}
        if(tau(vals) > 1.2855 & tau(vals) > 1.6875 & n_UPJ > 7.9065){score <- 5} 
        paste0(score)},
      color = "black")
  })
  
  output$DistBlack <-renderInfoBox({
    infoBox(
      "Tortuosity",
      formatC(tau(vals)),
      color = "black")
    
  })
  
  output$DistRed <-renderInfoBox({
    infoBox(
      "UPJ (Pixels)",
      formatC(100*pathLength(altvals1)/normd(vals)),
      color = "red")
    
  })
  
  output$DistBlue <-renderInfoBox({
    infoBox(
      "UVJ (Pixels)",
      formatC(100*pathLength(altvals2)/normd(vals)),
      color = "blue")
  })
  
  output$DistGreen <-renderInfoBox({
    infoBox(
      "Max Ureter Width (Pixels)",
      formatC(100*pathLength(altvals3)/normd(vals)),
      color = "green"
    )
    
  })
}

####################################
# Create Shiny App                 #
####################################
shinyApp(ui = ui, server = server)
