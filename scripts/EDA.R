#Exploratory Data Analysis Steps
#1.import the data
df.raw <- read.csv(file ='Pisa scores 2013 - 2015 Data.csv', fileEncoding="UTF-8-BOM", na.strings = '..')
str(df.raw)

#clean
install.packages("tidyverse")
library(tidyverse)
#make sure each row corresponds to ONLY one country. use spread()
#make sure only useful rows and columns are kept, use drop_na() and data subsetting
#rename column for meaningfulinterpretation

df <- df.raw[1:1161, c(1, 4, 7)] #select relevant rows and cols
%>%  spread(key=Series.Code, value=X2015..YR2015.) 
%>%  rename(Maths = LO.PISA.MAT,                        
            Maths.F = LO.PISA.MAT.FE,
            Maths.M = LO.PISA.MAT.MA,
            Reading = LO.PISA.REA,
            Reading.F = LO.PISA.REA.FE,
            Reading.M = LO.PISA.REA.MA,
            Science = LO.PISA.SCI,
            Science.F = LO.PISA.SCI.FE,
            Science.M = LO.PISA.SCI.MA
) %>%
  drop_na()

#now view the clean data with
view(df)
#process
#visualise the data

#1.Barplot
install.packages("ggplot2")
library(ggplot2)

#Ranking of Maths Score by Countries
ggplot(data=df,aes(x=reorder(Country.Name,Maths),y=Maths)) + 
  geom_bar(stat ='identity',aes(fill=Maths))+
  coord_flip() + 
  theme_grey() + 
  scale_fill_gradient(name="Maths Score Level")+
  labs(title = 'Ranking of Countries by Maths Score',
       y='Score',x='Countries')+ 
  geom_hline(yintercept = mean(df$Maths),size = 1, color = 'blue')


#Packages
#Tidyverse(tidy up dataset)
#ggplot2(visualize)
#functions(strsplit(), cbind(),matrix())

#na.strings = '..'allows R to replace those blanks in the dataset with NA. 
#This will be useful and convenient later when we want to remove all the ‘NA’s.

#fileEncoding="UTF-8-BOM"
#This allows R, in the laymen term, to read the characters as correctly as they would appear on the raw dataset.
