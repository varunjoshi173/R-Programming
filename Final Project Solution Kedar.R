# ---
#   title: "Credit Risk Modeling"
# author: "Kedar Kanhere"
# date: "October 23, 2016"
# output: html_document
# ---
# We will not read the strings as factors, instead we will convert them one by one if required
#### Remove Duplicate Rows
# The Loan.ID is a unique identifier, so we will remove any duplicate values of that
# ```{r Unique}

#Read the csv here in loan_data and then start 
getwd()
loan_data <- read.csv("LoansTrainingSetV2.csv")
loan_unique<-loan_data[row.names(as.data.frame(unique(loan_data$Loan.ID))),]
#```
#### Cleaning the data
# We will take one column at a time, and clean it, convert it etc. as per our requirement  
# Column 1 :- Loan.ID
# ```{r Loan.ID}
class(loan_unique$Loan.ID)
# It is a character vector. and we have removed the duplicate values
#```
#Column 2 :- Customer ID 
#```{r Customer.ID}
class(loan_unique$Customer.ID)
# It is a character vector, and doesn't requires any cleaning

#Column 3 :- Loan.Status
#```{r Loan.Status}
# It is our Dependent Variable
class(loan_unique$Loan.Status)
# It is character vector, and needs to be converted to factor
loan_unique$Loan.Status<-as.factor(loan_unique$Loan.Status)
levels(loan_unique$Loan.Status)
table(loan_unique$Loan.Status)
# It has two levels, "Charged Off" and "Fully Paid". "Charged Off" are our defaulters.
#```
# Column 4 :- Current.Loan.Amount 
# ```{r Current.Loan.Amount}
class(loan_unique$Current.Loan.Amount)
# It is a numeric vector.
summary(loan_unique$Current.Loan.Amount)
# There are no missing values. But there are outliers.There is a big difference between mean and median
library(ggplot2)
qplot(loan_unique$Current.Loan.Amount,geom="histogram")
# Histogram suggests that we have outliers.
# Seperating them using IQR methodology.
outlier<-boxplot.stats(loan_unique$Current.Loan.Amount)
length(outlier$out)
# There are 12783 values that are outliers.
# Replacing them with NA's
loan_unique$Current.Loan.Amount[loan_unique$Current.Loan.Amount>=min(outlier$out)]<-NA
summary(loan_unique$Current.Loan.Amount)
qplot(loan_unique$Current.Loan.Amount,geom="histogram")
#```
#Column 5 :- Term
#```{r Term}
class(loan_unique$Term)
# It is a character vector. Needs to be converted to factor
loan_unique$Term<-as.factor(loan_unique$Term)
levels(loan_unique$Term)
table(loan_unique$Term)
# It has two levels, "Long Term" and "Short Term". Cleaning not required
#```
#Column 6:- Credit.Score
#```{r Credit.Score}
class(loan_unique$Credit.Score)
# It is a numeric vector.
summary(loan_unique$Credit.Score)
# It has NA's and the maximum value is 7510. But it should be between 0-800.
qplot(loan_unique$Credit.Score)
# Dividing any score more than 800 by 10
loan_unique$Credit.Score<-ifelse(loan_unique$Credit.Score>800,loan_unique$Credit.Score/10,loan_unique$Credit.Score)
summary(loan_unique$Credit.Score)
qplot(log(loan_unique$Credit.Score))
#Missing value treatment, replacing missing values by median
#loan_unique$Credit.Score[is.na(loan_unique$Credit.Score)==TRUE]<-median(loan_unique$Credit.Score,na.rm = T)
#```
# Column 7:- Years.in.current.job
# ```{r Years.in.current.job}
class(loan_unique$Years.in.current.job)
# It is a character vector.
table(loan_unique$Years.in.current.job)
# Needs to be converted to factor and "n/a" needs to be replaced to NA.
# Replacing "n/a"
library(stringr)
loan_unique$Years.in.current.job<-str_replace_all(loan_unique$Years.in.current.job,fixed("n/a"),NA)
table(loan_unique$Years.in.current.job)
#Converting character to factors
loan_unique$Years.in.current.job<-as.factor(loan_unique$Years.in.current.job)
summary(loan_unique$Years.in.current.job)
#```
#Column 8:- Home.Ownership 
#```{r Home.Ownership}
class(loan_unique$Home.Ownership)
# It's a character vector
table(loan_unique$Home.Ownership)
# Needs to be converted to factor and "HaveMortgage" needs to be converted to "Home Mortgage"
loan_unique$Home.Ownership<-str_replace_all(loan_unique$Home.Ownership, "HaveMortgage", "Home Mortgage")
loan_unique$Home.Ownership<-as.factor(loan_unique$Home.Ownership)
summary(loan_unique$Home.Ownership)
#```
#Column 9:- Annual.Income 
#```{r Annual.Income}
class(loan_unique$Annual.Income)
# It's a numeric vector
summary(loan_unique$Annual.Income)
qplot(loan_unique$Annual.Income)
quantile(loan_unique$Annual.Income,probs = seq(0,1,0.05),na.rm=TRUE)
# Outliers are in the top 5 % data only
outlier<-quantile(loan_unique$Annual.Income,probs = seq(0.95,1,0.01),na.rm=TRUE)
# Capping any values greater than 99% to 99th value
loan_unique$Annual.Income[loan_unique$Annual.Income>outlier[5]]<-outlier[5]
summary(loan_unique$Annual.Income)
#Converting to log scale 
loan_unique$Annual.Income<-log(loan_unique$Annual.Income)
qplot(log(loan_unique$Annual.Income))
#```
#Column 10:- Purpose
#```{r Purpose}
class(loan_unique$Purpose)
# It's a character vector
table(loan_unique$Purpose)
# Needs to be converted to a factor, and "other" and "Other" has to be merged
loan_unique$Purpose<-str_replace_all(loan_unique$Purpose,"other","Other")
table(loan_unique$Purpose)
loan_unique$Purpose<-as.factor(loan_unique$Purpose)
summary(loan_unique$Purpose)
#```
#Column 11:- Monthly.Debt
#```{r Monthly.Debt}
class(loan_unique$Monthly.Debt)
# It's a character vector, but needs to be converted to numeric

# It has $ sign and "," which needs to be replaced
# Replacing "$" sign with ""
loan_unique$Monthly.Debt<- str_replace_all(loan_unique$Monthly.Debt, fixed("$"), "")
#Replacing "," with ""
loan_unique$Monthly.Debt<- str_replace_all(loan_unique$Monthly.Debt, fixed(","), "")
# Converting to numeric
loan_unique$Monthly.Debt<-as.numeric(loan_unique$Monthly.Debt)
summary(loan_unique$Monthly.Debt)
qplot(loan_unique$Monthly.Debt)
# It has outliers, checking the quantiles
quantile(loan_unique$Monthly.Debt,probs = seq(0,1,0.05))
# Outliers are from 95 to 100. Let's dig deeper.
quantile(loan_unique$Monthly.Debt,probs = seq(0.95,1,0.01))
#Only 100th percentile is an outlier. We will replace it with 99th percentile
outlier<-quantile(loan_unique$Monthly.Debt,probs =c(0.99,1))
loan_unique$Monthly.Debt[loan_unique$Monthly.Debt>outlier[1]]<-outlier[1]
qplot(loan_unique$Monthly.Debt)
#```
#Column 12:- Years.of.Credit.History
#```{r Years.of.Credit.History}
class(loan_unique$Years.of.Credit.History)
# It is a numeric vector
summary(loan_unique$Years.of.Credit.History)
qplot(loan_unique$Years.of.Credit.History)
# Looks Clean, no need of any processing
#```
#Column 13:- Months.since.last.delinquent
#```{r Months.since.last.delinquent}
class(loan_unique$Months.since.last.delinquent)
# It is a numeric vector
summary(loan_unique$Months.since.last.delinquent)
# Has lots of NA's. 
# Checking for outliers
qplot(loan_unique$Months.since.last.delinquent)
# We will treat NA's later, if required.
#```
#Column 14:- Number.of.Open.Accounts
#```{r Number.of.Open.Accounts}
class(loan_unique$Number.of.Open.Accounts)
# It is a numeric vector
summary(loan_unique$Number.of.Open.Accounts)
# Checking for outliers
qplot(loan_unique$Number.of.Open.Accounts)
quantile(loan_unique$Number.of.Open.Accounts,probs = seq(0.95,1,0.01))
# Only the 100th percentile is an outlier,replacing it with 99 i
outlier<-quantile(loan_unique$Number.of.Open.Accounts,probs =c(0.99,1))
loan_unique$Number.of.Open.Accounts[loan_unique$Number.of.Open.Accounts>outlier[1]]<-outlier[1]
qplot(loan_unique$Number.of.Open.Accounts)
#```
#Column 15:- Number.of.Credit.Problems
#```{r Number.of.Credit.Problems}
class(loan_unique$Number.of.Credit.Problems)
# It is a numeric vector
summary(loan_unique$Number.of.Credit.Problems)
# Checking for outliers
qplot(loan_unique$Number.of.Credit.Problems)
quantile(loan_unique$Number.of.Credit.Problems,probs = seq(0,1,0.05))
table(loan_unique$Number.of.Credit.Problems)
#Cleaning not requried
#```
#Column 16:- Current.Credit.Balance
#```{r Current.Credit.Balance}
class(loan_unique$Current.Credit.Balance)
summary(loan_unique$Current.Credit.Balance)
# It is a numeric vector
#Checking for outliers
qplot(loan_unique$Current.Credit.Balance)
quantile(loan_unique$Current.Credit.Balance,probs = seq(0,1,0.05))
outlier<-quantile(loan_unique$Current.Credit.Balance,probs = seq(0.95,1,0.01))
loan_unique$Current.Credit.Balance[loan_unique$Current.Credit.Balance>outlier[5]]<-outlier[5]

qplot(sqrt(loan_unique$Current.Credit.Balance))
# Taking sqrt to make it normal
loan_unique$Current.Credit.Balance<-sqrt(loan_unique$Current.Credit.Balance)
#```
#Column 17:- Maximum.Open.Credit
#```{r Maximum.Open.Credit}
class(loan_unique$Maximum.Open.Credit)
head(loan_unique$Maximum.Open.Credit)
# It's a character vector,but has numeric values.
# It has some junk values such as "#VALUE!", which needs to be replaced with NA
loan_unique$Maximum.Open.Credit<- str_replace_all(loan_unique$Maximum.Open.Credit, fixed("#VALUE!"),NA)
#  Converting to numeric data
loan_unique$Maximum.Open.Credit<-as.numeric(loan_unique$Maximum.Open.Credit)
summary(loan_unique$Maximum.Open.Credit)
# It also has outliers
qplot(loan_unique$Maximum.Open.Credit)
#Checking the quantiles
quantile(loan_unique$Maximum.Open.Credit,probs = seq(0,1,0.05),na.rm = T)
quantile(loan_unique$Maximum.Open.Credit,probs = seq(0.95,1,0.01),na.rm = T)
quantile(loan_unique$Maximum.Open.Credit,probs = seq(0.99,1,0.001),na.rm = T)
# Capping beyond 150000
loan_unique$Maximum.Open.Credit[loan_unique$Maximum.Open.Credit>150000]<-150000
qplot(sqrt(loan_unique$Maximum.Open.Credit))
# Replacing NA's by median
loan_unique$Maximum.Open.Credit<-ifelse(is.na(loan_unique$Maximum.Open.Credit),21780,loan_unique$Maximum.Open.Credit)
# Taking sqrt to make it more normal 
loan_unique$Maximum.Open.Credit<-sqrt(loan_unique$Maximum.Open.Credit)
#```
#Column 18:- Bankruptcies
#```{r Bankruptcies}
class(loan_unique$Bankruptcies)
# It's a numeric vector
summary(loan_unique$Bankruptcies)
# Replacing NA's with median
loan_unique$Bankruptcies<-ifelse(is.na(loan_unique$Bankruptcies),0,loan_unique$Bankruptcies)
table(loan_unique$Bankruptcies)

#```
#Column 19:- Tax.Liens
#```{r Tax.Liens}
class(loan_unique$Tax.Liens)
# It's a numeric vector
summary(loan_unique$Tax.Liens)
# Replacing NA's with median
loan_unique$Tax.Liens<-ifelse(is.na(loan_unique$Tax.Liens),0,loan_unique$Tax.Liens)
summary(loan_unique$Tax.Liens)
table(loan_unique$Tax.Liens)
#```

#### Replacing NA's

#```{r}
# Counting number of NA's in each column
sapply(loan_unique, function(x){sum(is.na(x))})
# Removing the column Months.since.last.delinquent
loan_unique$Months.since.last.delinquent<-NULL
# Applying mice for NA's in Years.in.current.job  and Annual.Income 
sapply(loan_unique,summary)
library(mice)
simple<-loan_unique[,4:18]
impute<-mice(simple,m=1)
loan_complete<-complete(impute)
summary(loan_complete)
#Adding loan status
loan_complete<-cbind(loan_complete,Loan.Status=loan_unique$Loan.Status)
#```
#Feature Selection from factor data using Chi-Square
#```{r}
str(loan_char)
# Between Loan Status and Term
chisq.test(loan_char$Loan.Status,loan_char$Term)
table(loan_char$Loan.Status,loan_char$Term)
cor(as.numeric(loan_char$Loan.Status),as.numeric(loan_char$Term),method = "spearman",use = "pairwise.complete.obs")
chisq.test(loan_char$Loan.Status,loan_char$Term)
#```
#Feature Selection from numeric data using correlation matrix
#```{r}
cor(loan_numeric$Bankruptcies,loan_numeric$Tax.Liens,method = "kendall",use = "pairwise.complete.obs")
cor(as.numeric(loan_char$Loan.Status),loan_numeric$Bankruptcies,method = "kendall",use = "pairwise.complete.obs" )
chisq.test(loan_char$Loan.Status,loan_numeric$Bankruptcies)
chisq.test(loan_char$Loan.Status,loan_numeric$Tax.Liens)
cor(as.numeric(loan_char$Loan.Status),loan_numeric$Tax.Liens,method = "kendall",use = "pairwise.complete.obs")
table(loan_char$Loan.Status,loan_numeric$Tax.Liens)
chisq.test(loan_char$Loan.Status,loan_char$Home.Ownership)
table(loan_char$Loan.Status,loan_char$Home.Ownership)
t.test(loan_numeric$Credit.Score~loan_char$Loan.Status)
t.test(loan_numeric$Current.Loan.Amount~loan_char$Loan.Status)
summary(aov(loan_numeric$Current.Loan.Amount~loan_char$Loan.Status))
model<-lm(loan_numeric$Current.Loan.Amount~loan_char$Loan.Status)
anova(model)
#```
###Feature Engineering
#```{r}
# Converting labels to 0 and 1 
loan_complete$Loan.Status<-ifelse(loan_complete$Loan.Status=="Charged Off",1,0)
#```
### Splitting the data
#Now since the cleaning is completed let's split the data into `train` and `test` using `caTools` library
#```{r split}
library(caTools)
set.seed(1)
spl<-sample.split(loan_complete$Loan.Status,SplitRatio = 0.7)
train<-subset(loan_complete,spl==TRUE)
test<-subset(loan_complete,spl==FALSE)
#```

### Model Building
#Let's start with XGBoost
#```{r XGB}
library(xgboost)
library(Matrix)
# Preparing sparse matrix
sparse.train<-sparse.model.matrix(Loan.Status~.-1,data = train)
dtrain<-xgb.DMatrix(data=sparse.train,label=train$Loan.Status)
#names(sparse.train)
sparse.test<-sparse.model.matrix(Loan.Status~.-1,data=test)
dtest<-xgb.DMatrix(data=sparse.test,label=test$Loan.Status)
watchlist<-list(test=dtest,train=dtrain)
params<-list(eta=0.01,max_depth=4,objective="binary:logistic")

model_xgb<-xgb.train(params = params,nrounds=5000,data=dtrain,verbose=1,watchlist=watchlist)

importabce<-xgb.importance(feature_names = colnames(sparse.train),model = model_xgb)
summary(importabce)
xgb.plot.importance(importabce)
xgb.dump(model_xgb,fname = 'eta0.01nr1000d4')
xgb.save(model_xgb,fname = 'eta0.01nr1000d4')
#```
### Making Prediction
