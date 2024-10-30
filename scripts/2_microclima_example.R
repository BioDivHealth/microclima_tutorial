# Microclima tutorial #


# 1 - Load packages  ----

install.packages(c(' terra', ' elevatr', 'dplyr', 'RNCEP', 'zoo', 'devtools',
                   'ncdf4', 'fields', 'Rcpp', 'sf')) 


install.packages("devtools")
devtools::install_github("ilyamaclean/microclima")
library(microclima)

devtools::install_github('mrke/NicheMapR')
"rgdal_show_exportToProj4_warnings"="none"

library(readr)
library(readxl)
library(tidyverse) 
library(raster) 
library(microclima)
library(NicheMapR)
library(sp)
library(sf)
library(rgdal)
library(rgeos)
library(maptools)
library(terra)
library(elevatr)


# find out r version
R.Version()$version.string

#### 2 - LOAD  GPS  DATA ----
# read in GPS point data - insert your own here
tomst_coords <- read_xlsx("filepath/example/points.xlsx")
str(tomst_coords)

####  3 - RUN MODEL ----
#download global climates dataset from nichemapr (only run if not downloaded onto computer! huge file)
get.global.climate()


# extract lon and lat from tomst coords (alter to fit your own data)
xy <- tomst_coords[,c(2,5,6)]
xy <- na.omit(xy)
str(xy) 
coordinates(xy) <- c("Lon", "Lat") 
proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")
xy <-spTransform(xy,CRS= "+proj=utm +zone=7 +datum=WGS84 +units=m +no_defs")

# check extents
xy 

#### 4 - Microclima Auto DEM ----
# download raster for QHI from Mapzen 
qhi_auto_dem <- get_elev_raster(locations = xy,
                                prj = "+proj=utm +zone=7 +datum=WGS84 +units=m +no_defs",
                                z = 13,  clip = "tile")

# turn dem into dataframe
herschel_dem_df <- data.frame(coordinates(qhi_auto_dem),
                              elevation = getValues(qhi_auto_dem))

# plot dem and gps points to check they align 
plot(qhi_auto_dem)
points(xy)

# Plot elevation data
ggplot(herschel_dem_df, aes(x = x,
                            y = y,
                            fill = elevation)) +
  geom_raster() +
  scale_fill_gradientn(colours = rev(terrain.colors(10)),
                       name = "Elevation (m)") +
  xlab("Longitude") +
  ylab("Latitude") +
  coord_equal() +
  theme_minimal() %+replace%
  theme(axis.text = element_text(angle = 45, size = 8))

# Microclimate model: alter to your own specifications here to include your date range, surface, habitat etc
# In this case it is hourly predictions over a month at 0cm above the surface in an open shrubland
qhi_surf <- runauto(r = qhi_auto_dem,
                    dstart = "01/09/2022",
                    dfinish = "30/09/2022",
                    hgt = 0, # 0cm aka surface temperature
                    l = NA,
                    x = NA,
                    habitat = "Open shrublands", 
                    r.is.dem = TRUE,
                    coastal = FALSE,
                    summarydata = TRUE,
                    plot.progress = FALSE)

# save mean data
qhi_surf_mean <- qhi_surf$tmean   

# plot mean data with gps points to check they align 
plot(qhi_surf_mean)
points(xy)


# create tiff of full pixel model - save to your own filepath!
raster::writeRaster(qhi_surf_mean, 'filepath/example/sep_qhi_surf_mean.tif', 
                    format = 'GTiff', 
                    overwrite = TRUE)

qhi_surf_mean <- raster('filepath/example/sep_qhi_surf_mean.tif')


#### 5: OPTIONAL: Interactive 3D plot ----
require(plotly)
zrange<-list(range = c(0, 500))
xrange<-list(range = c(700, 0))
yrange<-list(range = c(500, 0)) 

fig <- plot_ly(z = ~is_raster(qhi_auto_dem)) %>%
  add_surface(surfacecolor = ~is_raster(qhi_surf_mean)) %>%
  layout(scene = list(zaxis = zrange)) %>% 
  layout(xaxis = list(xrange = "reversed"))  %>% 
  layout(yaxis = list(yrange = "reversed"))  %>% 
  layout(scene = list(xaxis = list(title = "Lat"), yaxis = list(title = "Lon"),
                      zaxis = list(title = "Elevation (metres a.s.l)")))

fig  
