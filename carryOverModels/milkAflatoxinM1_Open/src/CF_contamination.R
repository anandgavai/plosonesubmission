CF_contamination <- function (Cont_scenario,nruns,maizePred){
  
  ## mean and standard deviation of afb1 contamination in ingredients 
  ## mean and stdev data were generated on log10(contamination +1)
  
    maize<-maizePred #from the forecasting model
    
    wheat<-c(0.0056,0.04263) 
    barley<-c(0.0045,0.03995)
    #maize<- c(0.0535,0.21028)
    triticale<-c(0.0193,0.09439)
    rye<-c(0,0)
    soyabean_meal<-c(0.0106,0.06064)
    sunflower_seed_meal<-c(0.2127,0.28587)
    palm_kernel<- c(0.0453,0.20801) 
    rapeseed_meal<- c(0,0)
    corn_gluten_feed<- c(0.0906,0.19935)  
    flour<-c(0,0)         
    dried_beed_pulp<- c(0,0) 
    citrus_pulp<-c(0.0061,0.04653)
    molasses<-c(0,0)      
    
    Mean_cont_stdev<-rbind(wheat,barley,maize,triticale,rye,soyabean_meal,sunflower_seed_meal,
                           palm_kernel,rapeseed_meal,corn_gluten_feed,flour,dried_beed_pulp,
                           citrus_pulp,molasses)    
    
    colnames(Mean_cont_stdev)<-c("Mean","StdDev")
    
    if (Cont_scenario == 1){# based on kap data
      mu = log((Mean_cont_stdev[,1]^2)/sqrt(Mean_cont_stdev[,2] + (Mean_cont_stdev[,1]^2)))
      sigma = sqrt(log(Mean_cont_stdev[,2]/(Mean_cont_stdev[,1]^2)+1))
      
      AFB1_cont_feed<-NULL
      for(i in 1:dim(Mean_cont_stdev)[1]){
        AFB1_cont_feed<-rbind(AFB1_cont_feed,rlnorm(nruns,mu[i],sigma[i]))
      }
      # convert back from log
      AFB1_cont_feed = 10^AFB1_cont_feed
      # convert back from log+1
      AFB1_cont_feed = AFB1_cont_feed -1
      AFB1_cont_feed[which(is.na(AFB1_cont_feed)==TRUE)]<-0       
      AFB1_cont_feed[AFB1_cont_feed>100]<-0; # check condition
    }else{ # will use contaminated maize
      
      Mean_cont_stdev [3,] = c(1.6747,0.25672) # contaminated maize batch
      mu = log((Mean_cont_stdev[,1]^2)/sqrt(Mean_cont_stdev[,2] + (Mean_cont_stdev[,1]^2)))
      sigma = sqrt(log(Mean_cont_stdev[,2]/(Mean_cont_stdev[,1]^2)+1))
      
      AFB1_cont_feed<-NULL
      for(i in 1:dim(Mean_cont_stdev)[1]){
        AFB1_cont_feed<-rbind(AFB1_cont_feed,rlnorm(nruns,mu[i],sigma[i]))
      }
      # convert back from log
      AFB1_cont_feed = 10^AFB1_cont_feed
      # convert back from log+1
      AFB1_cont_feed = AFB1_cont_feed -1
      AFB1_cont_feed[which(is.na(AFB1_cont_feed)==TRUE)]<-0       
      AFB1_cont_feed[AFB1_cont_feed>200]<-0; # check condition
    } 
    return(AFB1_cont_feed)
}
