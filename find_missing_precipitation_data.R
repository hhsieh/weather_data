setwd("/Users/hsiehhs7/Documents/Analyses for Phil/precipitation")
list.files()

#kbs <- read.csv("data-kbs_1950_05_01_to_2023_11_01.csv")
kbs <- read.csv("data-kbs_with_missing_precip.csv")

head(kbs)

library(rjson)
library(tidyverse)
#read in the weather station precipitation data in JSON format
hastings <- fromJSON(file = "hastings_10_years_precip_data.JSON")
bc <- fromJSON(file = "precip_BattleCreek5NW.JSON")
burlington <- fromJSON(file = "precip_Burlington.JSON")

un_hastings <- enframe(unlist(hastings$data))
un_bc <- enframe(unlist(bc$data))
un_burlington <- enframe(unlist(burlington$data))

str(hastings) #list of 3533
str(bc) #list of 19562
str(burlington) #list of 16621

#restructure the ws precipitation data
df_hastings <- data.frame(no = seq(3533), date = '', precipitation = '')
df_bc <- data.frame(no = seq(19562), date = '', precipitation = '')
df_burlington <- data.frame(no = seq(16621), date = '', precipitation = '')

df_hastings$date <- un_hastings[which(un_hastings$name %% 2 == 1), ]$value
df_hastings$precipitation <- un_hastings[which(un_hastings$name %% 2 == 0), ]$value
head(df_hastings)

df_bc$date <- un_bc[which(un_bc$name %% 2 == 1), ]$value
df_bc$precipitation <- un_bc[which(un_bc$name %% 2 == 0), ]$value
head(df_bc)

df_burlington$date <- un_burlington[which(un_burlington$name %% 2 == 1), ]$value
df_burlington$precipitation <- un_burlington[which(un_burlington$name %% 2 == 0), ]$value

#create a station column and merge the data frames
df_hastings$station <- "Hastings"
df_bc$station <- "Battle Creek"
df_burlington$station <- "Burlington"

df_three <- df_hastings %>% rbind(df_bc) %>% rbind(df_burlington) %>%
  select(date, precipitation, station) %>%
  mutate(precipitation = as.numeric(precipitation)* 25.4)

kbs$station <- 'KBS'

big <- kbs %>% 
  filter(is.na(precipitation) == FALSE) %>%
  select(date, precipitation, station) %>%
  mutate(precipitation = as.numeric(precipitation)) %>%
  rbind(df_three) %>% 
  arrange(date) %>%
  spread(key = station, value = precipitation)

head(big)
big$date <- as.Date(big$date, format = '%Y-%m-%d')
head(big$date)

#write.csv(big, 'merged_precip_data.csv', row.names = FALSE)

dim(big %>% filter(is.na(KBS) == TRUE)) 


filling_candidates <- big %>%
  filter(is.na(`Battle Creek`) == FALSE |
           is.na(Hastings) == FALSE |
           is.na(Burlington) == FALSE) %>%
  filter(is.na(KBS) == TRUE)

write.csv(filling_candidates, 'candidate_data_to_fill_KBS.csv', row.names = FALSE)

#KBS ~ Battle Creek
big %>% ggplot(aes(`Battle Creek`, KBS)) +
  geom_point() +
  geom_smooth(method = lm, se = TRUE, formula = 'y~x') +
  ggtitle("precipitation correlation, 1970 to 2023")

mo1 <- lm(big$kbs ~ big$`Battle Creek`)
summary(mo1)  

big1 <- big %>% filter(KBS < 100) 

big1 %>% ggplot(aes(`Battle Creek`, KBS)) +
  geom_point() +
  geom_smooth(method = lm, se = TRUE, formula = 'y~x') +
  ggtitle("precipitation correlation, 1970 to 2023, KBS > 100 data removed")
  
mo3 <- lm(big1$KBS ~ big1$`Battle Creek`)
summary(mo3)



#KBS ~Hastings
big %>% ggplot(aes(Hastings, KBS)) +
  geom_point() +
  geom_smooth(method = lm, se = TRUE, formula = 'y~x') +
  ggtitle("precipitation correlation, 1978 to 1988")

# KBS ~ Burlington
big %>% ggplot(aes(Burlington, KBS)) +
  geom_point() +
  geom_smooth(method = lm, se = TRUE, formula = 'y~x') +
  ggtitle("precipitation correlation, 1978 to 1988")

mo2 <- lm(big$KBS ~ big$Burlington)
summary(mo2)



##

library(rjson)
dd <- fromJSON(file = 'hastings_10_years_precip_data.JSON')
head(dd)

dd[[1]]
dd[[2]][[1]]

str(dd, max.level = 3, list.len = 4)

un <- enframe(unlist(dd$data))

df <- data.frame(no = seq(3533), date = '', precipitation = '')

df$date <- un[which(un$name %% 2 == 1), ]$value
head(df$date)
df$precipitation = as.numeric(un[which(un$name %% 2 == 0), ]$value)
head(df$precipitation)

df$precipitation_mm <- df$precipitation * 25.4

head(df)


##correlate KBS and Hasting data 1978-1988

merged <- merge(df, kbs, by.x = "date", by.y = 'date')
head(merged)


merged %>% 
  #filter(precipitation_mm < 100 & precipitation.y < 100) %>% 
  ggplot(aes(precipitation_mm, precipitation.y)) +
  geom_point() +
  #geom_abline(intercept = 0, slope = 1, size = 0.5) +
  geom_smooth(method = lm, se = TRUE, formula = 'y~x') +
  xlab('Hastings precipitation') +
  ylab('KBS precipitation') +
  ggtitle('1978-1988 precipitation')

merged %>% 
  filter(precipitation_mm < 100 & precipitation.y < 100) %>% 
  ggplot(aes(precipitation_mm, precipitation.y)) +
  geom_point() +
  #geom_abline(intercept = 0, slope = 1, size = 0.5) +
  geom_smooth(method = lm, se = TRUE, formula = 'y~x') +
  xlab('Hastings precipitation') +
  ylab('KBS precipitation') +
  ggtitle('1978-1988 precipitation - high precipitation data removed')

model <- lm(merged$precipitation.y ~ merged$precipitation_mm)
summary(model)

merged$date <- as.Date(merged$date, format = '%Y-%m-%d')
head(merged$date)
ggplot(merged, aes(date, precipitation_mm)) +
  geom_point()



###gapfilling
miss <- read.csv("data-missing_precip_1978_05_01_to_1988_01_01csv.csv")

head(miss)
dim(miss)

newdata <- merge(miss, df, by = 'date') %>%
  filter(is.na(precipitation.y) == FALSE)
head(newdata)
dim(newdata)
tail(newdata)

