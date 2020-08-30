#Wednesday, Aug. 26, 2020

###------------------------------------###
##
## Class Three: Programming Fundamentals
## For: Institute of Advanced Analytics 
## Instructor: Aaron Baker 
## Email: ambaker31991@gmail.com
##
###------------------------------------### 


##----------------------------##
## Logicals
##----------------------------##

# In addition to numeric and character classes, there is a logical

a <- 1
typeof(a)

a <- "1"
typeof(a)


# A logical is a binary representation of True and False 

a <- TRUE
a

b <- FALSE
b

typeof(b)

# Logicals are used for evaluating comparisons, such as:

# equality
# note the double equals == operator is a logical comparision, opposed to a single equal = being an assignment 

2==2
typeof(2==2)

'cat' == 'dog'

'cat' == 'cat'

#Not equal operator 
2!=2 

# greater than/less than
2>2

2>=2

2<1

2<=1

# Null Values 
V1 <- 1
V1[10] <- 10

is.na(V1)
!is.na(V1)

# Contained within set 
V1

1 %in% V1
10 %in% V1
2 %in% V1


c(1,2) %in% V1

# If you want not in, then use the not ! operator around the entire statement 
!(1 %in% V1)

# Note, logicals can be used with other data types as well
a <- c(1,2,3,4,5) 
a <= 1

b <- c(1,2,7,9,5)
a == b
a != b

A <- matrix(1:10,2,5)
B <- matrix(seq(1,20,2),2,5)

A == B
A != B

identical(a,b)
identical(A,B)

all.equal(A,B)

##----------------------------##
## Conditionals
##----------------------------##

# Conditionals are statements that allow us to control the flow of execution 
# We use logicals to evaluate conditional statements 
# Conditionals include if, else, ifelse 

set.seed(1)  
values <- rnorm(1000,0,1)  
mean_values <- round(mean(values),2)

# The if statement evaluates the logical in the ( ) and if TRUE, executes the code in { }
if (mean_values<=0) {
  print(paste("The mean is below zero, at value", mean_values))
}

# If you're only going to execute a single statement after the conditional, you can withold the { } 
if (mean_values<=0) print("The mean is below zero")

# If you want code to execute when FALSE as well, then we add an else statement
mean_values <- mean_values + 1

if (mean_values<=0) {
  print(paste("The mean is below zero, at value", mean_values))
} else {
  print(paste("The mean is above zero, at value", mean_values))
}

# You can nest conditionals
std_dev_values <- sd(values)

if (mean_values<=0) {
  print(paste("The mean is below zero, at value", mean_values))
  
  if (std_dev_values<=1){
    print(paste("Standard deviation less than one!"))
  }
  
} else {
  print(paste("The mean is above zero, at value", mean_values))
  
  if (std_dev_values>1){
    print(paste("Standard deviation greater than one!"))
  }
  
}

# Note, you can use multiple logicals with the:
# Or operator | 
# And operator &

if (mean_values>=0 & std_dev_values>=1) {
  print(paste("The mean", mean_values, " is above 0, and the standard deviation", std_dev_values, "is above 1"))
}

# If you want to evaluate multiple if statements, use an else if 
std_dev_values = 0.95

if (mean_values>=0 | std_dev_values>=1) {
  
  if(mean_values>=0 & std_dev_values>=1){
    print("Both conditions met") 
  } else if (mean_values>=0 & std_dev_values <= 1) {
    print("Only mean condition met") 
  } else {
    print("Only standard deviation condition met")
  }
  
}


# Additionally, you can use the ifelse function to quickly assign a value based on a condition
ifelse(std_dev_values>=1, "above one", "below one")

std_dev_vector <- c(1.2,0.8,0.3,2.4)
ifelse(std_dev_vector>=1, "above one", "below one")

##----------------------------##
## Creating Functions 
##----------------------------##

# recall, a function is applied to an object to obtain a result
numbers <- seq(1:10)
sum(numbers)

# you can create custom functions to be used later
calculator <- function(data, type){
  if(type=="mean"){
    value <- mean(data)
  } else if (type=="sum"){
    value <- sum(data) 
  } else if (type=="min"){
    value <- min(data) 
  } else {
    value <- "function not in calculator"
  }
  return(value)
}

calculator(numbers, "mean")
calculator(numbers, "sum")
calculator(numbers, "min")
calculator(numbers, "max")

# note, we have not provided a default value so it errors
calculator(numbers)

# to provide a default, use the equal:
calculator <- function(data, type='mean'){
  if(type=="mean"){
    value <- mean(data)
  } else if (type=="sum"){
    value <- sum(data) 
  } else if (type=="min"){
    value <- min(data) 
  } else {
    value <- "function not in calculator"
  }
  return(value)
}

calculator(numbers)

# If you want to return multiple values, you need store them in a vector or list and return that object
univariate_summary <- function(data){
  ntot <- length(data)
  mean <- mean(data)
  std <- sd(data)
  percentiles  <- quantile(data, probs=c(0, 0.25, 0.50, 0.75, 1))
  
  l1 <- list(n_obs=ntot, mean=mean, std=std, percentiles=percentiles)
  return(l1)
  
}

results <- univariate_summary(numbers)
results$percentiles
results$std


# Note, variables created in functions only exist in the function environment, thus not accessible after the function runs:
results <- univariate_summary(numbers)
ntot

# If you want the variables to be passed to the global environment, use a global assignment operator <<-
univariate_summary <- function(data){
  ntot <<- length(data)
  mean <- mean(data)
  std <- sd(data)
  percentiles  <- quantile(data, probs=c(0, 0.25, 0.50, 0.75, 1))
  
  l1 <- list(n_obs=ntot, mean=mean, std=std, percentiles=percentiles)
  return(l1)
  
}

results <- univariate_summary(numbers)
ntot

# What happens if we give our function the wrong type of data?

animals <- c("cat","dog")

results <- univariate_summary(animals)

# We see it errors. If we want to determine where, we can use the traceback function
#this provides the calls that occurred prior to the error occurring
traceback()

# More useful, we can place a browser() function within our function, then run it line by line to see where it errors
univariate_summary <- function(data){
  
  browser() #add the browser() function at the beginning of your code
  
  ntot <<- length(data)
  mean <- mean(data)
  std <- sd(data)
  percentiles  <- quantile(data, probs=c(0, 0.25, 0.50, 0.75, 1))
  
  l1 <- list(n_obs=n, mean=mean, std=std, percentiles=percentiles)
  return(l1)
  
}

results <- univariate_summary(animals)

# It appears the issue is that we are expecting numbers while providing strings
typeof(animals)

# How do we handle errors when creating the function?
# The most common route is to actively break the function and raise an error using the stop function
univariate_summary <- function(data){
  
  if(is.numeric(data)==FALSE){
    warning("Input data is not numeric")
    stop("Input data is not numeric") #note the warning() function will present a warning but not stop execution of the function
  } 
  
  ntot <- length(data)
  mean <- mean(data)
  std <- sd(data)
  percentiles  <- quantile(data, probs=c(0, 0.25, 0.50, 0.75, 1))
  
  l1 <- list(n_obs=ntot, mean=mean, std=std, percentiles=percentiles)
  return(l1)
  
}

results <- univariate_summary(animals)
results <- univariate_summary(numbers)

#Lastly, when we have multiple functions they can call upon one another
univariate_summary <- function(data){
  
  if(is.numeric(data)==FALSE){
    warning("Input data is not numeric")
    stop("Input data is not numeric") #note the warning() function will present a warning but not stop execution of the function
  } 
  
  ntot <- length(data)
  mean <- calculator(data,'mean') #note i am using the calculator() function we created
  std <- sd(data)
  percentiles  <- quantile(data, probs=c(0, 0.25, 0.50, 0.75, 1))
  
  l1 <- list(n_obs=ntot, mean=mean, std=std, percentiles=percentiles)
  return(l1)
  
}

univariate_summary(numbers)


##----------------------------##
## Looping 
##----------------------------##

# Occassionally, we need perform a task in an iterative cycle, also known as a loop

# For loops - they iterate a defined number of times 
sequence <- seq(0,50,5)
sequence

for(iter in number_to_iterate){
  
}

#Note this will iterate 41 times, the number of elements in "sequence"
for(i in 1:length(sequence)){
  print(paste("Now at iteration", i, ", value of sequence is", sequence[i]))
  Sys.sleep(0.50)
}

#Sys.sleep(0.50) slows down the loop (just makes it print out slower)

#By default, R will iterate over all the elements in a vector without needing to designate a number
for(value in sequence){print(paste("Value of sequence is", value))Sys.sleep(0.50)}

# You can break a loop with the break operator
for(i in 1:length(sequence)){
  
  if(i>5) break
  
  print(paste("Now at iteration", i, ", value of sequence is", sequence[i]))
  
  Sys.sleep(0.50)
  
}

# You can skip to the next iteration using the next operator 
for(i in 1:length(sequence)){
  
  if((i %% 2)!=0) next
  
  print(paste("Now at iteration", i, ", value of sequence is", sequence[i]))
  
  Sys.sleep(0.50)
  
}

#While loops - iterate so long as the condition is true 
#With while loops, it's important to set your starting conditions
continue <- TRUE 
i <- 0
while(continue==TRUE){
  i = i + 1 
  print(paste("At iteration", i, "continue still set to", continue))
  if(i>=5){
    continue <- FALSE #if you leave this line out, it will loop infinitely, you have to tell it when to stop
    print(paste("Iteration", i, "reached. Continue set to", continue))
    print(paste("While loop terminated upon reaching iteration", i))
  } 
  Sys.sleep(0.50)
}

#You can nest loops of the same type or different types - for example, for every value of i it will do a loop of n 
continue <- TRUE 
i <- 0

while(continue==TRUE){
  i = i + 1 
  print(i)
  if(i>=5) continue <- FALSE
  
  for(n in 1:3){
    print(paste("The value of i is", i, ",and the value of n is", n))
    Sys.sleep(0.25)
  }
  
}


##----------------------------##
## Vectorization 
##----------------------------##  

#Typically you want to avoid looping because it is very slow compared to alternative methods to accompish the same task
#Vectorization generally means the use of linear algebra to accomplish tasks instead of loops

#For example, if you want to sum the values in an array, you could loop through them:

individual_values <- 1:100000000

#Summing with a loop
start_time <- Sys.time()

total_loop <- 0 
for (val in individual_values){ #for loop to sum the values
  total_loop <- total_loop + val 
}

end_time<- Sys.time()
loop_time <- end_time - start_time

#Instead, you can use functions that are vectorized (linear algebra / matrix operations) 
start_time <- Sys.time()

total_sum <- sum(individual_values) #using the sum function

end_time <- Sys.time()
sum_time <- end_time - start_time

#How much faster is the sum function then loop?
as.numeric(loop_time) / as.numeric(sum_time)




