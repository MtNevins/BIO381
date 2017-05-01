### randomForest tutorial ###
### Computational Biology: Univeristy of Vermont 
### April 26, 2017
### Matthias Nevins 

### Notes on randomForest ###

# "randomForest" is an ensemble learning model
# (also refered to as a "machine learning" tool). 
# 
# The package uses a random forest algorithm to sample data randomly 
# and then construct and analyzes multiple random decision trees (ensemble). 
# The performance of each random decision tree is are compared used to
# determine the mode of a classification or the mean of a regression. 
# The model can be trained on a subset of the data and then tested for accuracy. 

## See notes on decision trees and random forest ## 


#-----------------------------------------------------
############ randomForest #######################

# Begin by installing the randomForest package
install.packages("randomForest")
library("randomForest")

## INPUTS ## 
help("randomForest")
# relevent input arguments 
        # x = data frame or matrix of predictor variable(s)
        # y = response vector (if factor, classification)
        # ntree = number of decision trees to grow 
        # mtry = Number of randomly sampled 
            ## mtry should be a value lower than the total number of variables 
            ## for classification trees use the square root of number of variables
        # sampsize = number of rows that are randomly sampled for each tree 
        # sampsize should be lower than the total number of rows in your data set
        # nodesize = minimum size of terminal nodes (larger the number smaller the tree)

### OUTPUTS ##
# predication by randomForest is the mean of the random decision trees
# confusion matrix (classification) 

#### EXAMPLE 1: Iris data ####
# Call to "iris" data set available in R 
data(iris) 
View(iris) 
str(iris) # numeric predictor variables, Species variable is catagorical
summary(iris)

# Store iris in a new data fram 

Dframe <- iris

# Let's get started 
set.seed(123) # to get reproducible random results

# Split iris data to training data and testing data
# Train the model with 70% of data and test it 
# with the remaing %30 of the data. 
help(sample)
spl <- sample(2,nrow(Dframe),replace=TRUE,prob=c(0.7,0.3)) 
print(spl)
str(spl)

# define the training data 
trainData <- Dframe[spl==1,]
head(trainData)

# Test data 
testData <- Dframe[spl==2,]
head(testData)

# Generate random forest with training data 
irisRF <- randomForest(Species~.,data=trainData, mtry= 3, ntree=200,proximity=TRUE) 
help(randomForest)

# Print Random Forest model and see the importance features
print(irisRF)

# Confusion matrix for train data
table(predict(irisRF),trainData$Species) 

# Plot random forest 
plot(irisRF)

# Look at importance of independant vars
importance(irisRF)
# Plot importance 
varImpPlot(irisRF)

# Now build random forest for testing data
help("predict.randomForest")

irisPred <- predict(irisRF,newdata=testData)
print(irisPred)
table(irisPred, testData$Species)

#Now, let's look at the margin, positive or negative,
# if positive it means correct classification
help("margin.randomForest")
plot(margin(irisRF,testData$Species))



##################### END OF EXAMPLE 1 ##############################

#------------------------------------------------------
####### EXAMPLE 2: Using MASS package ##################

# Begin by importing two libraries 
library(randomForest)
library(MASS)

# set seed 
help("set.seed")
set.seed(1234)

# Store data "birthwt" data set from the MASS package into a DataFrame 
help("birthwt")
dFrame <- birthwt

# Identify predictor variables and target variable
# Identify catagorical target variable 
head(dFrame)
str(dFrame)
View(dFrame)

# see how many unique values are within each variable 
# for "low"
length(unique(dFrame$low))
hist(dFrame$low) # two unique values 
length(unique(dFrame$bwt))
hist(dFrame$bwt) # continuous variable 

# another way to view unique values for all variables
apply(dFrame,2,function(x) length(unique(x))) 
help(apply) # 2 in this function indicates columns

# Now convert catagorical variables using as.factor so 
# they are treated as numerical data by randomForest

# Begin by placing the variables you need to convert into a new placehoder 
# variable cVars (catagorical variables)
cVars <- c("low", "race", "smoke", "ptl", "ht", "ui", "ftv")

# use a for loop to go over data frame (dFrame) 
for(i in cVars){
  dFrame[,i]=as.factor(dFrame[,i])
}
str(dFrame) # we see that the numerical values for the 
#catagorical variables have been converted

# Acquire new library "caTools" to assist in the splitting of 
# sampled data
help("caTools")
library(caTools)

ivar <- sample.split(Y = dFrame$low, SplitRatio = 0.7) 
ivar
# Now assign the split data to a "train" and a "test" data frame
trainD <- dFrame[ivar,]
testD <- dFrame[!ivar,]


#### FIT THE MODEL ####
# use randomForest model to try and predict the importance of 
# each variable as it relates to the traget variable ("low")

ranForMod <- randomForest(low~., data = trainD, mtry=2, ntree=200)
print(ranForMod)

# Error rate 
# OOB (out of bag rate) mis-classification rate 
# Low rate = high tree strength

### Importance of each Variable ###
# High mean decrease Gini (or high mean decrease in accuracy of the model)
# indicates a high importance of the variable within the model 

importance(ranForMod)
varImpPlot(ranForMod)

### Predictions for model ### 

predictMod <- predict(ranForMod, testD, type = "class")
print(predictMod)
tableP <- table(predictions=predictMod, actual=testD$low)
print(tableP)
sum(diag(tableP)/sum(tableP))

## Plotting ROC (Reciever Operator Curve) ###
# expressed graphically in 2-D
# plots relationship b/w sensitivity and false positive rate (FPR)

install.packages("pROC")
library(pROC)
pModProb <- predict(ranForMod, testD, type = "prob")
print(pModProb)
auc <- auc(testD$low, pModProb[,2])
plot(roc(testD$low, pModProb[,2]))

# Finding the best mtry by "tuning" the model
bestmtry <- tuneRF(trainD, trainD$low, ntreeTry = 200, 
                   stepFactor = 1.5, 
                   improve = 0.01, 
                   trace = T, 
                   plot = T)

