# Microclima tutorial #

# 1 - Load packages  ----
# Download NicheMapR (for macroclimate data) and MicroClima (for modelling) packages
install.packages("devtools")
devtools::install_github("ilyamaclean/microclima")
devtools::install_github('mrke/NicheMapR')
"rgdal_show_exportToProj4_warnings"="none"
# The below packages may be necessary if you're hitting an installation wall 
#install.packages(c(' terra', ' elevatr', 'dplyr', 'RNCEP', 'zoo', 'devtools',
#    'ncdf4', 'fields', 'Rcpp', 'sf')) 

# load libraries
library(readxl)
library(tidyverse) 
library(raster) 
library(microclima)
library(NicheMapR)
library(sp)
library(sf)
library(terra)
library(elevatr)

# 2 - Load  GPS  data ----
# read in GPS point data - insert your own here
# read in GPS point data from xlsx file
hyde_coords <- read_excel("data/hyde_park_points.xlsx")
str(hyde_coords)

# 3 - Run Microclima model ----
#download global climates dataset from NichemapT 
#(only run if not downloaded onto computer! huge file so only need to do it once)
get.global.climate()

# extract lon and lat from coords file (alter to fit your own data)
coordinates(hyde_coords) <- c("lon", "lat") 
proj4string(hyde_coords) <- CRS("+proj=longlat +datum=WGS84")
xy <-spTransform(hyde_coords,CRS= "+proj=utm +zone=7 +datum=WGS84 +units=m +no_defs")

# check extents
xy 

# 4 - Microclima Auto DEM ----
# download raster for hydepark from Mapzen 
hyde_auto_dem <- get_elev_raster(locations = xy,
                                prj = "+proj=utm +zone=7 +datum=WGS84 +units=m +no_defs",
                                z = 14,  clip = "tile")

# turn DEM into dataframe
hyde_dem_df <- data.frame(coordinates(hyde_auto_dem),
                              elevation = getValues(hyde_auto_dem))

# overlay DEM and GPS points to check they align 
plot(hyde_auto_dem)
points(xy)

# Plot elevation data
ggplot(hyde_dem_df, aes(x = x,
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
# In this case it is hourly predictions over a day at 0cm above the surface in urban environment

hyde_auto_dem <- rast(hyde_auto_dem)  # convert to terra SpatRaster object 

hyde_surf <- runauto(r = hyde_auto_dem,
                    dstart = "01/09/2022",
                    dfinish = "02/09/2022",
                    hgt = 0, # 0cm aka surface temperature
                    l = NA, 
                    x = NA,
                    habitat = "Urban and built-up", 
                    r.is.dem = TRUE,
                    coastal = FALSE,
                    summarydata = TRUE,
                    plot.progress = FALSE)

# extract mean surface temperature data 
hyde_surf_mean <- hyde_surf$tmean   

# plot surface temperature mean data with gps points to check they align 
plot(hyde_surf_mean)
points(xy)

# create tiff of full pixel model - save to your own filepath!
terra::writeRaster(hyde_surf_mean, 'data/sep_hyde_surf_mean.tif', 
                   filetype = 'GTiff', 
                   overwrite = TRUE)
 
# read it in at a later occasion
#hyde_surf_mean <- terra::rast("data/sep_hyde_surf_mean.tif")


# 5: Optional: Interactive 3D plot ----
require(plotly)
zrange<-list(range = c(0, 30)) # adjust these to suit your visualation - by metres elev
xrange<-list(range = c(700, 0))
yrange<-list(range = c(500, 0)) 

fig <- plot_ly(z = ~is_raster(hyde_auto_dem)) %>%
  add_surface(surfacecolor = ~is_raster(hyde_surf_mean)) %>%
 # layout(scene = list(zaxis = zrange)) %>% 
  layout(xaxis = list(xrange = "reversed"))  %>% 
  layout(yaxis = list(yrange = "reversed"))  %>% 
  layout(scene = list(xaxis = list(title = "Lat"), yaxis = list(title = "Lon"),
                      zaxis = list(title = "Elevation (metres a.s.l)")))

fig  
