dat <- read.csv("https://raw.githubusercontent.com/cheryltky/bikeshare_studies/main/csvdata/Q1.csv", sep=",", header = T, stringsAsFactors=F)

library(ggplot2)
library(tidyr)

dat$index <- seq_len(dim(dat)[1])

lnb <- loess(trips_bluebike ~ index, data=dat)
lnd <- loess(trips_divvy ~ index, data=dat, method="loess")

pdf("trips_bludiv.pdf")
plot(dat$index, dat$trips_bluebike, pch=20, col="blue", bty='n', xaxt='n', xlab='', ylab="Number of Trips", ylim=c(min(c(dat$trips_bluebike, dat$trips_divvy)), max(c(dat$trips_bluebike, dat$trips_divvy))))
points(dat$trips_divvy, pch=20, col='red')
axis(1, at=dat$index, labels=dat$month_year, las=2)
lines(dat$index, dat$trips_bluebike, col="blue", lwd=1)
lines(dat$index, dat$trips_divvy, col="red", lwd=1)
dev.off()


datl <- gather(dat, company, number_of_trips, trips_bluebike:trips_divvy)


ggplot(datl, aes(x=index, y=number_of_trips, color=as.factor(company))) + geom_point() + scale_x_continuous(breaks=dat$index, labels=dat$month_year) + theme(axis.text.x = element_text(angle=90)) + xlab("Date") + ylab("Number of Trips") + geom_line(data = datl, aes(x=index, y=number_of_trips))

geom_smooth(method="loess")





