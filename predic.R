#Loading data
Loan_data<-read.csv("C:/Users/LENOVO/OneDrive/Desktop/predictive/loan_approval_dataset.csv")
Loan_data
View(Loan_data)
#names of column in dataset
names(Loan_data)

#number of rows in dataset
nrow(Loan_data)

#number of columns in dataset
ncol(Loan_data)
#removing unnecessary column
Loan_data<-Loan_data[-1]
#Summary of each column
summary(Loan_data$no_of_dependents)
summary(Loan_data$education)
summary(Loan_data$self_employed)
summary(Loan_data$income_annum)
summary(Loan_data$loan_amount)
summary(Loan_data$loan_term)
summary(Loan_data$cibil_score)
summary(Loan_data$residential_assets_value)
summary(Loan_data$commercial_assets_value)
summary(Loan_data$luxury_assets_value)
summary(Loan_data$bank_asset_value)
summary(Loan_data$loan_status)

#checking for na values
sum(is.na(Loan_data))

#converting categorical column to factor
Loan_data$education<-as.factor(Loan_data$education)
Loan_data$self_employed<-as.factor(Loan_data$self_employed)
Loan_data$loan_status<-as.factor(Loan_data$loan_status)
#converting categorical column to numerical column
Loan_data$education<-as.numeric(factor(Loan_data$education))
Loan_data$self_employed<-as.numeric(factor(Loan_data$self_employed))
#dataset doesnot contain any float value or column so we are not going to normalize it
library(ggplot2)
#DATA VISUALISATION
ggplot(Loan_data, aes(x = education)) +
  geom_bar(fill = c("green","red")) +
  geom_text(stat = "count", aes(label = ..count..), vjust = -0.5) + 
  labs(title = "Graduate  VS Not Graduate", x = "Education", y = "Count",fill="education") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5), 
    panel.grid.major = element_blank(),     
    panel.grid.minor = element_blank()      
  )


# correlation
library(psych)
pairs.panels(Loan_data)
#PreProcessing of data
#Splitting data into training and testing part
indexx<-sample(1:nrow(Loan_data),nrow(Loan_data)*0.7)
indexx

#training set
train_set<-Loan_data[indexx,]
#Testing set
test_set<-Loan_data[-indexx,]

#KNN Model 
#Installing Libraries
install.packages("class")
install.packages("caret")
#loading libraries
library(class)
library(caret)
set.seed(123)
#Training model
vect<-seq(3,51,2)
knn_best_accuracy<-0
knn_best_f1_score<-0
knn_best_precision<-0
knn_best_recall<-0
best_k_value<-0
knn_k<-vect
knn_accuracy<-c()
for (i in vect){
      KNN_Model<-knn(train_set[,-12],test_set[,-12],train_set[,12],k=7)
      confusion_matrix<-table(test_set$loan_status,KNN_Model)
      #finding accuracy
      TP <- confusion_matrix[1, 1]
      FP <- confusion_matrix[1, 2]
      FN <- confusion_matrix[2, 1]
      TN <- confusion_matrix[2, 2]
      accuracy<-(sum(diag(confusion_matrix))/sum(confusion_matrix))*100
      recall<-((TP)/(TP+FN))
      precision<-((TP)/(TP+FP))
      #when we are going to calculate f1 score precision and recall must be in decimal
      f1<-(((recall*precision*2)/(recall+precision)))*100
      knn_accuracy<-c(knn_accuracy,accuracy)
      print(accuracy)
      if (accuracy > knn_best_accuracy) {
          knn_best_accuracy <- accuracy
          best_k_value <- i
      }
      if(recall>knn_best_recall){
          knn_best_recall<-recall
      }
      if(f1>knn_best_f1_score){
          knn_best_f1_score<-f1
      }
      if(precision>knn_best_precision){
          knn_best_precision<-precision
      }
}
par(bg="#222831")
plot( knn_k,knn_accuracy, type = "o", col = c("#d38ad2"), xlab = "K values", ylab = "KNN_accuracy", main = "K_Values VS Accuracy",lwd=3, col.main = "#e0e0e0",       # Main title color
      col.lab = "#e0e0e0",      # Axis labels color (xlab and ylab)
      col.axis = "#e0e0e0",border="black")
paste("Best accuracy: ",knn_best_accuracy)
paste("Best K value: ",best_k_value)
paste("Best recall value: ",knn_best_recall*100)
paste("Best f1 score value: ",knn_best_f1_score)
paste("Best precision value: ",knn_best_precision*100)

names(Loan_data)

#svm
library(e1071)
vect<-c("linear","radial","polynomial","sigmoid")
best_kernel<-""
svm_best_accuracy<-0
svm_best_f1_score<-0
svm_best_precision<-0
svm_best_recall<-0
svm_kernel<-vect
svm_accuracy<-c()
for (i in vect){
      model<-svm(loan_status~.,data=train_set,kernel=i)
      predicted<-predict(model,test_set)
      tb<-table(test_set$loan_status,predicted)
      TP <- tb[1, 1]
      FP <- tb[1, 2]
      FN <- tb[2, 1]
      TN <- tb[2, 2]
      print(sum(diag(tb)/sum(tb))*100)
      recall<-((TP)/(TP+FN))
      precision<-((TP)/(TP+FP))
      #when we are going to calculate f1 score precision and recall must be in decimal
      f1<-(((recall*precision*2)/(recall+precision)))*100
      accu<-sum(diag(tb)/sum(tb))
      svm_accuracy<-c(svm_accuracy,accu*100)
      if (accu > svm_best_accuracy) {
          svm_best_accuracy <- accu
          best_kernel <- i
      }
      if(recall>svm_best_recall){
          svm_best_recall<-recall
      }
      if(f1>svm_best_f1_score){
          svm_best_f1_score<-f1
      }
      if(precision>svm_best_precision){
          svm_best_precision<-precision
      }
}
par(bg="#222831")
barplot(svm_accuracy, names.arg = svm_kernel, col = c("#d1493d","#76d154","#ff7b9c","#ffaaff"), xlab = "Kernel", ylab = "Accuracy", main = "Kernel vs Accuracy",ylim=c(0,max(svm_accuracy+10)),
        col.main = "#e0e0e0",       
        col.lab = "#e0e0e0",      
        col.axis = "#e0e0e0" ,border = "black")
paste("Best accuracy: ",svm_best_accuracy)
paste("Best Kernel: ",best_kernel)
paste("Best recall value: ",svm_best_recall*100)
paste("Best f1 score value: ",svm_best_f1_score)
paste("Best precision value: ",svm_best_precision*100)

#Naive Bayes
library("e1071")
nv_model<-naiveBayes(loan_status~.,data=train_set)
nv_predicted<-predict(nv_model,test_set)
tb<-table(test_set$loan_status,nv_predicted)
TP <- tb[1, 1]
FP <- tb[1, 2]
FN <- tb[2, 1]
TN <- tb[2, 2]
naivebayes_accuracy<-sum(diag(tb)/sum(tb))
naivebayes_recall<-((TP)/(TP+FN))
naivebayes_precision<-((TP)/(TP+FP))
#when we are going to calculate f1 score precision and recall must be in decimal
naivebayes_f1<-(((naivebayes_recall*naivebayes_precision*2)/(naivebayes_recall+naivebayes_precision)))*100
paste("Best accuracy: ",naivebayes_accuracy*100)
paste("Best recall value: ",naivebayes_recall*100)
paste("Best f1 score value: ",naivebayes_f1)
paste("Best precision value: ",naivebayes_precision*100)

#DECISION TREE
library(rpart)
library(rpart.plot)
model<-rpart(loan_status~.,data=train_set)
rpart.plot(model)

predicted<-predict(model,test_set,type="class")
predicted
tb<-table(test_set$loan_status,predicted)
tb
TP <- tb[1, 1]
FP <- tb[1, 2]
FN <- tb[2, 1]
TN <- tb[2, 2]
decisiontree_accuracy<-sum(diag(tb)/sum(tb))
decisiontree_recall<-((TP)/(TP+FN))
decisiontree_precision<-((TP)/(TP+FP))
#when we are going to calculate f1 score precision and recall must be in decimal
decisiontree_f1<-(((decisiontree_recall*decisiontree_precision*2)/(decisiontree_recall+decisiontree_precision)))*100
paste("Best accuracy: ",decisiontree_accuracy*100)
paste("Best recall value: ",decisiontree_recall*100)
paste("Best f1 score value: ",decisiontree_f1)
paste("Best precision value: ",decisiontree_precision*100)

#RANDOM FOREST
library(randomForest)
vec<-seq(25,400,25)
vec
rf_best_accuracy<-0
rf_best_f1_score<-0
rf_best_precision<-0
rf_best_recall<-0
best_ntree<-0
rf_ntree<-vec
rf_accu<-c()
for (i in vec){
      rf<-randomForest(loan_status~.,data=train_set,ntree=i)
      predicted<-predict(rf,test_set,type="class")
      tb<-table(test_set$loan_status,predicted)
      TP <- tb[1, 1]
      FP <- tb[1, 2]
      FN <- tb[2, 1]
      TN <- tb[2, 2]
      recall<-((TP)/(TP+FN))
      precision<-((TP)/(TP+FP))
      #when we are going to calculate f1 score precision and recall must be in decimal
      f1<-(((recall*precision*2)/(recall+precision)))*100
      print(paste("Accuracy at number of trees ",i," is ",sum(diag(tb)/sum(tb))))
      accu<-sum(diag(tb)/sum(tb))
      rf_accu<-c(rf_accu,accu)
      if (accu > rf_best_accuracy) {
          rf_best_accuracy <- accu
          best_ntree <- i
      }
      if(recall>rf_best_recall){
          rf_best_recall<-recall
      }
      if(f1>rf_best_f1_score){
          rf_best_f1_score<-f1
      }
      if(precision>rf_best_precision){
          rf_best_precision<-precision
      }
}
par(bg="#222831")
plot( rf_ntree,rf_accu, type = "o", col = c("#d1493d"), xlab = "number of tree", ylab = "randomforest_accuracy", main = "RF_ntree VS RF_Accuracy",lwd=3, col.main = "#e0e0e0",       # Main title color
      col.lab = "#e0e0e0",      # Axis labels color (xlab and ylab)
      col.axis = "#e0e0e0",border="black")
paste("Best accuracy: ",rf_best_accuracy*100)
paste("Best_ntree: ",best_ntree)
paste("Best recall value: ",rf_best_recall*100)
paste("Best f1 score value: ",rf_best_f1_score)
paste("Best precision value: ",rf_best_precision*100)

#kmean
install.packages("arules")
install.packages("cluster")
library(arules)
library(cluster)
kmean_data<-Loan_data[-12]
vect<-seq(2,30,1)
set.seed(42)
kmean_best_accuracy<-0
kmean_best_f1_score<-0
kmean_best_precision<-0
kmean_best_recall<-0
best_nstart<-0
kmean_acc<-c()
kmean_nstart<-vect
for (i in vect){
      model<-kmeans(kmean_data,centers=2,nstart=i)
      #confusion matrix
      tb<-table(Loan_data$loan_status,model$cluster)
      TP <- tb[1, 1]
      FP <- tb[1, 2]
      FN <- tb[2, 1]
      TN <- tb[2, 2]
      recall<-((TP)/(TP+FN))
      precision<-((TP)/(TP+FP))
      #when we are going to calculate f1 score precision and recall must be in decimal
      f1<-(((recall*precision*2)/(recall+precision)))*100
      print(sum(diag(tb))/sum(tb))
      accu<-sum(diag(tb)/sum(tb))
      kmean_acc<-c(kmean_acc,accu)
      if (accu > kmean_best_accuracy) {
          kmean_best_accuracy <- accu
          best_nstart <- i
      }
      if(recall>kmean_best_recall){
          kmean_best_recall<-recall
      }
      if(f1>kmean_best_f1_score){
          kmean_best_f1_score<-f1
      }
      if(precision>kmean_best_precision){
          kmean_best_precision<-precision
      }
}
kmean_acc
kmean_nstart
par(bg="#222831")
plot( kmean_nstart,kmean_acc, type = "o", col = c("#34d399"), xlab = "kmean_nstart", ylab = "kmean_accuracy", main = "kmean_nstart VS kmean_Accuracy",lwd=3,col.main = "#e0e0e0",       # Main title color
      col.lab = "#e0e0e0",      # Axis labels color (xlab and ylab)
      col.axis = "#e0e0e0")
paste("Best accuracy: ",kmean_best_accuracy*100)
paste("Best accuracy: ",best_nstart)
paste("Best recall value: ",kmean_best_recall*100)
paste("Best f1 score value: ",kmean_best_f1_score)
paste("Best precision value: ",kmean_best_precision*100)
diag(tb)

model$cluster
model$centers

#Neural network
library(neuralnet)
model<-neuralnet(loan_status~.,data=train_set,hidden = c(2,2,1))
plot(model)

#Hierarichal clustering
data<-Loan_data[-12]
data
distance<-dist(data,method = "euclidean")
model<-hclust(distance,method="single")
model
clusters <- cutree(model, k = 2)
tb<-table(actual = Loan_data$loan_status,predicted = clusters)
tb
hierarchial_accuracy<-sum(diag(tb)/sum(tb))
TP <- tb[1, 1]
FP <- tb[1, 2]
FN <- tb[2, 1]
TN <- tb[2, 2]
hierarchial_recall<-((TP)/(TP+FN))
hierarchial_precision<-((TP)/(TP+FP))
#when we are going to calculate f1 score precision and recall must be in decimal
hierarchial_f1 <- (2 * (hierarchial_recall * hierarchial_precision)) / (hierarchial_recall + hierarchial_precision)
paste("Best accuracy: ",hierarchial_accuracy*100)
paste("Best recall value: ",hierarchial_recall*100)
paste("Best f1 score value: ",hierarchial_f1)
paste("Best precision value: ",hierarchial_precision*100)

#recall: (tp)/(tp+fn)
#precision: (tp)/(tp+fp)
#f1 score: 2*(p*r)/(p+r)
All_accuracy<-c(knn_best_accuracy,svm_best_accuracy*100,rf_best_accuracy*100,naivebayes_accuracy*100,decisiontree_accuracy*100,kmean_best_accuracy*100,hierarchial_accuracy*100)
All_accuracy
modell<-c("KNN","SVM","RF","NB","DTREE","KMN","HIERA")
barplot(All_accuracy, names.arg = modell, col = rainbow(length(modell)), ylab = "Model", xlab = "Accuracy", main = "Model vs Accuracy",ylim=c(0,max(svm_accuracy+10)),
        col.main = "#e0e0e0",       
        col.lab = "#e0e0e0",      
        col.axis = "#e0e0e0" ,border = "black",horiz = TRUE,width=12)
All_precision<-c(knn_best_precision*100,svm_best_precision*100,rf_best_precision*100,naivebayes_precision*100,decisiontree_precision*100,kmean_best_precision*100,hierarchial_precision*100)
All_f1_score<-c(knn_best_f1_score,svm_best_f1_score,rf_best_f1_score,naivebayes_f1,decisiontree_f1,kmean_best_f1_score,hierarchial_f1*100)
All_recall<-c(knn_best_recall*100,svm_best_recall*100,rf_best_recall*100,naivebayes_recall*100,decisiontree_recall*100,kmean_best_recall*100,hierarchial_recall*100)
All_precision
All_f1_score
All_recall

barplot(All_f1_score, names.arg = modell, col = rainbow(length(modell)), xlab = "Model", ylab = "f1 score", main = "Model vs f1 score",ylim=c(0,max(All_f1_score+10)),
        col.main = "#e0e0e0",       
        col.lab = "#e0e0e0",      
        col.axis = "#e0e0e0" ,border = "black")
barplot(All_recall, names.arg = modell, col = rainbow(length(modell)), xlab = "Model", ylab = "recall", main = "Model vs Recall",ylim=c(0,max(All_recall+10)),
        col.main = "#e0e0e0",       
        col.lab = "#e0e0e0",      
        col.axis = "#e0e0e0" ,border = "black")
barplot(All_precision, names.arg = modell, col = rainbow(length(modell)), xlab = "Model", ylab = "Precision", main = "Model vs Precision",ylim=c(0,max(All_precision+10)),
        col.main = "#e0e0e0",       
        col.lab = "#e0e0e0",      
        col.axis = "#e0e0e0" ,border = "black")


