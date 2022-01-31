## ----setup, include=FALSE------------------------------------------------------
knitr::opts_chunk$set(warning = FALSE, message = FALSE,error = FALSE, echo = FALSE) 


## ---- include= FALSE-----------------------------------------------------------
install.packages("tidyverse", repos='http://cran.us.r-project.org')
install.packages("ggmap", repos='http://cran.us.r-project.org')
install.packages("ggmap", repos='http://cran.us.r-project.org')
install.packages("pwr", repos='http://cran.us.r-project.org')
install.packages("hrbrthemes", repos='http://cran.us.r-project.org')
install.packages("googledrive", repos='http://cran.us.r-project.org')
install.packages("kableExtra", repos='http://cran.us.r-project.org')


## ---- echo = TRUE--------------------------------------------------------------

library(tidyverse)
library(purrr)
library(lubridate)
library(here)
library(hms)
library(scales)
library(rstudioapi)
library(ggmap)
library(pwr)
library(hrbrthemes)
library(googledrive)
library(kableExtra)


## ------------------------------------------------------------------------------

drive_download(
  as_id("1ZiEa7xBAaW0IXlQh97FCYMYOdkRuHL6u"),overwrite = TRUE) ## requires google account for use
bikeshare_v17 <- read_csv("bikeshare_v17.csv", 
    col_types = cols(
     ride_id = col_character(),
     member_casual = col_character(),
     rideable_type = col_character(),
     started_at = col_datetime(),
     ended_at = col_datetime(),
     day_of_week = col_double(),
     start_station_name = col_character(),
     start_station_id = col_character(),
     end_station_name = col_character(),
     end_station_id = col_character(),
     start_lat = col_double(),
     start_lng = col_double(),
     end_lat = col_double(),
     end_lng = col_double(),
     ride_length_min = col_double(),
     area = col_character(),
     ride_ml = col_double(),
     speed_mph = col_double()))


## ------------------------------------------------------------------------------
bikeshare_v17 %>%
  mutate(day_name = case_when(day_of_week == 1 ~ "Su",
                              day_of_week == 2 ~ "M",
                              day_of_week == 3 ~ "T",
                              day_of_week == 4 ~ "W",
                              day_of_week == 5 ~ "Th",
                              day_of_week == 6 ~ "F",
                              day_of_week == 7 ~ "S")) %>%
  mutate(day_name_2 = fct_relevel(day_name,"M","T","W","Th","F","S","Su")) %>%
  group_by(day_name_2,member_casual) %>%
  summarise(count = n()) %>%
  
ggplot(aes(x=day_name_2,
           y = count,
           group = member_casual,
           color = member_casual)) +
  geom_point(position = "dodge",
             size = 2,
             show.legend = FALSE) +
  geom_line(position = "dodge",
            size = 1,
            show.legend = FALSE) +
  scale_y_continuous("Total Rides",
                     labels = comma,
                     limits = c(0,700000),
                     expand = c(0,0)) +
  annotate("text",x = 2.5, y = 450000, label = "Members") + 
  annotate("text",x = 2.5, y = 200000, label = "Casuals") +
  labs(title = "Casuals like weekends",
       subtitle = "Members ride weekdays",
       x = NULL,
       caption = "Data: Oct-2020 to Oct-2021") +
  theme_ipsum()




## ------------------------------------------------------------------------------
bikeshare_v17 %>%
        
ggplot(aes(x = started_at,
           fill = member_casual)) +
  geom_density(alpha = .4) +
  scale_y_continuous("Rider Density",
                     labels = NULL, breaks = NULL) +
  scale_x_datetime(date_breaks = "months", date_labels = "%b",
                   minor_breaks = NULL) +
  scale_fill_discrete(name = "") +
  labs(title = "Yearly Rider Density",
       subtitle = "Comparing Members and Casuals",
       x = element_blank(),
       y = element_blank(),
       caption = "Data: Oct-2020 to Oct-2021") +
  theme_ipsum()


## ------------------------------------------------------------------------------
fun_peak <- function(x) { ## this function finds the corresponding x value for a max y value of the 
  d <- density(x)         ## density of a data frame
  d$x[which.max(d$y)]
  }


bikeshare_v17 %>%
  filter(ride_length_min < 46.618) %>% ## 92.6% of all rows, outliers eliminated through IQR method
  
ggplot(aes(x = ride_length_min,
           fill = member_casual)) +
  geom_density(alpha = .4) +
  expand_limits(y = 0.1) +
  scale_y_continuous("Rider Density",
                     labels = NULL, breaks = NULL) +
  scale_fill_discrete(name = "") +
  labs(title = "Ride Time",
       subtitle = "Members take shorter rides",
       x = "Minutes",
       y = element_blank(),
       caption = "Data: Oct-2020 to Oct-2021") +
  theme_ipsum()

bikeshare_v17 %>%
  filter(ride_length_min < 46.618,
         ride_ml != 0) %>% ## 92.6% of all rows, outliers eliminated through IQR method
  
ggplot(aes(x = speed_mph,
           fill = member_casual)) +
  geom_density(alpha = .4) +
  expand_limits(y = 0.2) +
  scale_y_continuous("Rider Density",
                     labels = NULL, 
                     breaks = NULL) +
  scale_x_continuous(limits = c(0,20)) +
  scale_fill_discrete(name = "") +
  labs(title = "Average Speed",
       subtitle = "Members go faster than Casuals",
       x = "MpH",
       y = element_blank(),
       caption = "Data: Oct-2020 to Oct-2021") +
  theme_ipsum()

bikeshare_v17 %>%
  filter(ride_length_min < 46.618,
         ride_ml != 0) %>% ## 92.6% of all rows, outliers eliminated through IQR method
  
ggplot(aes(x = ride_ml,
           fill = member_casual)) +
  geom_density(adjust = 4,
               alpha = .4) +
  expand_limits(y = 0.2) +
  scale_y_continuous("Rider Density",
                     labels = NULL, 
                     breaks = NULL) +
  scale_x_continuous(limits = c(0,8)) +
  scale_fill_discrete(name = "") +
  labs(title = "Distance",
       subtitle = "Members and Casuals ride a Similar Distance",
       x = "Miles",
       y = element_blank(),
       caption = "Data: Oct-2020 to Oct-2021") +
  theme_ipsum()






## ------------------------------------------------------------------------------
bikeshare_v17 %>%                                      
  filter(ride_length_min < 46.4) %>%
  group_by(member_casual) %>%
  summarise(ebike_rate = sum(rideable_type == "electric_bike")/n(),
            dist = mean(ride_ml),
            speed = mean(speed_mph),
            count = n()) %>%
  
ggplot(aes(x = member_casual,
           y = ebike_rate,
           fill = member_casual)) +
  geom_col(position = "dodge",
           width = .3) +
  geom_text(aes(label = percent(ebike_rate,1)),
            vjust = -.75) +
  scale_y_percent("Percent of rides taken on Ebikes",
                  limits = c(0,1)) +
  scale_x_discrete("",
                   breaks = NULL) +
  scale_fill_discrete(name = "") +
  labs(title = "Members vs. Casuals on ebikes",
       subtitle = "Casuals have only a slight preference",
       caption = "Data: Oct-2020 to Oct-2021") +
  theme_ipsum()


bikeshare_v17 %>%                                     
  filter(ride_length_min < 46.4,
         ride_ml != 0) %>%
  mutate(area_grouped = case_when(area == "Ev_nocollege" ~ "Z1",   ## Z1 and Z2 together to check price
                                  area == "Z1" ~ "Z1",
                                  area == "Ev_NW_College" ~ "Z1",
                                  area == "Z2_nocollege" ~ "Z2",
                                  area == "Hyde_Park" ~ "Z2")) %>%
  group_by(area_grouped,member_casual) %>%
  summarise(ebike_rate = sum(rideable_type == "electric_bike")/n(),
            dist = mean(ride_ml),
            speed = mean(speed_mph),
            count = n()) %>%
  
ggplot(aes(x = area_grouped,
           y = ebike_rate)) +
  geom_col(aes(fill = member_casual),
           position = "dodge",
           width = .5) +
  geom_text(aes(label = percent(ebike_rate,1),
             group = member_casual),
             position = position_dodge(width = .5),
            vjust = -.75) +
  scale_y_percent("Percent of rides taken on Ebikes",
                  limits = c(0,1)) +
  scale_x_discrete("") +
  scale_fill_discrete(name = "") +
  labs(title = "Zone 2 loves E-bikes",
       subtitle = "Zone has a much larger effect than membership",
       caption = "Data: Oct-2020 to Oct-2021") +
  theme_ipsum() 



## ------------------------------------------------------------------------------

rideable <- c("E-bike","Classic")
Z1_Casual <- c("$4.50","$3.30")
Z1_Member <- c("$0.90","$0.00")
Z2_Casual <- c("$3.30","$3.30")
Z2_Member <- c("$0.00","$0.00")

comparison <- data.frame(rideable,Z1_Casual,Z1_Member,Z2_Casual,Z2_Member)

comparison %>%
  select(rideable,everything()) %>%
  arrange(desc(rideable)) %>%
  kable(col.names = c("","Casual","Member","Casual","Member")) %>%
  column_spec(c(1:5), border_right = T) %>%
  kable_styling(bootstrap_options = "striped", full_width = FALSE) %>%
  collapse_rows(columns = 1) %>%
    add_header_above(c(" " = 1, "Z1" = 2, "Z2" = 2))

