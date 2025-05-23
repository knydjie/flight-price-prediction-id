# BAGGING REGRESSION TREE CGKSUB

library(rsample)     # data splitting 
library(dplyr)       # data wrangling
library(rpart)       # performing regression trees
library(rpart.plot)  # plotting regression trees
library(ipred)       # bagging
library(caret)       # bagging
library(parallelMap)
library(parallel)
library(doParallel)
library(Metrics)

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

#### BEST BOOTSTRAP SAMPLES ####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

# Assess 10-50 bagged trees
ntree <- 10:50

# Create empty vector to store OOB RMSE values
rmse <- vector(mode = "numeric", length = length(ntree))

for (i in seq_along(ntree)) {
  # reproducibility
  set.seed(123)
  
  # perform bagged model
  model <- bagging(
    formula = price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday,
    data = data_train,
    coob    = TRUE,
    nbagg   = ntree[i]
  )
  # get OOB error
  rmse[i] <- model$err
}

plot(ntree, rmse, type = 'l', lwd = 2)
abline(v = 23, col = "red", lty = "dashed")

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)
  
#### BAGGING REGRESSION TREE ####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

ctrl <- trainControl(method = "cv",  number = 10)

bagged_m1 <- train(
  form = price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday,
  data = data_train,
  method = "treebag",
  trControl = ctrl,
  importance = TRUE
)
bagged_m1
saveRDS(bagged_m1, file = "D:/UPH/SMT 13/TA2/R Shiny/brt_cgksub.rda")

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

# Variable importance
plot(varImp(bagged_m1), 20)

#### PREDICTION ####

# Training error
data_train$prediction3 <- predict(bagged_m1, newdata = data_train)

# mae
(mae.train <- mae(data_train$price,data_train$prediction3))
# mape
(mape.train <- mape(data_train$price,data_train$prediction3))
# rmse
(rmse.train <- rmse(data_train$price,data_train$prediction3))
# rsq
(rsq.train <- (cor(data_train$price,data_train$prediction3))^2)

# Testing error
data_test$prediction3 <- predict(bagged_m1, newdata = data_test)

# mae
(mae.test <- mae(data_test$price,data_test$prediction3))
# mape
(mape.test <- mape(data_test$price,data_test$prediction3))
# rmse
(rmse.test <- rmse(data_test$price,data_test$prediction3))
# rsq
(rsq.test <- (cor(data_test$price,data_test$prediction3))^2)

#### BAGGING REGRESSION TREE NBAGG = 22 ####
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

ctrl <- trainControl(method = "cv",  number = 10)

bagged_m1 <- train(
  form = price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday,
  data = data_train,
  method = "treebag",
  trControl = ctrl,
  importance = TRUE,
  nbagg = 24
)
bagged_m1
saveRDS(bagged_m1, file = "D:/UPH/SMT 13/TA2/R Shiny/brt_cgksub24.rda")
bagged_m1 = readRDS("D:/UPH/SMT 13/TA2/R Shiny/brt_cgksub23.rda")

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

########
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

control <- trainControl(method = 'cv',
                        number = 5,
                        search = 'grid')

# Train with different ntree parameters
modellist <- list()

for (nbagg in c(5, 10, 25, 50)){
  set.seed(1)
  fit <- train(price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday, 
               data=data_train,
               method = 'treebag',
               metric = 'RMSE',
               trControl = control,
               nbagg = nbagg)
  key <- toString(nbagg)
  modellist[[key]] <- fit
}

# Compare results
results <- resamples(modellist)
summary(results)

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)