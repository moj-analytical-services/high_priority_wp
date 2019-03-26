
library(dplyr)
library(lubridate)
library(tibble)
library(stringr)
library(ggplot2)
library(shiny)
library(s3tools)

server <- function(input, output) {
  
  # ================================================================================
  #
  # open the OPT csv file
  #
  # ================================================================================
  
  # frmOPTData <- read.csv(file="/home/pythagoras77/high_priority_wp/www/DAMIT Helpdesk Calls 25_03_MS_DOS.csv", header=TRUE, sep=",")
  
  # df <-s3tools::s3_path_to_full_df("alpha-everyone/s3tools_tests/folder1/iris_folder1_1.csv")  

  frmOPTData <-s3tools::s3_path_to_full_df("alpha-DAMIT_MI_DEL/HP_WebPage/Data/DAMIT Helpdesk Calls 25_03_MS_DOS.csv")
  
  # ================================================================================
  #
  # clean the data
  #
  # ================================================================================
  
  frmOPTData$ID_Conv <- parse_date_time(frmOPTData$IDENTIFIED_DATE, orders = "d-b-y")
  
  frmChtSeq <- data.frame(
    ChtYear = c(2019, 2019, 2019, 2018, 2018, 2018, 2018, 2018, 2018, 2018, 2018, 2018),
    ChtMonth = c(3, 2, 1, 12, 11, 10, 9, 8, 7, 6, 5, 4)
  )
  
  # ================================================================================
  #
  # calculate additional variables
  #
  # ================================================================================
  
  frmOPTData$STATUS <- as.character(frmOPTData$STATUS)
  frmOPTData$MEASURE_NAME <- as.character(frmOPTData$MEASURE_NAME)
  frmOPTData$HELPDESK_CALL_TYPE_NAME <- as.character(frmOPTData$HELPDESK_CALL_TYPE_NAME)
  
  frmOPTData$STATUS[is.na(frmOPTData$STATUS)] <- "NA"
  frmOPTData$MEASURE_NAME[is.na(frmOPTData$MEASURE_NAME)] <- "NA"
  frmOPTData$HELPDESK_CALL_TYPE_NAME[is.na(frmOPTData$HELPDESK_CALL_TYPE_NAME)] <- "NA"
  
  frmOPTData$ChtYear <- year(frmOPTData$ID_Conv)
  frmOPTData$ChtMonth <- month(frmOPTData$ID_Conv)
  
  frmOPTData <- transform(frmOPTData, 
                          ChtStatus = 
                            ifelse(STATUS == "NA", "NA",
                            ifelse(STATUS == "Open", "OPEN", 
                            ifelse(STATUS == "Closed", "CLOSED", "ON-HOLD"))))
  
  frmOPTData <- transform(frmOPTData,
                          ChtSource =
                            ifelse((MEASURE_NAME == "-" | MEASURE_NAME == "Other" | MEASURE_NAME == "Enforcement"),"OTHER",
                            ifelse(MEASURE_NAME == "Civil - County", "COUNTY",
                            ifelse(MEASURE_NAME == "Crime - Crown", "CROWN",
                            ifelse(MEASURE_NAME == "Crime - Magistrates", "MAGS",
                            ifelse((MEASURE_NAME == "Crime (Crown and Mags)" | MEASURE_NAME == "Cross-Jurisdictional"), "COURT_X",
                            ifelse(MEASURE_NAME == "Family", "FAMILY", "TRIBUNALS")))))))

  
  frmOPTData <- transform(frmOPTData,
                          ChtType =
                            ifelse(HELPDESK_CALL_TYPE_NAME == "Ad Hoc Query ","ADHOC",
                            ifelse(HELPDESK_CALL_TYPE_NAME == "DAP Request", "DAP",
                            ifelse(HELPDESK_CALL_TYPE_NAME == "Data Request", "DATAREQ",
                            ifelse(HELPDESK_CALL_TYPE_NAME == "Data Share Agreement", "DSA",
                            ifelse((HELPDESK_CALL_TYPE_NAME == "FOI" | HELPDESK_CALL_TYPE_NAME == "FOI Data" | HELPDESK_CALL_TYPE_NAME == "FOI Response"), "FOI",
                            ifelse(HELPDESK_CALL_TYPE_NAME == "General/Data Query", "GENDATA", 
                            ifelse(HELPDESK_CALL_TYPE_NAME == "New Report Request","NEWREP", "PARQ"))))))))
  
  frmOPTTable <- frmOPTData %>%
    filter((ChtStatus == "OPEN") & (PRIORITY == "High")) %>%
    select(Call.Number, HELPDESK_CALL_TYPE_NAME, HELPDESK_CALL_SUMMARY, MEASURE_NAME, IDENTIFIED_DATE, Requestor.Team.Name)
  
  names(frmOPTTable)[names(frmOPTTable)=="Call.Number"] <- "Job"
  names(frmOPTTable)[names(frmOPTTable)=="HELPDESK_CALL_TYPE_NAME"] <- "Type"
  names(frmOPTTable)[names(frmOPTTable)=="HELPDESK_CALL_SUMMARY"] <- "Summary"
  names(frmOPTTable)[names(frmOPTTable)=="MEASURE_NAME"] <- "Jurisdiction"
  names(frmOPTTable)[names(frmOPTTable)=="IDENTIFIED_DATE"] <- "Identified"
  names(frmOPTTable)[names(frmOPTTable)=="Requestor Team Name"] <- "Team"
  
  frmOPTData <- select(frmOPTData, Call.Number, ChtMonth, ChtYear, ChtStatus, ChtType, ChtSource)

  output$theTimeandDate <- renderText({
    
    td <- Sys.time()
    strftime(td,"%A %d %B, %Y")

  })

  data <- reactive({
    
    if (input$StaSelect == "1") {
      
      StaOpt <- c("OPEN","CLOSED","ON-HOLD")
      
    } else if (input$StaSelect == "2") {
      
      StaOpt <- c("OPEN")
      
    } else if (input$StaSelect == "3") {
      
      StaOpt <- c("CLOSED")
      
    } else {
      
      StaOpt <- c("ON-HOLD")
      
    }

    if (input$SouSelect == "1") {
      
      SouOpt <- c("OTHER","COUNTY","CROWN","MAGS","COURT_X","FAMILY","TRIBUNALS")
      
    } else if (input$SouSelect == "2") {
      
      SouOpt <- c("COUNTY")
      
    } else if (input$SouSelect == "3") {
      
      SouOpt <- c("CROWN")
 
    } else if (input$SouSelect == "4") {
      
      SouOpt <- c("MAGS")

    } else if (input$SouSelect == "5") {
      
      SouOpt <- c("COURT_X")
      
    } else if (input$SouSelect == "6") {
      
      SouOpt <- c("FAMILY")

    } else if (input$SouSelect == "7") {
      
      SouOpt <- c("TRIBUNALS")

    } else {
      
      SouOpt <- c("OTHER")
      
    }

    if (input$TypSelect == "1") {
      
      TypOpt <- c("ADHOC","DAP","DATAREQ","DSA","FOI","GENDATA","NEWREP","PARQ")

    } else if (input$TypSelect == "2") {
      
      TypOpt <- c("ADHOC")
      
    } else if (input$TypSelect == "3") {
      
      TypOpt <- c("DAP")
      
    } else if (input$TypSelect == "4") {
      
      TypOpt <- c("DATAREQ")
      
    } else if (input$TypSelect == "5") {
      
      TypOpt <- c("DSA")
      
    } else if (input$TypSelect == "6") {
      
      TypOpt <- c("FOI")
      
    } else if (input$TypSelect == "7") {
      
      TypOpt <- c("GENDATA")
      
    } else if (input$TypSelect == "8") {
      
      TypOpt <- c("NEWREP")
      
    } else {
      
      TypOpt <- c("PARQ")
      
    }

    frmChtData <- frmOPTData %>%
        group_by(ChtYear, ChtMonth) %>%
        filter((ChtStatus %in% StaOpt) & (ChtSource %in% SouOpt) & (ChtType %in% TypOpt)) %>%
        summarize(ChtData = n()) %>%
        arrange(desc(ChtYear), desc(ChtMonth))  
          
    frmChtSeq <- frmChtSeq %>% left_join(frmChtData, by = c("ChtYear", "ChtMonth"))
    
    frmChtSeq$ChtData[is.na(frmChtSeq$ChtData)] <- 0
    frmChtSeq$ChtYrMn <- str_c(frmChtSeq$ChtYear, sprintf("%02d", frmChtSeq$ChtMonth), sep = "/")
  
    frmChtSeq <- select(frmChtSeq, ChtYrMn, ChtData)   
    
    data <- frmChtSeq
        
})

  output$hist <- renderPlot({
    
    ggplot(data = data(), mapping = aes(x = ChtYrMn, y = ChtData)) +
      geom_bar(stat = "identity", fill="#FF9999", colour="black") +
      geom_text(aes(label = ChtData), vjust = -0.5, size = 3.5) +
      scale_y_continuous(limits = c(0,120)) +
      xlab("Year/Month") +
      ylab("Commissions")

  })
  
  output$HPtable <- shiny::renderTable({
    
    frmOPTTable %>% arrange(Requestor.Team.Name)
    
  }, striped = TRUE, border = FALSE, spacing = c("xs"), align = "llllrr")
  

  output$noHighPro <- renderText({
    
    totHighPrio <- frmOPTTable %>% ungroup() %>% summarise(totComm = n())
    
    paste0("Total Open High Priority Commissions = ",totHighPrio)
    
  })
  
}

