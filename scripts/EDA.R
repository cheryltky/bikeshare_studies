#Exploratory Data Analysis Steps
#import the data
df.raw2 <- read.csv(file ='Pisa scores 2013 - 2015 Data.csv',na.strings = '..')
str(df.raw2)

#clean
#process
#visualise

#Packages
#Tidyverse(tidy up dataset)
#ggplot2(visualize)
#functions(strsplit(), cbind(),matrix())

#na.strings = '..'allows R to replace those blanks in the dataset with NA. 
#This will be useful and convenient later when we want to remove all the ‘NA’s.