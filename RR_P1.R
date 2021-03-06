#------------------------------------------------------------------------------#
#                                                                              #
#                               Reproducible Research                          #    
#                                     Project 1                                #
#                                                                              #
#------------------------------------------------------------------------------#

# Author: acallebaut

# Libraries

library(dplyr)
library(lattice)


# Download Data

mydata <- tempfile()
download.file("http://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip", mydata)
unzip(mydata)
unlink(mydata)


# Loading and preprocessing the data

df.activity <- read.table("activity.csv", sep=",", header = TRUE, na.strings = "NA")
df.activity$date <- as.Date(df.activity$date, "%Y-%m-%d")
head(df.activity)


# Total Steps per day

df.total <- df.activity %>%
  group_by(date=date) %>%
  summarise(TotalSteps = sum(steps))
df.total$date <- as.Date(df.total$date)
hist(df.total$TotalSteps, main="Total steps per day", col="pink", xlab="Number of steps")


# Mean & Median Total Number of steps per day

mean_steps <- mean(df.total$TotalSteps, na.rm=T)
print(mean_steps)
median_steps <- median(df.total$TotalSteps, na.rm=T)
print(median_steps)


# Average daily activity pattern

IntervalSteps <- aggregate(steps ~ interval, df.activity, mean)
plot(IntervalSteps$interval, IntervalSteps$steps, 
     main="Average Daily Activity Pattern", type="l", 
     xlab="Interval", 
     ylab="Number of Steps")


IntervalSteps[which.max(IntervalSteps$steps),1]


# Imputing missing values

# In order to impute missing values, I decided to make use of the mean 5-min interval and make a left-join with the original dataset.
# The total number of missing values in the dataset is 2 304.
# The mean and median number of steps per day is equal to 10 766. 
# There is no impact of imputing missing data on the estimates of the total daily number of steps as we have almost the same results. 

sum(is.na(df.activity))
IntervalSteps$steps_mean <- IntervalSteps$steps
IntervalSteps$steps <- NULL
df.activity <- left_join(df.activity, IntervalSteps, by="interval")
df.activity$Steps_complete <- df.activity$steps
steps_mean_vector <- as.numeric(df.activity$steps_mean[is.na(df.activity$steps)])
df.activity$steps[is.na(df.activity$Steps_complete)] <- steps_mean_vector
df.activity$Steps_complete <- NULL
df.activity$steps_mean <- NULL

Steps_day_sum <- aggregate(steps ~ date, df.activity, sum)
hist(Steps_day_sum$steps, main="Total of steps per day", col="green", xlab="Number of steps")
Steps_day_mean <- mean(Steps_day_sum$steps)
Steps_day_median <- median(Steps_day_sum$steps)


# Are there differences in activity patterns between weekdays and weekends?

# We can see that the activity is higher during weekends. 

df.activity$WE_WD <- weekdays(as.Date(df.activity$date))
weekends <- c("zaterdag", "zondag")
df.activity$weektype[df.activity$WE_WD %in% weekends] <- "weekend"
df.activity$weektype[!(df.activity$WE_WD %in% weekends)] <- "weekday"
df.activity$WE_WD <- NULL

steps_Weektype <- aggregate(steps ~ interval + weektype, df.activity, mean)
library(lattice)
xyplot(steps_Weektype$steps ~ steps_Weektype$interval|steps_Weektype$weektype, 
       main="Activity pattern during weekends and weekdays",
       xlab="5-min Interval", ylab="Steps",
       layout=c(1,2), type="l")

