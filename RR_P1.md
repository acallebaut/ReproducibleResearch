Reproducible Research Project 1
================
acallebaut
9 april 2017

### Libraries

``` r
library(dplyr)
library(lattice)
```

### 1. Loading and preprocessing the data

``` r
mydata <- tempfile()
download.file("http://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip", mydata)
unzip(mydata)
unlink(mydata)

df.activity <- read.table("activity.csv", sep=",", header = TRUE, na.strings = "NA")
df.activity$date <- as.Date(df.activity$date, "%Y-%m-%d")
head(df.activity)
```

    ##   steps       date interval
    ## 1    NA 2012-10-01        0
    ## 2    NA 2012-10-01        5
    ## 3    NA 2012-10-01       10
    ## 4    NA 2012-10-01       15
    ## 5    NA 2012-10-01       20
    ## 6    NA 2012-10-01       25

### 2. What is mean total number of steps taken per day?

``` r
df.total <- df.activity %>%
  group_by(date=date) %>%
  summarise(TotalSteps = sum(steps))

df.total$date <- as.Date(df.total$date)
hist(df.total$TotalSteps, main="Total steps per day", col="pink", xlab="Number of steps")
```

![](Figs/Total%20Steps%20per%20day-1.png)

``` r
mean_steps <- mean(df.total$TotalSteps, na.rm=T)

median_steps <- median(df.total$TotalSteps, na.rm=T)
```

The `mean` is 10 766.19 and the `median` is 10 765.

### 3. What is the average daily activity pattern?

``` r
IntervalSteps <- aggregate(steps ~ interval, df.activity, mean)
plot(IntervalSteps$interval, IntervalSteps$steps, 
     main="Average Daily Activity Pattern", type="l", 
     xlab="Interval", 
     ylab="Number of Steps")
```

![](Figs/Average%20daily%20activity%20pattern-1.png)

``` r
maxSteps <- IntervalSteps[which.max(IntervalSteps$steps),1]
```

The maximum number of steps for 5-min interval is 835.

### 4. Imputing missing values

In order to impute missing values, I decided to make use of the mean 5-min interval and make a left-join with the original dataset. The total number of missing values in the dataset is 2 304. The mean and median number of steps per day is equal to 10 766. There is no impact of imputing missing data on the estimates of the total daily number of steps as we have almost the same results.

``` r
NA_Rows <- sum(is.na(df.activity))
IntervalSteps$steps_mean <- IntervalSteps$steps
IntervalSteps$steps <- NULL
df.activity <- left_join(df.activity, IntervalSteps, by="interval")
df.activity$Steps_complete <- df.activity$steps
steps_mean_vector <- as.numeric(df.activity$steps_mean[is.na(df.activity$steps)])
df.activity$steps[is.na(df.activity$Steps_complete)] <- steps_mean_vector
df.activity$Steps_complete <- NULL
df.activity$steps_mean <- NULL
Steps_day_sum <- aggregate(steps ~ date, df.activity, sum)
hist(Steps_day_sum$steps, main="Total steps per day", col="green", xlab="Number of steps")
```

![](Figs/Imputing%20missing%20values-1.png)

``` r
Steps_day_mean <- mean(Steps_day_sum$steps)
Steps_day_median <- median(Steps_day_sum$steps)
```

### 5. Are there differences in activity patterns between weekdays and weekends?

We can see that the activity is higher during weekends.

``` r
df.activity$WE_WD <- weekdays(as.Date(df.activity$date))
weekends <- c("zaterdag", "zondag")
df.activity$weektype[df.activity$WE_WD %in% weekends] <- "weekend"
df.activity$weektype[!(df.activity$WE_WD %in% weekends)] <- "weekday"
df.activity$WE_WD <- NULL
steps_Weektype <- aggregate(steps ~ interval + weektype, df.activity, mean)
xyplot(steps_Weektype$steps ~ steps_Weektype$interval|steps_Weektype$weektype, 
       main="Activity pattern during weekends and weekdays",
       xlab="5-min Interval", ylab="Steps",
       layout=c(1,2), type="l")
```

![](Figs/Activity%20pattern%20weekdays%20and%20weekends-1.png)
