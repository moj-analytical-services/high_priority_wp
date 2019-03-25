#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# ================================================================================
#
#
#
# ================================================================================

ui <- fixedPage(title = "DAMIT MI Delivery Whiteboard", responsive = FALSE,

      fixedRow(
        column(width = 12,
            tags$br(),
            tags$table(width = "100%",
              tags$tr(
                  tags$td(align = "center", bgcolor = "#FF0000", style = "font-family: arial; font-size: 16pt; font;color: white", tags$b("DAMIT MI Ad hoc Delivery Team - High Priority Commissions"))
              )
            )
        )
      ),                

      fixedRow(
        column(width = 12,
            tags$br(),
            tags$table(width = "100%",
              tags$tr(
                  tags$td(align = "right", style = "font-family: arial; font-size: 10pt; font;color: black", tags$b(tags$em(textOutput("theTimeandDate"))))
              )
            )
        )
      ),
                      
      fixedRow(
        column(width = 12,
            tags$em(
            tags$b(
            tags$ul(style = "font-family: Arial; font-size: 10pt;",
              tags$li("This web-page is a list of the open high-priority ad hoc commissions that the DAMIT Ad Hoc Team are currently working on."),
              tags$li("The commissions are listed by commissioning team rather than by delivery deadlines."),
              tags$li("Our delivery deadlines are flexibly nogotiated with our customers because of the priority attached to new commissions and relative changes of priority to existing commissions."),
              tags$li("The DAMIT Ad Hoc Team delivers through dynamic relative-prioritisation based on available resource and relative priority attached to our existing workload."),
              tags$li("The team also provides responses to low-priority commissions from our internal and external customers."),
              tags$li("A summary table of all commissions received by the team over the last 12-months and their current status appears below.")
            )))
          )
      ),
      
      fixedRow(
        column(8, plotOutput("hist")),
        column(4, 
          selectInput("StaSelect", "Status",
                      choices = list(
                        "All" = 1, 
                        "Open" = 2,
                        "Closed" = 3,
                        "On-hold" = 4), 
                      selected = 1,
                      multiple = FALSE, 
                      selectize = TRUE),
          selectInput("TypSelect", "Commission Type", 
                      choices = list(
                        "All" = 1, 
                        "Ad Hoc Query" = 2,
                        "DAP" = 3,
                        "Data Request" = 4,
                        "DSA" = 5,
                        "FOI" = 6,
                        "General/Data Query" = 7,
                        "New Report" = 8,
                        "PQ" = 9), 
                      selected = 1,
                      multiple = FALSE, 
                      selectize = TRUE),
          selectInput("SouSelect", "Jurisdiction", 
                      choices = list(
                        "All" = 1, 
                        "County" = 2,
                        "Crown" = 3,
                        "Magistrates" = 4,
                        "Court Cross Jurisdictonal" = 5,
                        "Family" = 6,
                        "Tribunals" = 7,
                        "Other" = 8), 
                      selected = 1,
                      multiple = FALSE, 
                      selectize = TRUE)
          )
      ),
      
      fixedRow(
        column(width = 12,
               tags$br(),
               tags$table(width = "100%",
                          tags$tr(
                            tags$td(align = "left", bgcolor = "#FF0000", style = "font-family: arial; font-size: 12pt; font;color: white", tags$b("Open High-priority Commissions"))
                          )
               ),
               tags$br(),
               tags$em(
                tags$div(style = "font-family: Arial; font-size: 10pt; font; color:black", "Commission relative priority is based on the type of work and the individual or team who are integral to or the final recipient of the ad hoc delivery. High-priority is attached to:-"),
                tags$ul(style = "font-family: Arial; font-size: 10pt; font; color:black",
                  tags$li("PQs, FOIs and one-off performance reporting for Ministerial briefing and A&P products."),
                  tags$li("Commissions by or from senior HMCTS operational and strategic staff, FGP and Ministers.")
                  )),
               tags$div(tableOutput("HPtable"), style = "font-family: arial; font-size: 10pt"),
               tags$table(width = "100%",
                          tags$tr(
                            tags$td(align = "right", style = "font-family: arial; font-size: 8pt; font;color: black", tags$b(tags$em(textOutput("noHighPro"))))
                                  )
                          ),
               tags$table(width = "100%",
                          tags$tr(
                            tags$td(align = "center", bgcolor = "#FF0000", style = "font-family: arial; font-size: 12pt; font;color: white", tags$b("Please contact the team to talk about any of these commissions"))
                                  )
                          ),
               tags$br()
                )
      )
)
