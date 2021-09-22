#install.packages("psych")
library(psych)  #for general functions
#install.packages("ggplot2")
library(ggplot2)  #for data visualization


library(caret)  #for training and cross validation (also calls other model libaries)
library(rpart)  #for trees

library(rpart.plot)   #Enhanced tree plots
library(RColorBrewer) #Color selection for fancy tree plot
#install.packages("party")
library(party)    #Alternative decision tree algorithm
#install.packages("partykit")
library(partykit)   #Convert rpart object to BinaryTree
library(pROC)   #for ROC curves

#Load data
data <- read.delim("v2_BV_proteins.txt", header = TRUE, row.names = 1, sep = "\t")
#View data
head(data,10)

#Select 80% of data for training dataset
TrainingIndex <- createDataPartition(data$BV_Status, p=0.8, list = FALSE)
TrainingSet <- data[TrainingIndex,]
#Test dataset includes 20% of data not included in the training dataset
TestingSet <- data[-TrainingIndex,]


#Setting the random seed for replication
set.seed(1234)

#Setting up cross-validation
cvcontrol <- trainControl(method="repeatedcv", number = 10,
                          allowParallel=TRUE)

#Train model using training dataset
train.bagg <- train(as.factor(BV_Status) ~ ., 
                    data=TrainingSet,
                    method="treebag",
                    trControl=cvcontrol,
                    importance=TRUE)

train.bagg

#Plot variables
plot(varImp(train.bagg), cex.lab = 0.4)

bagg.classTrain <-  predict(train.bagg, 
                            type="raw")
head(bagg.classTrain)

confusionMatrix(TrainingSet$BV_Status,bagg.classTrain)

bagg.classTest <-  predict(train.bagg, 
                           newdata = TestingSet,
                           type="raw")
head(bagg.classTest)

confusionMatrix(TestingSet$BV_Status,bagg.classTest)


bagg.probs=predict(train.bagg,
                   newdata=TestingSet,
                   type="prob")
head(bagg.probs)

#Calculate ROC curve
rocCurve.bagg <- multiclass.roc(TestingSet$BV_Status,bagg.probs[,"Positive"])
#Plot the ROC curve
plot(rocCurve.bagg,col=c(2))

auc(rocCurve.bagg)

library(rpart)
library(rpart.plot)

#Create decision tree
tree<- rpart(BV_Status~., data = TrainingSet, method = 'class')
rpart.plot(tree)

tree$variable.importance

