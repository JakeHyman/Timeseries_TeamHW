install.packages("ggeconodist", repos = "https://cinc.rud.is")
library(hrbrthemes)
library(ggeconodist)
library(ggplot2)
library(dplyr)

#Adding this section changes the error code from polygon edges not found to font could not be found for family
install.packages("extrafont")
library(extrafont)
extrafont::font_import() #type y

gg <- ggplot(mammogram_costs, aes(x = city)) +
  geom_econodist(aes(ymin = tenth, median = median, ymax = ninetieth), stat = "identity") +
  scale_y_continuous(expand = c(0,0), position = "right", limits = range(0, 800)) + coord_flip() +
  labs(x =NULL,y=NULL,title = "Mammoscams",
    
    subtitle = "United States, prices for a mammogram*\nBy metro area, 2016, $",
    
    
    caption = "*For three large insurance companies\nSource: Health Care Cost Institute") + theme_econodist() 

gg

grid.newpage()
left_align(gg, c("subtitle", "title", "caption")) %>% 
  add_econodist_legend(econodist_legend_grob(), below = "subtitle")  %>%
  grid.draw()

#Go to this link https://github.com/hrbrmstr/hrbrthemes 
#and download zip and then go to the folder /inst/fonts/font_you_want import it into the font book

# Elaborate fontbook on your mac or windows 

############################################################
#Using MSA data for boxplot
############################################################

#set working directory to downloads
setwd("~/Downloads")

msa_students <- readxl::read_xlsx("MSA Students by Age and Gender.xlsx")

#Calculating 10th percentile, median, and 90th percentile for each year
msa_students1 <- msa_students %>%
  group_by(`Class Year`) %>%
  mutate(Median_Age_Per_Year=median(`Age at Entry`)) %>%
  mutate(Percentile10=quantile(`Age at Entry`,probs = c(0.10))) %>%
  mutate(Percentile90=quantile(`Age at Entry`, probs=c(0.90))) %>%
  ungroup()

msa_students2 <- msa_students1 %>%
  select(`Class Year`, Median_Age_Per_Year, Percentile10, Percentile90)

msa_students3 <- unique(msa_students2)

#Calculating 10th percentile, median, and 90th percentile for each year by gender
msa_students2.1 <- msa_students %>%
  group_by(`Class Year`, Gender) %>%
  mutate(Median_Age=median(`Age at Entry`)) %>%
  mutate(Percentile10=quantile(`Age at Entry`,probs = c(0.10))) %>%
  mutate(Percentile90=quantile(`Age at Entry`, probs=c(0.90))) %>%
  ungroup()

msa_students2.2 <- msa_students2.1 %>%
  select(`Class Year`, Gender, Median_Age, Percentile10, Percentile90)

msa_students2.3 <- unique(msa_students2.2)

#Graphing 10th percentile, median, and 90th percentile for each year
gg <- ggplot(msa_students3, aes(x =`Class Year`, group=`Class Year`)) + 
  geom_econodist(aes(ymin = Percentile10, median = Median_Age_Per_Year, ymax = Percentile90), stat = "identity") +
  scale_y_continuous( expand = c(0,0),position = "right", limits = range(0, 50)) +
  scale_x_continuous(trans="reverse", breaks=unique(msa_students3$`Class Year`)) +
  coord_flip() +
  labs(x ="Year",y="Age", title = "Distribution of the MSA Class by Age", subtitle = "2008 - 2021") + #had an extra comma after subtitle, so gave error about argument 3
  theme_econodist() 

gg

grid.newpage()
left_align(gg, c("subtitle", "title", "caption")) %>% 
  add_econodist_legend(econodist_legend_grob(), below = "subtitle")  %>%
  grid.draw()

names(msa_students)
old_boxplot <- ggplot(msa_students, aes(y=`Age at Entry`, x=`Class Year`, group=`Class Year`)) + 
  geom_boxplot(aes(lower=quantile(`Age at Entry`,probs=c(0.10)),
                   middle=median(`Age at Entry`), 
                   upper=quantile(`Age at Entry`,probs=c(0.90)), ymin=20,ymax=60)) + 
    coord_flip() + scale_x_discrete(limits=c(2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021)) +
  labs(x ="Year",y="Age", title = "Distribution of the MSA Class by Age", subtitle = "2008 - 2021") 
old_boxplot

#Graphing 10th percentile, median, and 90th percentile for each year by gender
gg <- ggplot(msa_students2.3, aes(x = `Class Year`, group=`Class Year`)) + facet_wrap(~Gender)+
  geom_econodist(aes(ymin = Percentile10, median =Median_Age, ymax = Percentile90), stat = "identity") +
  scale_y_continuous( expand = c(0,0),position = "right", limits = range(0, 50)) +
  scale_x_discrete(limits=c(2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021)) +
  coord_flip() +
  labs(x ="Year",y="Age", title = "The Distribution of the MSA Class by Age and Sex", subtitle = "2008 - 2021") + #had an extra comma after subtitle, so gave error about argument 3
  theme_econodist() 

gg

grid.newpage()
left_align(gg, c("subtitle", "title", "caption")) %>% 
  add_econodist_legend(econodist_legend_grob(), below = "subtitle")  %>%
  grid.draw()

