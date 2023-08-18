---
title: "Space-Time Data Objects"
output: html_document
---

In a previous tutorial, we learned how to create `Spatial*` objects using the 
`sp` package. Those objects contained information about points in space, but
they didn't contain any information about those points over time. In this 
tutorial we'll learn how to create an `ST*` object using the `spacetime` package. 
We'll also learn how to feed that object into other functions for interpolation
and vizualization.

- [`ST*` objects](#ST)
- [Plotting](#plotting)
- [Interpolation](#interpolation)

# `ST*` objects{#ST}

In the tutorial on the `sp` package we learned how to create a very simple `Spatial`
object, and then learned how to build on that object to create a `SpatialPoints` object
and a `SpatialPointsDataFrame`. And there are many other `Spatial*` objects you can
create, such as `SpatialLines` and `SpatialGrid`.

The `spacetime` package also has a fundamental object that is the basis for more
complicated objects. The `ST` object simply contains information about the spatial
nature of the object (basically the same information contained in a `SpatialPoints` object)
and information about the time frame for the object. The object is created using the
`ST()` function. Below is a simple object representing two points in space over two
time intervals.

```{r, warning=FALSE}
library(sp)
library(spacetime)
dates <- as.Date('2008-01-01')+1:2
dates
my_matrix <- cbind(c(0,1),c(0,1))
my_matrix
spatial_points <- SpatialPoints(my_matrix)
ST(sp = spatial_points, time = dates, endTime = delta(dates))
```

The `delta()` function finds the `endTime` for regularly spaced time intervals. In this
case the time interval is a full day, so the slot "endTime" shows that the end time
for 2008-01-02 is 2008-01-03, and the end time for 2008-01-03 is 2008-01-04. 

The `ST` object is the basis of more complicated objects that represent space and time
data in a full grid layout (`STF` objects), a sparse grid layout (`STS` objects), an
irregular layout (`STI` objects), and a trajectory layout (`STT` objects). We will only
learn about the `STF` layout in this tutorial, because it is the most useful for monitoring
data.

We will use a subset of the `airdata` dataset to show how to construct an 
`STFDF` object, which stands for a **S**pace **T**ime **F**ull-grid-layout **D**ata **F**rame.

First we subset down to 3 monitors and 4 time points for 1 hour ozone.

```{r, warning=FALSE, message=FALSE}
library(region5air)
library(dplyr)

data(airdata)
as.tbl(airdata)
# make POSIXct time column
airdata$datetime <- as.POSIXct(airdata$datetime, tz = "US/Central",
                               format = "%Y%m%dT%H%M")
# subset down to ozone and three monitors
monitors <- unique(airdata$site)[1:3]
air <- filter(airdata, parameter == 44201, site %in% monitors)
# filter down to the minimum poc
air <- group_by(air, site, datetime)
air <- filter(air, poc == min(poc))
# filter down to 4 hours on June 1, 2013
min_time <- as.POSIXct("2013-06-01 11:00:00", tz = "US/Central")
max_time <- as.POSIXct("2013-06-01 14:00:00", tz = "US/Central")
air <- filter(air, datetime >= min_time, datetime <= max_time)
air <- select(air, site, datetime, value, lon, lat, GISDatum)
air
```

Now we make an `STFDF` object using the `stConstruct()` function.

```{r}
# the class for air must be data.frame
air <- as.data.frame(air)
airSTFDF <- stConstruct(air, space = c("lon", "lat"),
                        time = "datetime",
                        crs = CRS("+proj=longlat +ellpsWGS84"))
airSTFDF
```

If you don't supply anything for the argument `endTime` in 
`stConstruct()` then it's assumed that the these are time
instances and not durations.
