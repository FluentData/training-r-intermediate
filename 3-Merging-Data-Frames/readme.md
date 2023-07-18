---
title: "Merging Data Frames"
output: 
  html_document: 
    keep_md: yes
---

This tutorial will cover the following topics on how to merge data frames and
perform other database-like operations on data frames using `dplyr`. 

- Mutating joins with `inner_join()`, `left_join()`, and `full_join()`
- Filtering joins with `semi_join()` and `anti_join()`
- Manipulating individual rows with `rows_insert()`, `rows_update()`, and
  `rows_upsert()`.

For most of the joining examples we will be using the simplified versions of the 
data frames `chicago_aqs` and `aqs_paramters` from the `region5air` package.


```r
library(region5air)
library(dplyr)

data(chicago_aqs)
data(aqs_parameters)
```

The `sites` data frame will contain minimal information about each site from the
`chicago_aqs` data set.



```r
sites <- chicago_aqs %>%
  group_by(Site_Number, Parameter_Code) %>%
  summarise(Max_Value = max(First_Maximum_Value))

sites
```

```
## # A tibble: 3 × 3
## # Groups:   Site_Number [3]
##   Site_Number Parameter_Code Max_Value
##         <int>          <int>     <dbl>
## 1          76          42401      11.9
## 2        4002          42602      69.1
## 3        6005          88501     182.
```

The `parameters` data frame will contain a subset of information about criteria
gases from the `aqs_parameters` data set.


```
## # A tibble: 4 × 3
##   Parameter_Code Parameter              Standard_Units   
##            <dbl> <chr>                  <chr>            
## 1          42101 Carbon monoxide        Parts per million
## 2          42602 Nitrogen dioxide (NO2) Parts per billion
## 3          44201 Ozone                  Parts per million
## 4          42401 Sulfur dioxide         Parts per billion
```

# Mutating joins

Mutating joins are database-like joins on two data frames. This is the same concept
as joining two tables in SQL using statements like `INNER JOIN` or `LEFT JOIN`. In fact the 
function names in `dplyr` use the same terminology: `inner_join`, `full_join()`,
`left_join()`, etc. These are called mutating joins because they change the contents
of the tables being joined into some combination of the two.

Joining two data frames depends on matching the contents of values in one or more
columns that the two data frames have in common. In our example data frames, we 
see that there is a column name in common: `Parameter_Code`.


```r
colnames(sites)
```

```
## [1] "Site_Number"    "Parameter_Code" "Max_Value"
```

```r
colnames(parameters)
```

```
## [1] "Parameter_Code" "Parameter"      "Standard_Units"
```

Suppose we would like to combine these two data frames so that we only retain
the information that is common to both tables in the `Parameter_Code` columns.
We can use the `inner_join()` function to create that data frame.


```r
inner_join(sites, parameters, by = "Parameter_Code")
```

```
## # A tibble: 2 × 5
## # Groups:   Site_Number [2]
##   Site_Number Parameter_Code Max_Value Parameter              Standard_Units   
##         <int>          <dbl>     <dbl> <chr>                  <chr>            
## 1          76          42401      11.9 Sulfur dioxide         Parts per billion
## 2        4002          42602      69.1 Nitrogen dioxide (NO2) Parts per billion
```

The function takes the two data frames as the first two parameters, and the `by`
parameter takes a vector of column names to join on. The result is a data frame
with just two rows, because there are only two values in the `Paramter_Code` columns
that the two data frames share.

If we wanted to keep all of the rows in the `sites` data frame, we could use the
`left_join()` function. The data frame supplied in the first parameter will keep
all of its rows in the output.


```r
left_join(sites, parameters, by = "Parameter_Code")
```

```
## # A tibble: 3 × 5
## # Groups:   Site_Number [3]
##   Site_Number Parameter_Code Max_Value Parameter              Standard_Units   
##         <int>          <dbl>     <dbl> <chr>                  <chr>            
## 1          76          42401      11.9 Sulfur dioxide         Parts per billion
## 2        4002          42602      69.1 Nitrogen dioxide (NO2) Parts per billion
## 3        6005          88501     182.  <NA>                   <NA>
```

If we wanted to keep all of the records from both data frames in the output,
we can use the `full_join()` function.


```r
full_join(sites, parameters, by = "Parameter_Code")
```

```
## # A tibble: 5 × 5
## # Groups:   Site_Number [4]
##   Site_Number Parameter_Code Max_Value Parameter              Standard_Units   
##         <int>          <dbl>     <dbl> <chr>                  <chr>            
## 1          76          42401      11.9 Sulfur dioxide         Parts per billion
## 2        4002          42602      69.1 Nitrogen dioxide (NO2) Parts per billion
## 3        6005          88501     182.  <NA>                   <NA>             
## 4          NA          42101      NA   Carbon monoxide        Parts per million
## 5          NA          44201      NA   Ozone                  Parts per million
```

# Filtering joins

In some cases, we may not want to merge the two data frames together. But it might
be useful to limit the rows in one data frame based on the records in another
data frame. The `dplyr` functions that accomplish this are called filtering joins.

If we wanted to filter the `sites` data frame down to just the records that have
common `Parameter_Code` values in the `parameters` data frame, we could use the
`semi_join()` function.


```r
semi_join(sites, parameters, by = "Parameter_Code")
```

```
## # A tibble: 2 × 3
## # Groups:   Site_Number [2]
##   Site_Number Parameter_Code Max_Value
##         <int>          <int>     <dbl>
## 1          76          42401      11.9
## 2        4002          42602      69.1
```

Or if we only wanted to retain rows in the `sites` data frame that do not have
parameter codes in the `parameter` data frame, we could use the `anti_join()`
function.


```r
anti_join(sites, parameters, by = "Parameter_Code")
```

```
## # A tibble: 1 × 3
## # Groups:   Site_Number [1]
##   Site_Number Parameter_Code Max_Value
##         <int>          <int>     <dbl>
## 1        6005          88501      182.
```

# Manipulating individual rows

Another common database operation is updating records in a table. `dplyr` now has
functions that use the same terminology as SQL to manipulate values in an existing
data frame.

## Insert

The `rows_insert()` function will insert the rows of one data frame into another
data frame, as long as the columns of the rows being inserted exist in both data
frames. Below, we insert a new row into the `paramters` data frame.


```r
new_parameter <- data.frame(Parameter_Code = 11204, Parameter = "Smoke")

rows_insert(parameters, new_parameter, by = "Parameter_Code")
```

```
## # A tibble: 5 × 3
##   Parameter_Code Parameter              Standard_Units   
##            <dbl> <chr>                  <chr>            
## 1          42101 Carbon monoxide        Parts per million
## 2          42602 Nitrogen dioxide (NO2) Parts per billion
## 3          44201 Ozone                  Parts per million
## 4          42401 Sulfur dioxide         Parts per billion
## 5          11204 Smoke                  <NA>
```

## Update

The `rows_update()` function will update rows in a data frame based on the values
in another data frame. In the example below, we replace the `Parameter` value
"Carbon monoxide" with the value "CO".


```r
co_parameter <- data.frame(Parameter_Code = 42101, Parameter = "CO")

rows_update(parameters, co_parameter, by = "Parameter_Code")
```

```
## # A tibble: 4 × 3
##   Parameter_Code Parameter              Standard_Units   
##            <dbl> <chr>                  <chr>            
## 1          42101 CO                     Parts per million
## 2          42602 Nitrogen dioxide (NO2) Parts per billion
## 3          44201 Ozone                  Parts per million
## 4          42401 Sulfur dioxide         Parts per billion
```

## Upsert

The `rows_upsert()` function will either insert or update values in a data frame,
depending on whether or not the key value exists or not. Here we make a data frame
with a new parameter (SMOKE) and an updated name for a parameter (CO). 


```r
upsert_parameters <- data.frame(Parameter_Code = c(11204, 42101),
                                Parameter = c("Smoke", "CO"))

rows_upsert(parameters, upsert_parameters, by = "Parameter_Code")
```

```
## # A tibble: 5 × 3
##   Parameter_Code Parameter              Standard_Units   
##            <dbl> <chr>                  <chr>            
## 1          42101 CO                     Parts per million
## 2          42602 Nitrogen dioxide (NO2) Parts per billion
## 3          44201 Ozone                  Parts per million
## 4          42401 Sulfur dioxide         Parts per billion
## 5          11204 Smoke                  <NA>
```
