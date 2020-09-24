# code to estimate available temperatures throughout the Holocene in catchment of Lake Naleng

# ... Rationale
# A extract future time series for region around Lake Naleng
# B temperature data fusion
# C combine DEM information in lake catchment with time lapse rates to estimate catchment through time

# prerequisites
# ... set working directory to the folder with the necessary files
setwd(choose.dir())


# A extract future time series for region around Lake Naleng
	# based on http://geog.uoregon.edu/GeogR/topics/netCDF-read-ncdf4.html
	library("ncdf4")

	# set coordinate for extraction
	nalengcoordlat=31.1
	nalengcoordlon=97.75

	# set input file names
	ncfname="tas_Amon_MPI-ESM-LR_rcp45_r1i1p1_200601-210012.nc"
	ncfname=c(ncfname,"tas_Amon_MPI-ESM-LR_rcp45_r1i1p1_210101-230012.nc")
	dname <- "tas"

	# run of all input files
	yrtmp=NULL
	for(ncfnamei in 1:length(ncfname))
	{
		# open a netCDF file
		ncin <- nc_open(ncfname[ncfnamei])
		print(ncin)
			# institution: Max Planck Institute for Meteorology
			# institute_id: MPI-M
			# experiment_id: rcp45
			# source: MPI-ESM-LR 2011; URL: http://svn.zmaw.de/svn/cosmos/branches/releases/mpi-esm-cmip5/src/mod; atmosphere: ECHAM6 (REV: 4619), T63L47; land: JSBACH (REV: 4619); ocean: MPIOM (REV: 4619), GR15L40; sea ice: 4619; marine bgc: HAMOCC (REV: 4619);
			# model_id: MPI-ESM-LR
			# forcing: GHG,Oz,SD,Sl,Vl,LU
			# parent_experiment_id: historical
			# parent_experiment_rip: r1i1p1
			# branch_time: 56978
			# contact: cmip5-mpi-esm@dkrz.de
			# history: Model raw output postprocessing with modelling environment (IMDI) at DKRZ: URL: http://svn-mad.zmaw.de/svn/mad/Model/IMDI/trunk, REV: 3436 2011-07-17T14:42:03Z CMOR rewrote data to comply with CF standards and CMIP5 requirements.
			# references: ECHAM6: n/a; JSBACH: Raddatz et al., 2007. Will the tropical land biosphere dominate the climate-carbon cycle feedback during the twenty first century? Climate Dynamics, 29, 565-574, doi 10.1007/s00382-007-0247-8;  MPIOM: Marsland et al., 2003. The Max-Planck-Institute global ocean/sea ice model with orthogonal curvilinear coordinates. Ocean Modelling, 5, 91-127;  HAMOCC: http://www.mpimet.mpg.de/fileadmin/models/MPIOM/HAMOCC5.1_TECHNICAL_REPORT.pdf;
			# initialization_method: 1
			# physics_version: 1
			# tracking_id: 8a91cca7-07e6-4c1f-a7d7-9631d65f5d9b
			# product: output
			# experiment: RCP4.5
			# frequency: mon
			# creation_date: 2011-07-17T14:42:11Z
			# Conventions: CF-1.4
			# project_id: CMIP5
			# table_id: Table Amon (27 April 2011) a5a1c518f52ae340313ba0aada03f862
			# title: MPI-ESM-LR model output prepared for CMIP5 RCP4.5
			# parent_experiment: historical
			# modeling_realm: atmos
			# realization: 1
			# cmor_version: 2.5.9
		# extract relevant information
			lon <- ncvar_get(ncin,"lon")
			nlon <- dim(lon)
			lat <- ncvar_get(ncin,"lat",verbose=F)
			nlat <- dim(lat)

			tyr=list(sort(rep(2006:2100,12)),sort(rep(2101:2300,12)))

			tmp_array <- ncvar_get(ncin,dname)
			dlname <- ncatt_get(ncin,dname,"long_name")
			dunits <- ncatt_get(ncin,dname,"units")
			fillvalue <- ncatt_get(ncin,dname,"_FillValue")
			dim(tmp_array)

		# subselect for ROI
			windowwid=5
			lonselect=which(lon>(nalengcoordlon-windowwid) & lon<(nalengcoordlon+windowwid))
			latselect=which(lat>(nalengcoordlat-windowwid) & lat<(nalengcoordlat+windowwid))

		# extract data
			for(yri in unique(tyr[[ncfnamei]]))
			{
				yrtmp=rbind(yrtmp,data.frame(YR=yri, TAS=mean(as.vector(tmp_array[lonselect,latselect,which(tyr[[ncfnamei]]==yri)]))-273.15))
			}
		
		nc_close(ncin)
	}

	# check data
		plot(yrtmp,col="red",type="b")

	# save data of individual years
		yrtmp$RCP=4.5
		str(yrtmp)
		write.csv2(yrtmp,"tas.yrtmp.2006-2300.csv",row.names=FALSE)

	# loess estimate in 50yr bins
		yrint=c(2006,seq(2050,2300,50))
		tmptr_rel=as.data.frame(cbind(RCP=4.5,t(predict(with(yrtmp[yrtmp$RCP==4.5,],loess(TAS~YR,control = loess.control(surface = "direct"))),newdata=yrint)-predict(with(yrtmp[yrtmp$RCP==4.5,],loess(TAS~YR,control = loess.control(surface = "direct"))),newdata=yrint)[1])))
		names(tmptr_rel)[2:dim(tmptr_rel)[2]]=yrint
		tmptr_rel

		write.csv2(tmptr_rel,"tas.tmptr_rel.2006-2300.csv",row.names=FALSE)


# B temperature data fusion
	# read temperature reconstructions 
	# ... 22-6.5 kyr BP, Shakun, J. D. et al. Global warming preceded by increasing carbon dioxide concentrations during the last deglaciation. Nature 484, 49–54 (2012).
	# ... 12-0 kyr BP, Marcott, S. A., Shakun, J. D., Clark, P. U. & Mix, A. C. A Reconstruction of Regional and Global Temperature for the Past 11,300 Years. Science 339, 1198–1201 (2013).
		temp=read.csv2("paleo_temperatures.csv", stringsAsFactors=TRUE)
		str(temp)
		# with(temp, plot(Temp~AgeBP1950, col=c("blue","orange")[Source]))
		# legend("topright", c("Marcott","Shakun"), pch=1, col=c("blue","orange"))
		
	# align temperatures
	# ... (a) overlap of Shakun to Marcott
	# ... (b) cut Shakun
		ts=temp[temp$Source=="Shakun",]$AgeBP1950
		tm=temp[temp$Source=="Marcott",]$AgeBP1950
		ovlp_min=min(ts)
		ovlp_max=max(tm)
		mean_s=mean(temp[temp$AgeBP1950>=ovlp_min & temp$AgeBP1950<=ovlp_max & temp$Source=="Shakun",]$Temp)
		mean_m=mean(temp[temp$AgeBP1950>=ovlp_min & temp$AgeBP1950<=ovlp_max & temp$Source=="Marcott",]$Temp)
		diff_sm=mean_m-mean_s
		temp[temp$Source=="Shakun",]$Temp=temp[temp$Source=="Shakun",]$Temp+diff_sm
		# with(temp, plot(Temp~AgeBP1950, col=c("blue","orange")[Source], type="n"))
			# with(temp[temp$Source=="Marcott",], lines(Temp~AgeBP1950, col=c("blue","orange")[Source], lwd=3))
			# with(temp[temp$Source=="Shakun",], lines(Temp~AgeBP1950, col=c("blue","orange")[Source], lwd=3))
			# abline(v=c(ovlp_min,ovlp_max),lty=2)
		tex=temp[(temp$Source=="Shakun" & temp$AgeBP1950>ovlp_max) | temp$Source=="Marcott",]
	
		tagg=with(tex, aggregate(Temp, list(AgeBP1950), function(x)mean(na.omit(x))))
		names(tagg)=c("yr", "tr")# age in bp1950 and temp as relative to present
		
		# exclude NAN of Marcott yr{negative} yr0==0
		# reformat to AgeBP2000
		tagg$yr=tagg$yr
		tagg=rbind(data.frame(yr=-50,tr=0),tagg)
		tagg=tagg[!is.na(tagg$tr),]
		str(tagg)

		png("temperatures_paleo_merged.png")
			with(tagg, plot(tr~yr, type="l",lwd=2,col="red"))
		dev.off()
	
	# add future series
	# ... we consider the difference of 2006 starting year and 2000 final year of reconstruction as neglectable
		tmptr_rel=read.csv2("tas.tmptr_rel.2006-2300.csv")
		str(tmptr_rel)

		tyrdf=rbind(data.frame(yr=rev(-1*(as.numeric(gsub("X","",names(tmptr_rel[ii,3:dim(tmptr_rel)[2]])))-1950)),	tr=rev(unlist(tmptr_rel[ii,3:dim(tmptr_rel)[2]]))),tagg)
		str(tyrdf)
		
		write.csv2(tyrdf, "tempRCP45_FINAL_complete.csv",row.names=FALSE)

	# extract temperature every 500 yrs from 18000 until 0
		# linear interpolation
		intyears=c(seq(0,18000,500))
		trinter=with(tyrdf, approx(x=yr,y=tr, xout=intyears))$y
		tmpsim500yrs_lininter=data.frame(yr=intyears,  tr=trinter)
		
		with(tyrdf, plot(x=yr,y=tr, type="l"))
		with(tmpsim500yrs_lininter, points(x=yr,y=tr, col="red", pch=2))
		
		write.csv2(tmpsim500yrs_lininter, "tempRCP45_only500yrsteps_linearinterpolated.csv",row.names=FALSE)


# C combine DEM information in lake catchment with time lapse rates to estimate catchment through time
	# read temperature data
		tmpsim500yrs_lininter=read.csv2(paste0("tempRCP45_only500yrsteps_linearinterpolated.csv"))
		str(tmpsim500yrs_lininter)

	# read distribution of DEM tiles of 90 m spatial resolution in catchment
	# ... catchment was delineated in QGIS file:///C:/StefanKruseData/_Betreuung/Sisi%20Liu/NatureCommAreaChange/Catchment%20delineation%20with%20QGIS%20%E2%80%93%20GeoGeek.htm based on 30 m-downsampled 90 m SRTM data ./naleng_ice_model_dem90m.tif => naleng_ice_model_demresampled30m.tif & ./naleng_catch_30m.shp and further files & 
		demall=read.csv2("naleng_dem_allvaluesincatchment.naleng_catch_90m.csv")$x
		str(demall)			

	# read 18000-6500 yrs BP available DEM tiles of 90 m spatial resolution in catchment
		# ... masking area with available glacial and permanent snow cover in ./icecover_sim_tiffs.zip
		load(file=paste0("icecoverout.yearwise_available_dem.","naleng_catch_90m",".RDATA"))
		str(icecoverout)
		# ... colnames == years BP

	# calculate temperature at 100 m DEM bins and estimate for past excluding areas covered by snow
		# ... temperature lapse rate is 0.0055°C/m provided by Dirk Scherler
		lapse=0.0055
		Tsealevel=50 # relative variable set to 50 to avoid negative values
		demlevel=seq(1000,6000,100)
		brkst=(Tsealevel)-(demlevel*lapse)
		demtdf=data.frame(Ele=demlevel, Tmp=brkst)
		demintime=matrix(NA, ncol=length(tmpsim500yrs_lininter$yr), nrow=length(brkst)-1)
		rownames(demintime)=rev(demlevel)[-1]
		colnames(demintime)=unique(tmpsim500yrs_lininter$yr)
		for(ti in unique(tmpsim500yrs_lininter$yr))
		{
			demin=demall
			if(length(icecoverout[[as.character(ti)]])>0)# if some area is covered by ice
			{
				demin=icecoverout[[as.character(ti)]]
			}
			hi=hist((Tsealevel+tmpsim500yrs_lininter[tmpsim500yrs_lininter$yr==ti,]$tr)-(demin*lapse), breaks=brkst, plot=FALSE)
			demintime[,as.character(ti)]=hi$counts
		}

		library(lattice)
			lplti=levelplot(t(demintime)[,dim(demintime)[1]:1], scales=list(y=list(rot=45), x=list(rot=45)), col.regions=colorRampPalette(c("gray90","blue","yellow")), main="available areas in catchment\nreduced by snow cover")
		pdf("naleng_available_areas_in_catchment_reduced_by_snow_cover_18-0kyrsBP.naleng_catch_90m.pdf")
			print(lplti)
		dev.off()

		write.csv2(as.data.frame(demintime), "temperature_dem_in_time_icefree.naleng_catch_90m.csv")

	# calculate total cover possible
		demtdf=data.frame(Ele=demlevel, Tmp=brkst)
		demintime_total=matrix(NA, ncol=length(unique(tmpsim500yrs_lininter$yr)), nrow=length(brkst)-1)
		rownames(demintime_total)=rev(demlevel)[-1]
		colnames(demintime_total)=unique(tmpsim500yrs_lininter$yr)
		for(ti in unique(tmpsim500yrs_lininter$yr))
		{
			demin=demall
			hi=hist((Tsealevel+tmpsim500yrs_lininter[tmpsim500yrs_lininter$yr==ti,]$tr)-(demin*lapse), breaks=brkst, plot=FALSE)
			demintime_total[,as.character(ti)]=hi$counts
		}

		lplti=levelplot(t(demintime_total)[,dim(demintime_total)[1]:1], scales=list(y=list(rot=45), x=list(rot=45)), col.regions=colorRampPalette(c("gray90","blue","yellow")), main="available areas in catchment")
		pdf("naleng_available_areas_in_catchment_total.naleng_catch_90m.pdf")
			print(lplti)
		dev.off()

		write.csv2(as.data.frame(demintime_total), "temperature_dem_in_time_total.naleng_catch_90m.csv")