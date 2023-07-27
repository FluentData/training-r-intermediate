---
title: "Custom Functions"
output: 
  html_document: 
    keep_md: yes
---



If we can do _anything_ in R, then we already know how to use functions. This tutorial
will cover how to create our own functions. We'll also learn how to write functions
that work well in the tidyverse. 

- Writing functions
- Mutate functions
- Summarise functions
- Data frame functions


# Writing functions

We already know that functions in R usually take at least one parameter inside the
parentheses. For example, if we want to use the `mean()` function, we look at the
documentation by typing `?mean()` and see that it takes at least one required 
numeric parameter named `x`.

The first function we write will be our own version of a function that calculates
the mean of a numeric vector. Since we can't just call it `mean` (or, if we do, we will
replace that base function in our environment), we will call our function `my_mean`.

Here is the basic structure of creating a custom function, which uses the appropriately
named  `function()`.


```r
my_mean <- function( ){
  
}
```

The parentheses will contain the parameters we want our function to have, and the
curly braces will contain the operation that will be performed on the parameters. 
First, we'll need a vector of numbers, so we'll call it the `numbers` parameter.


```r
my_mean <- function(numbers){
  #do something to numbers
}
```

Next we'll calculate the average of the values in `numbers`.


```r
my_mean <- function(numbers){
  
sum(numbers) / length(numbers)
  
}
```



Now let's try our function and compare it to the built in R function.


```r
my_vector <- c(1, 3, 5, 2, 6, 9, 0)
vector_mean <- my_mean(numbers = my_vector)
vector_mean
```

```
## [1] 3.714286
```

```r
mean(my_vector)
```

```
## [1] 3.714286
```

# Mutate functions

When we are working with data frames, it's useful to create functions that work 
with `mutate()`. As described in the second
[Data Manipulation](training-r-intermediate/blob/initial-update/2-Data-Manipulation-2/readme.md)
tutorial, the `mutate()` function takes a data frame as the first argument and
allows you to add new columns. A custom function that takes a vector as the 
first argument and returns a vector with the same length (and in the same order)
is a mutate function.

To demonstrate, we will create a function that converts temperature values from
Fahrenheit to Celsius.


```r
convert_temp <- function(temp_value) {
  
  (temp_value - 32) * (5 / 9) 
  
}

# test it out on a vector of numbers

convert_temp(c(32, 0, 100))
```

```
## [1]   0.00000 -17.77778  37.77778
```

We can use this function along with `mutate()` to add a `temp_celsius` column to
the `chicago_air` data frame.


```r
library(dplyr)
library(region5air)
data(chicago_air)

chicago_celsius <- mutate(chicago_air, temp_celsius = convert_temp(temp))

head(chicago_celsius, 3)
```

```
## # A tibble: 3 × 7
##   date       ozone  temp pressure month weekday temp_celsius
##   <date>     <dbl> <dbl>    <dbl> <dbl>   <dbl>        <dbl>
## 1 2021-01-01 0.019    42    1007.     1       6         5.56
## 2 2021-01-02 0.02     35    1003.     1       7         1.67
## 3 2021-01-03 0.026    34    1002.     1       1         1.11
```

A better function design would take into account which temperature scale is being
converted, and which scale it is being converted to. Here is a modified version
of the function that uses two more parameters for that purpose.


```r
convert_temp <- function(temp_value, to = c("celcius", "kelvin"), from = "fahrenheit") {
  
  if(from == "fahrenheit" & to == "celcius") {
    
    (temp_value - 32) * (5 / 9)
    
  } else if(from == "fahrenheit" & to == "kelvin") {
    
    (temp_value - 32) * (5 / 9) + 273.15
    
  } else {
    
    stop("currently this function only converts from Fahrenheit to Celcius or Kelvin")
    
  }
  
}

chicago_kelvin <- mutate(chicago_air, temp_kelvin = convert_temp(temp, "kelvin"))

head(chicago_kelvin, 3)
```

```
## # A tibble: 3 × 7
##   date       ozone  temp pressure month weekday temp_kelvin
##   <date>     <dbl> <dbl>    <dbl> <dbl>   <dbl>       <dbl>
## 1 2021-01-01 0.019    42    1007.     1       6        279.
## 2 2021-01-02 0.02     35    1003.     1       7        275.
## 3 2021-01-03 0.026    34    1002.     1       1        274.
```

Now the `convert_temp()` function can convert from Fahrenheit to Celsius or
Kelvin. Notice we do not need to supply the `from =` parameter, since the default
value is the only value that can be used. The `stop()` function is a way to let
the user know that this function only converts from Fahrenheit, by adding a 
helpful message for any situation that doesn't fall within the currently allowed
options. Further modification to the function would allow for conversion from 
any of the temperature scales to any other.

# Summarise functions

Summarise functions take a vector of values and return a single value. They work
work well with the `summarise()` function from `dplyr`.

As an example, we could write a function that takes a vector of ozone values in
ppm and returns the count of those values that exceeded the standard of 0.070 ppm.


```r
standard_exceedances <- function(concentration) {
  
  sum(concentration > 0.070)
  
}
```

We can use this function along with `group_by()` and `summarise()` to tell us 
how many days there was an exceedance of the standard value in a given month.


```r
chicago_grouped <- group_by(chicago_air, month)

chicago_exceedances <- summarise(chicago_grouped, 
                                 ozone_exceedances = standard_exceedances(ozone))

# equivalently using pipes
chicago_exceedances <- chicago_air %>%
  group_by(month) %>%
  summarise(ozone_exceedances = standard_exceedances(ozone))

head(chicago_exceedances, 3)
```

```
## # A tibble: 3 × 2
##   month ozone_exceedances
##   <dbl>             <int>
## 1     1                 0
## 2     2                 0
## 3     3                 0
```




# Data frame functions

Another type of function that is useful with `dplyr` and other 
[tidyverse packages](https://www.tidyverse.org/packages/)
are data frame functions. These are functions that take a data frame as the
first parameter and return a data frame. This keeps the data in a 
[tidy shape](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html)
and allows for a data flow that works with pipes.

A useful data frame function might summarize data in the same way, if you find 
yourself doing the same manual operations every time you get new data in the same
format. For example, it maight be useful to summarize daily 1-hour maximum ozone 
for the year.


```r
summarise_ozone <- function(ozone_df, ozone_column) {
  
  ozone_df %>%
    summarise(first_03_max = max({{ozone_column}}, na.rm = TRUE),
              second_03_max = sort({{ozone_column}}, decreasing = TRUE)[2],
              third_03_max = sort({{ozone_column}}, decreasing = TRUE)[3],
              fourth_03_max = sort({{ozone_column}}, decreasing = TRUE)[4])
  
}

chicago_air %>%
  summarise_ozone(ozone)
```

```
## # A tibble: 1 × 4
##   first_03_max second_03_max third_03_max fourth_03_max
##          <dbl>         <dbl>        <dbl>         <dbl>
## 1        0.065         0.064        0.062         0.062
```

The double curly braces `{{ }}` allow you to provide the column name without 
quotes. The function also allows you to pass a data frame that has been grouped
using the `group_by()` function. Here we summarize the ozone data by month:


```r
chicago_air %>%
  group_by(month) %>%
  summarise_ozone(ozone)
```

```
## # A tibble: 12 × 5
##    month first_03_max second_03_max third_03_max fourth_03_max
##    <dbl>        <dbl>         <dbl>        <dbl>         <dbl>
##  1     1        0.037         0.033        0.033         0.032
##  2     2        0.055         0.051        0.048         0.047
##  3     3        0.057         0.05         0.049         0.048
##  4     4        0.057         0.057        0.056         0.055
##  5     5        0.061         0.056        0.056         0.056
##  6     6        0.065         0.064        0.062         0.062
##  7     7        0.053         0.05         0.049         0.048
##  8     8        0.05          0.046        0.044         0.044
##  9     9        0.057         0.056        0.055         0.054
## 10    10        0.05          0.049        0.049         0.047
## 11    11        0.041         0.041        0.038         0.037
## 12    12        0.033         0.033        0.032         0.032
```
