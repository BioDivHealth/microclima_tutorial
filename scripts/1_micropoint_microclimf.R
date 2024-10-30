# Micropoint Tutorial #

# 1. Install packages ----
require(devtools) # to install from github repos
install_github("ilyamaclean/micropoint")
install_github("ilyamaclean/microclimf")

# install these dependencies if necessary 
#require(stats)
#require(Rcpp)

# load libraries
library(micropoint)
library(microclimf)
library(terra)

# 2. Read in and examine data ----
head(climdata) # this is an inbuilt dataset from the microclim packages
?groundparams # examine groundparam variables in the help window
?forestparams # examine forestparam variables in the help window
?soilparams # examine soilparam variables in the help window

# example: setting vegetation parameters to a set canopy height of your choosing
myvegparams <- forestparams
myvegparams$h <- 10 # change height to 10 m

# 3. Run a MICROPOINT model for Epping Forest ----
# call micropoint model and set parameters
# find more parameters to use by running ??runpointmodel
epping_point <- micropoint::runpointmodel(climdata, reqhgt = 1, forestparams, paii = NA,  
                                  groundparams, lat = 51.668431, long= 0.059040, n = 20) # 20-layer canopy model for your coords

# extract time data to plot
tme <- as.POSIXct(climdata$obs_time)

# plot time series of air temperature for microclimate data
plot(epping_point$tair ~ tme, type="l", xlab = "Month", ylab = "Air temperature",
     ylim = c(-5, 30), col = "purple")   # microclimate

# plot air temperature for hottest hour at different heights for epping forest
epping_hot_air <- plotprofile(climdata, hr = 4094, "tair", forestparams, paii = NA, 
                  groundparams, lat = 51.668431, long= 0.059040)

# plot leaf temperature for hottest hour for epping forest
epping_hot_leaf <- plotprofile(climdata, hr = 4094, "tleaf", forestparams, paii = NA, 
                 groundparams, lat = 51.668431, long= 0.059040)


# 4. Run a MICROCLIMF model for an inbuilt dataset (dtmcaerth - a SpatRaster) ----
detach(package:micropoint, unload = TRUE)  # remove micropoint to avoid name conflicts
#devtools::install_github("ilyamaclean/microclimf")
library(microclimf)

# run point microclimate model built into microclimf with inbuilt datasets (takes ~ 5 seconds)
micropoint <- runpointmodel(climdata, reqhgt = 0.05, dtmcaerth, vegp, soilc)

# subset point model outputs for all hours in warmest day of each month
micropoint <- subsetpointmodel(micropoint, tstep = "month", what = "tmax")
head(micropoint$weather) 

# run model 5 cm above ground with subset values (takes ~10 seconds)
plot(rast(dtmcaerth))

# Note here - monthly valued are supplied. Ask Ilya about this 
mout <- runmicro(micropoint, reqhgt = 0.05, vegp, soilc, dtmcaerth)
attributes(mout)

# Plot air temperatures on hottest hour in 
# micropoint (2017-06-20 13:00:00 UTC)
mypal <- colorRampPalette(c("darkblue", "blue", "green", "yellow", 
                            "orange",  "red"))(255)
plot(rast(mout$Tz[,,134]), col = mypal, range = c(20, 48))
# Note that darker areas correspond to shaded areas:
plot(rast(vegp$pai)[[5]])




















