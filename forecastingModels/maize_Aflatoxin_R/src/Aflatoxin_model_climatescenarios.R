#preprocessing function
preprocessing<-function(dat,CW_unique){ 
    colnames(dat)<-c("RUN_WINDOW","GRID_NO","YEAR","DOY","PRECIPITATION","TEMPERATURE_MIN","TEMPERATURE_MAX","RHmin","RHmax","VAPOURPRESSURE")
    
    #read in flowering and harvest data
    flo_har<-read.csv("Maize.csv",header=TRUE)
    colnames(flo_har)<-c("GRID_NO","crop_no","variety_no","start_type","start_date","start_day","start_month","flowering_data","harvest_data")
  
    #join lat long data to dat
    require("sqldf")
    dat<-sqldf("select * from dat left join CW_unique on dat.GRID_NO=CW_unique.GRID_NO")
    dat<-dat[,c("GRID_NO","LATITUDE","LONGITUDE","ALTITUDE","YEAR","DOY","TEMPERATURE_MAX","TEMPERATURE_MIN","VAPOURPRESSURE","PRECIPITATION","RHmin","RHmax")]
    
    #join flowering and harvest data to dat
    dat<-sqldf("select * from dat left join flo_har on dat.GRID_NO=flo_har.GRID_NO")
    dat<-dat[,c("GRID_NO","LATITUDE","LONGITUDE","ALTITUDE","YEAR","DOY","TEMPERATURE_MAX","TEMPERATURE_MIN","VAPOURPRESSURE","PRECIPITATION","RHmin","RHmax","start_day", "start_month","flowering_data","harvest_data")]
    
    #create column with correctly formulated start date
    dat$start_date<-NA
    lownums<-dat$start_day%in%c(1:9)
    dat$start_date[lownums]<-paste0(0,dat$start_month[lownums],0,dat$start_day[lownums])
    dat$start_date[!lownums]<-paste0(0,dat$start_month[!lownums],dat$start_day[!lownums])
    
    #convert to day of the year
    require("lubridate")
    dat$start_yday<-NA
    x<-as.Date(dat$start_date, "%m%d")
    dat$start_yday[]<-yday(x)
    dat$start_yday<-as.integer(dat$start_yday)
    
    return(dat)
}

#running the scenario analysis 
getAflatoxinScenarios<-function(dat){
  Weather_all<-dat[,c("GRID_NO","LATITUDE","LONGITUDE","YEAR","DOY","TEMPERATURE_MAX","TEMPERATURE_MIN","VAPOURPRESSURE","PRECIPITATION","RHmin","RHmax","start_yday")]
  median_startday<-median(Weather_all$start_yday,na.rm = TRUE)
  flowering_data<-dat[,c("flowering_data")]
  harvest_data <-flowering_data+dat[,c("harvest_data")]
  c="349" #15 december as day of the year
  grid= as.matrix(unique(Weather_all[,1]))
  lat<-as.matrix(unique(Weather_all[,2]))
  long<-as.matrix(unique(Weather_all[,3]))
  ARI<-matrix(0,length(grid),length(Years_modelled)+3)
  for (i in 1:length(Years_modelled)){
    Year =Years_modelled[i]
    print(i)
    sel1<-which(Weather_all[,4]==Year)
    Weather_year<-Weather_all[sel1,]
    for (ii in 1:length(grid)){
      
            #tryCatch makes sure the loop continues for grid cells where II is empty
      # which occurs when GDD is never larger than the flowering date
      tryCatch({
        
      grid_new = grid[ii,1]
      long_new<-long[ii,1]
      lat_new<-lat[ii,1]
      selection <- which(Weather_year[,1]== grid_new);
      Weather_grid<-Weather_year[selection,]
      #some Ukrain grid cells are not in flo_har, leading to NA for start_yday
      #assign median start_yday to these cells
      for(iii in 1:length(Weather_grid$start_yday)){ 
            if(is.na(Weather_grid$start_yday[iii])){Weather_grid$start_yday[iii]<-median_startday} 
            }
      Weather_start<-which(Weather_grid[,5]==Weather_grid[,12])
      Weather_end_December= which(Weather_grid[,5]==c)
      Weather = Weather_grid[Weather_start:Weather_end_December,]
      Temp_min = Weather[,7]
      Temp_max = Weather[,6]
      Rain = Weather [,9]
      RHmin = Weather[,10]
      RHmax = Weather[,11]
      RH = (RHmin+RHmax)/2
      # the future data contain the variable relative humidity already
      # therefore, we do not need to calculate this from vapour pressure
      # as is done for the baseline data
   
      Temp_mean= (Temp_min+Temp_max)/2; 
      
      ## GDD calculation - GDD accumulation was calculated from emergence of maize plant
      GDD = rep(0,length(Temp_min))
      for(iii in 1:length(Temp_min)){
        Tmin = Temp_min[iii]
        Tmax = Temp_max[iii] 
        Tbase = 6 
        Tcut = 30 # degC
        if(Tmin<Tbase){
          Tmin=Tbase
        }
        if(Tmax < Tbase){
          Tmax = Tbase
        }
        if(Tmin > Tcut){
          Tmin =Tcut
        }
        if (Tmax > Tcut){
          Tmax =Tcut
        }
        GDD[iii] = ((Tmin + Tmax)/2) - Tbase
      }
      
      GDD[1]=GDD[1] + 50 ## GDD @ emergence = 50
      GDD = cumsum(GDD)
      #          I = find(GDD < 751); 
      
      #################750 is flowering date and 1500 is flowering date + harvest date 
      ### flowering_date=750 and harvest_date= 1500 are WF variable
      II = as.numeric(which(GDD > flowering_data[ii] & GDD < harvest_data[ii]))
      
      ## Select weather from crop flowering to harvest
      Rain = Rain[II]
      RH = RH[II]
      Temp_mean= Temp_mean[II]
      
      #######################################################################################    
      # DISPERSAL
      # Spore dispersal/fungal invasion is modelled according to Battilani et al 2013
      DIS_rain = rep(0,length(Rain)) 
      DIS_RH = rep(0,length(RH))
      DIS = rep(0,length(RH))
      
      idx<-which(Rain==0)
      DIS_rain[idx]<-1    
      idx2<-which(Rain>0)
      DIS_rain[idx2]<-0
      DIS <- DIS_rain
      
      DIS_RH[which(RH<80)] <-1
      DIS_RH[which(RH>=80)] <-0
      DIS<-cbind(DIS,DIS_RH)
      DIS<-cbind(DIS,rowSums(DIS))
      DIS<-DIS[,3]
      DIS[DIS==1]<- 0
      DIS[DIS==2]<- 1
      
      ############################################################################################3    
      
      ## AFLA production according to Battilani (2013)
      # AFLA.T
      A= 4.84
      B=1.32
      C=5.59
      T_max = 47
      T_min=10
      
      AFLA = as.matrix(rep(0,length(Temp_mean)))
      
      for (jjj in 1:length(Temp_mean)){
        Temp = Temp_mean[jjj]
        
        Teq = (Temp - T_min)/(T_max-T_min)
        AFLA[jjj,1]<- (A *(Teq^B)*(1-Teq))^C
        AFLA[is.nan(AFLA)]<-0
        
      }
      
      
      ## GROWTH according to Battilani (2013)
      # GROWTH.T
      A= 5.98
      B=1.70
      C=1.43
      T_max = 48
      T_min=5
      GROWTH = as.matrix(rep(0,length(Temp_mean)))  
      
      for(kkk in 1:length(Temp_mean)){
        Temp <- Temp_mean[kkk]
        
        Teq = (Temp -T_min)/(T_max-T_min)
        GROWTH[kkk,1]<-(A*(Teq^B)*(1-Teq))^C
        GROWTH[is.nan(GROWTH)]<-0
        
      }
      ## Calculate ARI
      Aflo_risk = AFLA * GROWTH *DIS;  #* DIS(DIS is considered as non limiting factor);
      Aflo_risk_sum = sum(Aflo_risk); #sum  
      ARI[ii,i+3]<-Aflo_risk_sum
      ARI[ii,1]=grid_new #output file ARI (grid nr and risk for each year)
      ARI[ii,2]=lat_new
      ARI[ii,3]=long_new
      #ii is grid nr, i is the year
      
      #closing the tryCatch function, print error message
      }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
    }
  }
  colnames(ARI)<-c("grid_no","LATITUDE","LONGITUDE", as.character(Years_modelled))
  #fname<-paste0("ARI_",country)
  return(ARI)
}

