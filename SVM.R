####################################
# http://github.com/dataprofessor  #
####################################

# Importing libraries
install.packages("caret")
library(caret) # Package for machine learning algorithms / CARET stands for Classification And REgression Training

# Importing the data set
data <- read.delim("Desktop/Machine learning/Inflammation Category/InflammationProteins.txt", header = TRUE, row.names = 1)

install.packages("skimr")
library(skimr)
skim(data)

# Check to see if there are missing data with your own dataset? Summation function, to see if there a missing vals
sum(is.na(data))

# To achieve reproducible model; set the random seed number
# When you're building a classification model, you want to set the seed number to a fixed number
# When you rereun the same model - you will get the same number
set.seed(100)

# Performs stratified random split of the data set
# Simulate the siutation in which we have a dataset which we use to train the model see whether model will be applicable to future data
# Split one part into training set (create a training model); apply the training model to predict the class label in the 20% of the testing set
# Training set - represents 80% of dataset
# Testing set - represents 20% of dataset
TrainingIndex <- createDataPartition(data$Inflammation_category, p=0.8, list = FALSE)
# Index of dataset (like ID) each flower will be assigned a unique ID, 150 flowers - 120 rows (80% of data), randomly selected out of 150 flowers
TrainingSet <- data[TrainingIndex,] # Training Set
TestingSet <- data[-TrainingIndex,] # Test Set; give the remaining 20%

# Compare scatter plot of the 80 and 20 data subsets


###############################
# SVM model (polynomial kernel)
# Hyperparameters need to optimize

# Build Training model
Model <- train(Inflammation_category ~ ., data = TrainingSet,
               method = "svmPoly",
               na.action = na.omit,
               preProcess=c("scale","center"),
               trControl= trainControl(method="none"),
               tuneGrid = data.frame(degree=1,scale=1,C=1)
)

# scale data according the mean centre, for each variable will compute the mean value and subtract each val of each row from the mean val of each col
# for each variabe will have a mean of 0 
# training model: use training set to build the model, apply the training model to predict the class label of testing set 

# Build CV model
Model.cv <- train(Inflammation_category ~ ., data = TrainingSet,
                  method = "svmPoly",
                  na.action = na.omit,
                  preProcess=c("scale","center"),
                  trControl= trainControl(method="cv", number=10),
                  tuneGrid = data.frame(degree=1,scale=1,C=1)
)


# Apply model for prediction
Model.training <-predict(Model, TrainingSet) # Apply model to make prediction on Training set; predict class label of 120 flower training set
Model.testing <-predict(Model, TestingSet) # Apply model to make prediction on Testing set; apply training model to predict the class label of 30 flowers
Model.cv <-predict(Model.cv, TrainingSet) # Perform cross-validation; use training set partition in 10 parts, perform 10 iterations, for each iteration will use 9 parts to create training model, average out performance

# Model performance (Displays confusion matrix and statistics)
# Look at prediction performance
Model.training.confusion <-confusionMatrix(Model.training, TrainingSet$Inflammation_category)
Model.testing.confusion <-confusionMatrix(Model.testing, TestingSet$Inflammation_category)
Model.cv.confusion <-confusionMatrix(Model.cv, TrainingSet$Inflammation_category)

print(Model.training.confusion)
# Each column will represent actual class label, each row will represent predicted class label
# Accuracy is not the best way to measure performance of model, especially if dataset is imbalanced
# Don't want bias of unequal distribution of class label to have an effect 
print(Model.testing.confusion)
# Out of 10 versicolor, 8 have been predicted to versicolor, whereas 2 has been predicted to be virginica
print(Model.cv.confusion)

# Feature importance
Importance <- varImp(Model)
plot(Importance2)
?plot
Importance2 <- Importance{Importance$importance[1:100,]}

plot(Importance, cex = .00001)

write.table(Importance2, file = "Predictors_inflammation_proteins.txt", sep = "\t",
            row.names = TRUE, col.names = NA)
