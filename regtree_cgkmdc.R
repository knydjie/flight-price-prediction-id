# REGRESSION TREE CGKMDC

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
data <- read.csv(file = 'D:/UPH/SMT 13/TA2/Data/Data/data_cgkmdc.csv')

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
write.csv(data_train, "D:/UPH/SMT 13/TA2/Data/Data/datatrain_cgkmdc_raw.csv")

#### FiRST MODEL ####
m1 <- rpart(formula = price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday,
            data = data_train,
            method = "anova"
)
summary(m1)
plot1 <- rpart.plot(m1, digits = -3)

# rpart is automatically applying a range of CP to prune the tree.
# This is why not all 10 predictors are used in this model
# Notice the dashed line which goes through |T| = 8 (upper x-axis/size of tree)
# Thus, we could use a tree with 8 terminal nodes 
# and reasonably expect to experience similar results 
# within a small margin of error.
plotcp(m1)
m1$cptable


#### MODEL WITH ALL PREDICTORS ####
# We also can force rpart to generate a full tree using all 10 predictors
m2 <- rpart(formula = price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday,
            data = data_train,
            method = "anova",
            control = list(cp = 0, xval = 10)
)
plotcp(m2)
abline(v = 8, lty = "dashed") 
# We can see that after 8 terminal nodes, 
# we see diminishing returns in error reduction as the tree grows deeper. 
# Thus, we can signifcantly prune our tree and still achieve minimal expected error.
# So, by default, rpart is performing some automated tuning, 
# with an optimal subtree of 7 splits, 8 terminal nodes, and 
# a cross-validated error of .3447373

#### TUNED MODEL ####
# However, we can perform additional tuning to try improve model performance: minsplit/maxdepth
# minsplit default = 20
# maxdepth default = 30

# Grid search
cl<-makePSOCKcluster(5)
registerDoParallel(cl)
start.time<-proc.time()

hyper_grid <- expand.grid(
  minsplit = seq(5, 20, 1),
  maxdepth = seq(5, 15, 1)
)
head(hyper_grid)
nrow(hyper_grid) # total number of combinations

models <- list()

for (i in 1:nrow(hyper_grid)) {
  
  # get minsplit, maxdepth values at row i
  minsplit <- hyper_grid$minsplit[i]
  maxdepth <- hyper_grid$maxdepth[i]
  
  # train a model and store in the list
  models[[i]] <- rpart(
    formula = price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday,
    data = data_train,
    method  = "anova",
    control = list(minsplit = minsplit, maxdepth = maxdepth)
  )
}

# function to get optimal cp
get_cp <- function(x) {
  min    <- which.min(x$cptable[, "xerror"])
  cp <- x$cptable[min, "CP"] 
}

# function to get minimum error
get_min_error <- function(x) {
  min    <- which.min(x$cptable[, "xerror"])
  xerror <- x$cptable[min, "xerror"] 
}

hyper_grid %>%
  mutate(
    cp    = purrr::map_dbl(models, get_cp),
    error = purrr::map_dbl(models, get_min_error)
  ) %>%
  arrange(error) %>%
  top_n(-5, wt = error)

stop.time<-proc.time()
run.time<-stop.time -start.time
print(run.time)
stopCluster(cl)

# Optimal tree
m3 <- rpart(formula = price~airline+departure+arrival+transit+day_of_week+holiday+days_left_until_departure+duration+scrape_day+scrape_holiday,
            data = data_train,
            method = "anova",
            control = list(minsplit = 17, maxdepth = 13, cp = 0.01)
)
saveRDS(m3, file = "D:/UPH/SMT 13/TA2/R Shiny/rt_cgkmdc.rda")
rpart.plot(m3)

#### PRUNING ####
# CP
printcp(m3)
opt_cp <- m3$cptable[which.min(m3$cptable[,"xerror"]),"CP"]
plotcp(m3)

m4 <- prune(m3, cp = opt_cp)
rpart.plot(m4)

#### PREDICTION ####

# Training error
data_train$prediction1 <- predict(m4, newdata = data_train)

# mae
(mae.train <- mae(data_train$price,data_train$prediction1))
# mape
(mape.train <- mape(data_train$price,data_train$prediction1))
# rmse
(rmse.train <- rmse(data_train$price,data_train$prediction1))
# rsq
(rsq.train <- (cor(data_train$price,data_train$prediction1))^2)

# Testing error
data_test$prediction1 <- predict(m4, newdata = data_test)

# MEAN ABSOLUTE ERROR
(mae.test <- mae(data_test$price,data_test$prediction1))

# MEAN PERCENTAGE ABSOLUTE ERROR
(mape.test <- mape(data_test$price,data_test$prediction1))

# ROOT MEAN SQUARE ERROR
(rmse.test <- rmse(data_test$price,data_test$prediction1))

# R-SQ
(rsq.test <- (cor(data_test$price,data_test$prediction1))^2)

