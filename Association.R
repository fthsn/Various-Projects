rm(list=ls())

# install.packages("arulesViz")
library(arules);library(arulesViz);library(tidyverse);library(data.table)
library(readxl);library(knitr);library(ggplot2);library(lubridate);library(plyr);library(dplyr)



setwd("/Users/ftmfth/Downloads")

#read excel into R dataframe
# saveRDS(retail,"retail.rds")
retail = readRDS("retail.rds")
#complete.cases(data) will return a logical vector indicating which rows have no missing values. Then use the vector to get only rows that are complete using retail[,].
retail <- retail[complete.cases(retail), ]
#mutate function is from dplyr package. It is used to edit or add new columns to dataframe. Here Description column is being converted to factor column. as.factor converts column to factor column. %>% is an operator with which you may pipe values to another function or expression
retail %>% mutate(Description = as.factor(Description))
#Converts character data to date. Store InvoiceDate as date in new variable
retail$Date <- as.Date(retail$InvoiceDate,origin="1980-01-01")
#Extract time from InvoiceDate and store in another variable
#Convert and edit InvoiceNo into numeric
InvoiceNo <- as.numeric(as.character(retail$InvoiceNo))
 

 
#######################
gary = data.table(read_csv("Data_association_analysis_project.csv"))
gary = unique(gary)
gary$Orders_ID <-  (as.character(gary$Orders_ID))
gary$ItemID <-  (as.character(gary$ItemID))

transactionData <- ddply(gary,c("Orders_ID"),
                         function(df1)paste(df1$ItemName,
                                            collapse = ","))

#######################
transactionData$InvoiceNo <- NULL
colnames(transactionData) <- c("items","V1")
 
transactionData = data.table(transactionData)

nrow(transactionData[V1 %like% "Savoury Muffin" & V1 %like% "Flat White"])


write.csv(transactionData,"market_basket_transactions.csv", quote = FALSE, row.names = FALSE)
tr <- read.transactions('market_basket_transactions.csv', format = 'basket', sep=',')
summary(tr)
library(RColorBrewer) 
itemFrequencyPlot(tr,topN=20,type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot")
association.rules <- apriori(tr, parameter = list(supp=0.002, conf=0.5))
summary(association.rules)
dd = inspect(association.rules) 

openxlsx::write.xlsx(dd,"dd2.xlsx")
subRules<-associati3on.rules[quality(association.rules)$confidence>0.4]
top10subRules <- head(subRules, n = 10, by = "confidence")
plot(top10subRules, method = "graph",  engine = "htmlwidget")

summary(transactionData2)
transactionData22 = data.table(transactionData2)
transactionData22[items %like% 'Oats - Full' & items %like% 'Special - Make from Sides' ]

