library('rvest')
library('magrittr')
library('dplyr')
library('xml2')

HDI_Calendar_CourseNames <- character()
HDI_Calendar_Data <- character()


#loop through all possible pages
for(i in 1:20) {
  
  #Read html page
  HDI_Calendar_Page <- paste("https://www.thinkhdi.com/education/calendar.aspx?pg=", i, sep="") %>%
    read_html()
  
  #get vector of course names from page
  HDI_Calendar_CourseNames <- HDI_Calendar_Page %>%
    html_nodes(".CourseSchedule-CourseLink") %>%
    html_text() %>%
    append(HDI_Calendar_CourseNames, .)
  
  
  # #get vector containing location and start and end dates
  # HDI_Calendar_Dates <- HDI_Calendar_Page %>%
  #   html_nodes(".CourseSchedule-lightbox-dates span") %>%
  #   html_text() %>%
  #   append(HDI_Calendar_Dates, .)
  
  #get vector containing location and start and end dates
  #need the :not selector to avoid picking up the pop-up windows
  HDI_Calendar_Data <- HDI_Calendar_Page %>%
    html_nodes(".CourseList-Item:not(.CourseSchedule-Register) > span  ") %>%
    html_text() %>%
    append(HDI_Calendar_Data, .)

}

#parse vector into start and end dates
HDI_Calendar_Dates_Start <- HDI_Calendar_Data[c(TRUE, FALSE, FALSE, FALSE)]
HDI_Calendar_Dates_End <- HDI_Calendar_Data[c(FALSE, TRUE, FALSE, FALSE)]

#parse vector into city and state
HDI_Calendar_City <- HDI_Calendar_Data[c(FALSE, FALSE, TRUE, FALSE)]
HDI_Calendar_State <- HDI_Calendar_Data[c(FALSE, FALSE, FALSE, TRUE)]

#remove some extra characters 
HDI_Calendar_Dates_Start <- sub(' - ', '', HDI_Calendar_Dates_Start)
HDI_Calendar_City <- sub(',','', HDI_Calendar_City)

#create data frame
HDI_Calendar.df <- data.frame(Course_Name = HDI_Calendar_CourseNames,
                              Start_Date = HDI_Calendar_Dates_Start, 
                              End_Date = HDI_Calendar_Dates_End, 
                              City = HDI_Calendar_City,
                              State = HDI_Calendar_State)

#virtual classrooms are incorrectly stored as the state, need to put them in the city column
#fortunately every city with the name "HDI" should actually be named "Virtual"
# is.HDI <- function(city) {
#   if (city == 'HDI') {
#     return(TRUE)
#   }
#   else {
#     return(FALSE)
#   }
# }

#change the location of virtual courses from 'HDI' to 'virtual'
HDI_Calendar.df$City <- gsub(x = HDI_Calendar.df$City, pattern = "HDI", replacement = "Virtual", perl = TRUE)

write.csv(HDI_Calendar.df, file="HDI Calendar.csv", na = "NA")

