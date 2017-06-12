# Installation:
# 1. Install R from your Linux repository
# 2. Run "R"
# 3. Install required packages by running 'install.packages(c("RCurl","jsonlite","dplyr"))'in R console, exit with q()
# 4. Create example.csv file like the following (remove comments #)

# address,symbol,value
# 0xb293...0347,ETH,45
# 0xe260...cfff,ETH,12.0033
# 0x5fce...eb6b,ETH,12.44
# 0x1e26...da4f,ETH,23.1
# 1J3K....Q6dG,BTC,1.22
# 1GRE....ErRF,BTC,73.30001
# 157S....hqFg,BTC,10.11

# 5. Set a path to your CSV file
inFile<-"~/Work/R/DEV/cryptoSummary/example.csv"

# 6. Start using the script in shell using 'Rscript <path>/cryptoSummary.R'

# The output should be silimiar to the following

# symbol    total total_usd total_nok
# 1    BTC 84.63001 236460.48 2003664.4
# 2    ETH 92.54330  36551.92  309725.3

library(RCurl,quietly=TRUE)
library(jsonlite,quietly=TRUE)
library(dplyr,quietly=TRUE,warn.conflicts=FALSE)

cmcJSON<-getURL("https://api.coinmarketcap.com/v1/ticker/?convert=NOK")
cmcRAW<-fromJSON(cmcJSON)
cmc<-cmcRAW[,c("symbol","price_usd","price_nok","last_updated")]
cmc$price_usd<-as.numeric(cmc$price_usd)
cmc$price_nok<-as.numeric(cmc$price_nok)

input<-read.csv(inFile)
input$value<-as.numeric(input$value)

out<-merge(input,cmc,by="symbol")
sum<-out %>%
    mutate(value_usd=value*price_usd,
           value_nok=value*price_nok) %>%
    group_by(symbol) %>%
    summarize(total=sum(value),total_usd=sum(value_usd),total_nok=sum(value_nok))

as.data.frame(sum)