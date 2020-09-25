# R_PastElevationChange
R code for estimating available elevation in a lake catchment through time based on temperature lapse rates and temperature time series.

## Rationale
1. *extract and merge reconstructed temperature time series and simulations for region around Lake Naleng*
![Temperature through time](https://github.com/StefanKruse/R_PastElevationChange/blob/master/temperatures_paleo_merged.png)
Figure 1. Merged relative temperatures from the reconstructions of the last 22 kyrs.
	- simulated data from MPI-ESM-LR 2011; URL: http://svn.zmaw.de/svn/cosmos/branches/releases/mpi-esm-cmip5/src/mod; atmosphere: ECHAM6 (REV: 4619), T63L47; land: JSBACH (REV: 4619); ocean: MPIOM (REV: 4619), GR15L40; sea ice: 4619; marine bgc: HAMOCC (REV: 4619); experiment RCP4.5; parent_experiment_rip: r1i1p1
		- JSBACH: Raddatz et al., 2007. Will the tropical land biosphere dominate the climate-carbon cycle feedback during the twenty first century? Climate Dynamics, 29, 565-574, doi 10.1007/s00382-007-0247-8;  MPIOM: Marsland et al., 2003. The Max-Planck-Institute global ocean/sea ice model with orthogonal curvilinear coordinates. Ocean Modelling, 5, 91-127;  HAMOCC: http://www.mpimet.mpg.de/fileadmin/models/MPIOM/HAMOCC5.1_TECHNICAL_REPORT.pdf;
	- temperature reconstruction by
		- Shakun, J. D. et al. Global warming preceded by increasing carbon dioxide concentrations during the last deglaciation. Nature 484, 49–54 (2012).
		- Marcott, S. A., Shakun, J. D., Clark, P. U. & Mix, A. C. A Reconstruction of Regional and Global Temperature for the Past 11,300 Years. Science 339, 1198–1201 (2013).
2. *combine DEM information in lake catchment with time lapse rates to estimate catchment through time excluding areas covered by ice extents*
![Levelplot showing the number of available elevation at a certain time](https://github.com/StefanKruse/R_PastElevationChange/blob/master/naleng_available_areas_in_catchment_reduced_by_snow_cover_18-0kyrsBP.naleng_catch_90m.png)
Figure 2. Levelplot showing the number of available elevation at a certain time step.
	- Past ice extents were estimated with the numerical ice-flow model GC2D (Kessler et al., 2006). We ran simulations on the present-day topography, based on a 90-m resolution SRTM digital elevation model. Climate was imposed through a vertical mass-balance profile that we estimated from present-day conditions. Based on the spatially averaged mean elevation of present-day glaciers in the vicinity (Pfeffer et al., 2014), we estimated an equilibrium line altitude (ELA) of ~5200 m (Braithwaite, 2015). We estimated the maximum ice accumulation rate to be 0.25 m yr-1, based on different gridded precipitation data sets (HAR, Maussion et al., 2014; GPCC, Anja et al., 2011). Guided by observations from modern Tibetan Glaciers (Yuzhong et al., 2013), and by matching the present-day distribution of ice cover in the wider region of our study area, we estimated a mass balance gradient of 0.0115 m yr-1 m-1. Glacier and snow cover through time were interpolated from the corresponding △ELA based on a temperature lapse rate of 0.55°C/100m (Li et al., 2013).
		- Kessler, M. A., Anderson, R. S. & Stock, G. M. Modeling topographic and climatic control of east-west asymmetry in Sierra Nevada glacier length during the Last Glacial Maximum. J. Geophys. Res. Earth Surf. 111, (2006).
		- Pfeffer, W. T. et al. The Randolph Glacier Inventory: a globally complete inventory of glaciers. J. Glaciol. 60, 537–552 (2014).
		- Braithwaite, R. J. From Doktor Kurowski’s Schneegrenze to our modern glacier equilibrium line altitude (ELA). The Cryosphere 9, 2135–2148 (2015).
		- Maussion, F. et al. Precipitation Seasonality and Variability over the Tibetan Plateau as Resolved by the High Asia Reanalysis. J. Clim. 27, 1910–1927 (2014).
		- Anja, M.-C. et al. GPCC Climatology Version 2011 at 0.25°: Monthly Land-Surface Precipitation Climatology for Every Month and the Total Year from Rain-Gauges built on GTS-based and Historic Data. doi:10.5676/DWD_GPCC/CLIM_M_V2011_025.
		- Yuzhong, Y., Qingbai, W. & Hanbo, Y. Stable isotope variations in the ground ice of Beiluhe Basin on the Qinghai-Tibet Plateau. Quat. Int. 313–314, 85–91 (2013).
		- Li, X. et al. Near-surface air temperature lapse rates in the mainland China during 1962-2011. J. Geophys. Res. Atmospheres 118, 7505–7515 (2013).

### Version history
- 25.09.2020 added descriptions
- 24.09.2020 initial upload

### Authors
- Stefan Kruse - stefan.kruse@awi.de - Development of idea, R script implementation
- Dirk Scherler - scherler@gfz-potsdam.de - Simulation of past ice extents
- Sisi Liu - sisi.liu@awi.de - Development of idea

## Containing files
1. "PastElevationChange.r" master file including the script and explanations about input and output files 
2. "icecover_sim_tiffs.zip" geotiff files by time step of ice cover
3. "naleng_catch_30m.xxx" shapefiles and geotiffs of the estimated lake catchment