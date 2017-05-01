# Begin by importing two libraries 
library(randomForest)
library(MASS)

# set seed 
help("set.seed")
set.seed(123)

# Store data from MASS package into a DataFrame 
dFrame <- birthwt

# Identify predictor variables and target variable
# Identify catagorical target variable 
help("birthwt")
str(dFrame)
View(dFrame)

# use randomForest model to try and predict the importance of 
# each variable as it relates to the traget variable ("low")

head(dFrame)
summary(dFrame)

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

# Acquire new library "caTools" to assist in the splitting of sampled data
help("caTools")
library(caTools)

ivar <- sample.split(Y = dFrame$low, SplitRatio = 0.7) 
# Now assign the split data to a "train" and a "test" data frame
trainD <- dFrame[ivar,]
testD <- dFrame[!ivar,]

# Random Forest (randomForest) parameters 
# A "forest" of random decision trees
  # mtry = number of variables selected at each split (selected randomly)
    # predication by randomForest is the mean of the random decision trees
    # mtry should be a value lower than the total number of variables 
    # for classification trees use the square root of number of variables
# sampsiz = number of rows that are randomly sampled for each tree 
    # samsize should be lower than the total number of rows in your data set
  # ntree = number of trees you would like to grow
  # nodesize = minimum size of terminal nodes (larger the number smaller the tree)

#### FIT THE MODEL ####

ranForMod <- randomForest(low~., data = trainD, mtry=3, ntree=20)
print(ranForMod)

# Error rate 
# OOB (out of bag rate) mis-classification rate 
# Low rate = high tree strength

### Importance of each Variable ###
# Use the Gini coefficient to measure the inequality of variables 
# Where a value of 0.0 would be perfect equality and
# a value of 1.0 would be maximal inequality 
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
pModProb <- predict(ranForMod, testD, type="prob")
print(pModProb)
auc <- auc(testD$low, pModProb[,2])
plot(roc(testD$low, pModProb[,2]))

# Finding the best mtry by "tuning" the model
bestmtry <- tuneRF(trainD, trainD$low, ntreeTry = 200, 
                   stepFactor = 1.5, 
                   improve = 0.01, 
                   trace = T, 
                   plot = T)
                   