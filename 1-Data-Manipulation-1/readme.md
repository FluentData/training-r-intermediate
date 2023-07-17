---
title: 'Data Manipulation Part 1: dplyr'
output: 
  html_document: 
    keep_md: yes
---

`dplyr` is an [R package](https://cran.r-project.org/web/packages/dplyr/index.html) written
by [Hadley Wickham](http://had.co.nz/). It makes data manipulation of data frames easier and quicker.

This tutorial will cover the following functions in the `dplyr` package:

- `select()`, selecting columns
- `arrange()`, reordering rows
- `filter()`, filtering rows
- `summarise()`, summarizing rows


```r
library(dplyr)
```

We will be using the `chicago_aqs` data set from the `region5air` package. It is
a data frame of Chicago air monitoring data from [AQS](https://aqs.epa.gov/aqsweb/airdata/download_files.html).


```r
library(region5air)
data(chicago_aqs)
```

For each function we will review how to accomplish the task in base R, then see
how the dplyr function accomplishes the same task.

# Select columns with select() 

If we wanted to select a few columns from `chicago_aqs`, we would need to either
use numbers or a vector of names on the right side of the comma using square brackets
`[ , ]`.



```r
p <- chicago_aqs[, c("Site_Number", "Parameter_Name", "Date_Local", "First_Maximum_Value")]

#equivalently
p <- chicago_aqs[, c(3, 9, 12, 23)]

head(p, 3)
```

```
## # A tibble: 3 × 4
##   Site_Number Parameter_Name         Date_Local First_Maximum_Value
##         <int> <chr>                  <chr>                    <dbl>
## 1        4002 Nitrogen dioxide (NO2) 2021-02-06                19.1
## 2        4002 Nitrogen dioxide (NO2) 2021-02-07                28.7
## 3        4002 Nitrogen dioxide (NO2) 2021-02-08                51.2
```

With the `select()` function, you can provide the names of the columns unquoted.



```r
p <- select(chicago_aqs, Site_Number, Parameter_Name, Date_Local, First_Maximum_Value)
head(p, 3)
```

```
## # A tibble: 3 × 4
##   Site_Number Parameter_Name         Date_Local First_Maximum_Value
##         <int> <chr>                  <chr>                    <dbl>
## 1        4002 Nitrogen dioxide (NO2) 2021-02-06                19.1
## 2        4002 Nitrogen dioxide (NO2) 2021-02-07                28.7
## 3        4002 Nitrogen dioxide (NO2) 2021-02-08                51.2
```

You can also select consecutive columns by separating the first column and the 
last column with a colon.


```r
p <- select(chicago_aqs, Site_Number:Longitude)
head(p, 3)
```

```
## # A tibble: 3 × 5
##   Site_Number Parameter_Code   POC Latitude Longitude
##         <int>          <int> <int>    <dbl>     <dbl>
## 1        4002          42602     1     41.9     -87.8
## 2        4002          42602     1     41.9     -87.8
## 3        4002          42602     1     41.9     -87.8
```

# Arrange rows with arrange()

If we wanted to arrange `chicago_aqs` by first ordering by `Site_Number` then 
ordering chronologically, we would need to use the `order()` function in 
base R. The output of the `order()` function is a vector of integers, and it's
placed on the left side of the comma using the square brackets `[ , ]`.


```r
ordered <- chicago_aqs[order(chicago_aqs$Site_Number, chicago_aqs$Date_Local), ]
```

The `arrange()` function in `dplyr` allows you to order a data frame by just 
adding the column names as parameters. Use `desc()` to arrange in descending order.


```r
ordered <- arrange(chicago_aqs, desc(Site_Number), Date_Local)
```

# Filter rows with filter()

To filter a data frame in base R we use a logical vector on the left side of the 
comma using the square brackets. For example, if we wanted to filter `chicago_aqs`
by parameter code and POC, we could do this:


```r
logical_vector <- chicago_aqs$Parameter_Code == 42401 & chicago_aqs$POC == 1
filtered <- chicago_aqs[logical_vector, ]
dim(filtered)
```

```
## [1] 363  34
```

The `filter()` function in `dplyr` takes logical expressions as parameters (commas
are equivalent to `&`).


```r
filtered <- filter(chicago_aqs, Parameter_Code == 42401, POC == 1)
dim(filtered)
```

```
## [1] 363  34
```

# summarise rows with group_by() and summarise()

Suppose we wanted to summarise the `chicago_aqs` data frame by finding the maximum
hourly value for each parameter. In base R, we can summarise by using the `tapply()`
function (see `?tapply()`). 



```r
max_value <- tapply(chicago_aqs$First_Maximum_Value, chicago_aqs$Parameter_Name, max)
head(max_value, 3)
```

```
## Nitrogen dioxide (NO2)         PM2.5 Raw Data         Sulfur dioxide 
##                   69.1                  182.3                   11.9
```


`dplyr` accomplishes this task by allowing you to use data frames and their column
names. The first step is to use the `group_by()` function to pick the columns that
will be factors (groups will be created by the levels of these columns).


```r
parameters <- group_by(chicago_aqs, Parameter_Name)
```

The `summarise()` function will apply the `max()` function to each group in the 
`Parameter_Name` column.


```r
summarise(parameters, max_value = max(First_Maximum_Value))
```

```
## # A tibble: 3 × 2
##   Parameter_Name         max_value
##   <chr>                      <dbl>
## 1 Nitrogen dioxide (NO2)      69.1
## 2 PM2.5 Raw Data             182. 
## 3 Sulfur dioxide              11.9
```


# Using pipes 

`dplyr` and most [tidyverse packages](https://www.tidyverse.org/packages/) are
meant to work with the pipe operator. There are now two pipes you can use in R:

- The `%>%` pipe from the [magrittr package](https://magrittr.tidyverse.org/)
- The `|>` pipe, available in base R starting with version 4.1.0

The purpose of the pipe is to allow your code to flow from one function to the 
next, without saving intermediate objects. The tidyverse packages are designed
to have functions that always take a data frame as the first argument, so they
can be chained together using the pipe.

For example, the `group_by()` and `summarise` functions are often used with the 
pipe. Our example above was this code:


```r
parameters <- group_by(chicago_aqs, Parameter_Name)

summarise(parameters, max_value = max(First_Maximum_Value))
```

```
## # A tibble: 3 × 2
##   Parameter_Name         max_value
##   <chr>                      <dbl>
## 1 Nitrogen dioxide (NO2)      69.1
## 2 PM2.5 Raw Data             182. 
## 3 Sulfur dioxide              11.9
```

The `parameters` data frame is just a place-holder data frame with no other 
purpose than to provide the first parameter value in the `summarise()`
function. Using the pipe:


```r
group_by(chicago_aqs, Parameter_Name) %>%
  summarise(max_value = max(First_Maximum_Value))
```

```
## # A tibble: 3 × 2
##   Parameter_Name         max_value
##   <chr>                      <dbl>
## 1 Nitrogen dioxide (NO2)      69.1
## 2 PM2.5 Raw Data             182. 
## 3 Sulfur dioxide              11.9
```

The output of the `group_by()` function is a data frame that is piped down to the 
next line and used as the first parameter of the `summarise()` function.

The generalized operation is:

- `x %>% f(y, .)` is equivalent to `f(y, x)`
- `x %>% f(y, z = .)` is equivalent to `f(y, z = x)`

Pipes may be difficult to grasp at first, but you may want to use them for these 
reasons:

- Pipes encourage you to think and write functionally from left to right as 
  opposed to inside out (nested function calls)
- Pipes reduce the need for intermediate variables
- Additional `tidyverse` operations can easily be added at any point in the chain
  of piped functions
- You will be `tidyverse` literate when searching for help online--many 
  answers on Stack Overflow will include code with pipes


# Additional comments on `dplyr` 

- Some functions don't appear to be that much easier to use than base R (like
  `select()` or `arrange()`). But `dplyr` provides a suite of functions with the 
  same syntax so that you can easily remember them. 
- `dplyr` is fast.
- You can use `dplyr` with databases.

