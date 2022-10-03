install.packages("randomForest")
library(randomForest)

data <- read.delim("Desktop/Machine learning/BV Status/BVStatus_Genera.txt", header = TRUE, row.names = 1)
  
str(data)
set.seed(100)
train <- sample(nrow(data), 0.7*nrow(data), replace = FALSE)
TrainSet <- data[train,]
ValidSet <- data[-train,]
summary(TrainSet)
summary(ValidSet)

model1 <- randomForest(BV_Status ~ ., data = TrainSet, importance = TRUE)
model1


# Fine tuning parameters of Random Forest model
model2 <- randomForest(BV_Status ~ ., data = TrainSet, ntree = 500, mtry = 5, importance = TRUE)
model2

predTrain <- predict(model2, TrainSet, type = "class")
# Checking classification accuracy
table(predTrain, TrainSet$BV_Status)  


# Predicting on Validation set
predValid <- predict(model2, ValidSet, type = "class")
# Checking classification accuracy
mean(predValid == ValidSet$BV_Status)                    
table(predValid,ValidSet$BV_Status)

importance(model2)        
varImpPlot(model2)        

# Using For loop to identify the right mtry for model
a=c()
i=20
for (i in 3:23) {
  model3 <- randomForest(BV_Status ~ ., data = TrainSet, ntree = 500, mtry = i, importance = TRUE)
  predValid <- predict(model3, ValidSet, type = "class")
  a[i-2] = mean(predValid == ValidSet$BV_Status)
}
a
plot(3:23,a)



# Compare with Decision Tree
install.packages("rpart")
install.packages("caret")
install.packages("e1071")
library(rpart)
library(caret)
library(e1071)
# We will compare model 1 of Random Forest with Decision Tree model
model_dt = train(Inflammation_category ~ ., data = TrainSet, method = "rpart")
model_dt_1 = predict(model_dt, data = TrainSet)
table(model_dt_1, TrainSet$Inflammation_category)
mean(model_dt_1 == TrainSet$Inflammation_category)

# Running on Validation Set
model_dt_vs = predict(model_dt, newdata = ValidSet)
table(model_dt_vs, ValidSet$Inflammation_category)
mean(model_dt_vs == ValidSet$Inflammation_category)

