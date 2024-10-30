# MicroClima Tutorial - NHM November 6th 2024

## Overview 

Microclima is an R package developed by Ilya Maclean that downscales gridded climate data and models fine-scale local variations in temperature. The model pulls in data on coastal proximity, radiation, IUCN habitat type, radiation, wind speed, elevation, albedo and frost hours. There are various spin-off packages in what I refer to as the 'MicroClima Multiverse'. We'll focus on these three:

  1) **MicroClima**: The original model. You can either load your own DEM or choose a location and have a DEM imported online from MapZen. You can run for any time period and the output will give you a raster map with microclimate variables at the height from surface you have selected. 
  2) **MicroPoints**: This is similar to microclima but allows you to run microclimate models for discrete points, and therefore runs a lot more efficiently. You can easily get microclimate time series data from this package. 
  3) **MicroClimF**: This is similar to microclima (i.e. you can model spatial climate 'grids' but it specialises in below-canopy and below-ground. It also allows you to customise more based on canopy characteristics / leaf foliage density / vegetation height etc. 

## Scripts 

1) [1_micropoint_microclimf.R](https://github.com/BioDivHealth/microclima_tutorial/blob/main/scripts/1_micropoint_microclimf.R) Adapted from the MEB2024 Conference workshop in Helsinki. Shows you how to run microclimate chronologies for discrete points (example: Epping Forest) and run a gridded MicroClimF model for the inbuilt example data (somewhere in Cornwall I think?)
2) [2_microclima_example.R](https://github.com/BioDivHealth/microclima_tutorial/blob/main/scripts/2_microclima_example.R) Code to import coordinate data (exmaple: Hyde Park), run a full microclima model, extract microclimate surface temperature means, save raster output, and plot the model output.  

