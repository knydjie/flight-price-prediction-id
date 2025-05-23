# RANDOM FOREST CGKSUB

library(rsample)     # data splitting 
library(dplyr)       # data wrangling
library(rpart)       # performing regression trees
library(rpart.plot)  # plotting regression trees
library(ipred)       # bagging
library(caret)       # bagging
library(parallelMap)
library(parallel)
library(doParallel)
library(ggplot2)
library(scales)
library(rattle)
library(Metrics)
library(randomForest)

# READ DATA
data <- read.csv(file = 'D:/UPH/SMT 13/TA2/Data/Data/data_cgksub.csv')

# CLASS
str(data)

cols <- c("airline", "day_of_week", "scrape_day")
data[cols] <- lapply(data[cols], factor)

sapply(data, class)

# SPLITTING
set.seed(1)
data_split <- initial_split(data, prop = .8)
data_train <- training(data_split)
data_test  <- testing(data_split)

#### DEFAULT MODEL ####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

control <- trainControl(method='cv', 
                        number=5)

# Metric compare model is RMSE
metric <- 'RMSE'

# Number randomely variable selected is mtry
mtry <- floor(sqrt(29))
tunegrid <- expand.grid(.mtry=mtry)

rf_default <- train(price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday, 
                    data=data_train, 
                    method='rf', 
                    metric=metric, 
                    tuneGrid=tunegrid,
                    trControl=control,
                    ntree=500,
                    maxnodes = 10)
print(rf_default)

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

#### RANDOM SEARCH MTRY ####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

control2 <- trainControl(method="cv", number=5, search="random")
rf_random <- train(price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday, 
                   data=data_train, 
                   method = 'rf',
                   metric = metric,
                   tuneLength  = 10, 
                   trControl = control2,
                   ntree=500,
                   maxnodes = 10)
print(rf_random)
plot(rf_random)

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

#### TUNE MANUALLY NTREE ####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

control3 <- trainControl(method = 'cv',
                        number = 5,
                        search = 'grid')
# Create tune grid
tunegrid <- expand.grid(.mtry = 18)

# Train with different ntree parameters
modellist <- list()
for (ntree in c(200,500,1000)){
  set.seed(1)
  fit <- train(price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday, 
               data=data_train,
               method = 'rf',
               metric = metric,
               tuneGrid = tunegrid,
               trControl = control3,
               ntree = ntree,
               maxnodes = 10)
  key <- toString(ntree)
  modellist[[key]] <- fit
}

# Compare results
results <- resamples(modellist)
summary(results)

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

#### TUNE MANUALLY MAXNODES ####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

# Create tune grid
tunegrid <- expand.grid(.mtry = 18)

#train with different maxnodes parameters
modellist <- list()
for (maxnodes in c(5,10,20,30,40,50)){
  set.seed(1)
  fit <- train(price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday, 
               data=data_train,
               method = 'rf',
               metric = metric,
               tuneGrid = tunegrid,
               trControl = control,
               ntree = 1000,
               maxnodes = maxnodes)
  key <- toString(maxnodes)
  modellist[[key]] <- fit
}

# Compare results
results <- resamples(modellist)
summary(results)

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

#### FINAL MODEL ####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

control <- trainControl(method='cv', 
                        number=5)

# mtry = 18, ntree = 1000, maxnodes = 50. run time: 1332 secs (22.2 menit)
tunegrid <- expand.grid(.mtry=18)

rf_opt <- train(price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday, 
                    data=data_train, 
                    method='rf', 
                    metric=metric, 
                    tuneGrid=tunegrid,
                    trControl=control,
                    ntree=1000,
                    maxnodes = 50)
print(rf_opt)
saveRDS(rf_opt, file = "D:/UPH/SMT 13/TA2/R Shiny/rf_cgksub.rda")

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

#### PREDICTION ####
# Training error
data_train$prediction4 <- predict(rf_opt, newdata = data_train)

# mae
(mae.train <- mae(data_train$price,data_train$prediction4))
# mape
(mape.train <- mape(data_train$price,data_train$prediction4))
# rmse
(rmse.train <- rmse(data_train$price,data_train$prediction4))
# rsq
(rsq.train <- (cor(data_train$price,data_train$prediction4))^2)

# Testing Error
data_test$prediction4 <- predict(rf_opt, newdata = data_test)

# mae
(mae.train <- mae(data_test$price,data_test$prediction4))
# mape
(mape.train <- mape(data_test$price,data_test$prediction4))
# rmse
(rmse.train <- rmse(data_test$price,data_test$prediction4))
# rsq
(rsq.train <- (cor(data_test$price,data_test$prediction4))^2)

