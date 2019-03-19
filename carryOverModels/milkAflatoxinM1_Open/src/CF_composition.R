CF_composition<-function(CF_scenario,nruns){
      wheat<- c(5,6,0,35) 
      barley <-c(0,2.39,0,0)
      corn<-c(10.24,15.06,0,35)
      triticale <- c(1.2,1.9,0,15)
      rey <- c(0,1,0,15) 
      
      
      soyabean_meal<-c(14.96, 0.23,0,30)
      sunflower_seed_meal<-c(4.5,3.83,0,25)     
      palm_kernel <- c(15.01,15.00,0,20)
      rapeseed_meal <-c(7.94,5.54,0,30)
      corn_gluten_feed<-c(3.67,1.0,0,30)
      flour<-c(0,0.04,0,20) 
      dried_beet_pulp<-c(0.08,7.86,0,40)
      citrus_pulp <-c(0,3.37,0,25)
      molasses<-c(1.5,1.55,0,10)    
      
      Composition_cereals = rbind(wheat,barley,corn,triticale,rey)
      
      Comp_non_cereals = rbind(soyabean_meal,sunflower_seed_meal,palm_kernel,rapeseed_meal,
                               corn_gluten_feed,flour,dried_beet_pulp,citrus_pulp,molasses)
      cereals_comp<-NULL
      # 2013 composition high protein
      if(CF_scenario==1){
        CF_comp <- c(Composition_cereals[,1],Comp_non_cereals[,1])
        CF_comp <- replicate(nruns,CF_comp)
      }else if(CF_scenario == 2) { # 2013 composition low protein
        CF_comp <- c(Composition_cereals[,2],Comp_non_cereals[,2])
        CF_comp <- replicate(nruns,CF_comp)
      }else if(CF_scenario == 3){ # distribution of general guidelines
        TF<-0
        count <- 0
        while (TF < nruns){
          # simulation for cereals
          Min_cont_cereals = Composition_cereals[,3]; # minimum inclusion rate
          Max_cont_cereals = Composition_cereals[,4]; # maximum inclusion rate
          cereals_comp_test=replicate((nruns*7),rep(0,length(Min_cont_cereals)))

          for (i in 1:length(Min_cont_cereals)){
            #set.seed(123)
            cereals_comp_test[i,]<- runif((nruns*7),Min_cont_cereals[i], Max_cont_cereals[i])
          }
          A = colSums(cereals_comp_test)
          Check = t(data.matrix(which(A>20 & A<60)))
          AA = dim(Check)
          TF=AA[2]
          count=count+1
        }
        cereals_comp <- cereals_comp_test[,Check]
        cereals_comp<-rbind(cereals_comp,colSums(cereals_comp))
        cereals_comp<-t(cereals_comp)
        cereals_comp <- cereals_comp[order(-cereals_comp[,6]),]
        cereals_comp <- t(cereals_comp)
      
      
        ## simulation for non-cereals
        count <-0
        TF<-0
        while (TF < nruns){
        # simulation for cereals
        Min_non_cereals = Comp_non_cereals[,3]; 
        Max_non_cereals = Comp_non_cereals[,4]; 
        non_cereals_comp_test=replicate((nruns*400),rep(0,length(Min_non_cereals)))
        
        for (i in 1:length(Min_non_cereals)){
          #set.seed(123)
          non_cereals_comp_test[i,]<- runif((nruns*400),Min_non_cereals[i], Max_non_cereals[i])
        }
        A = colSums(non_cereals_comp_test)
        Check = t(data.matrix(which(A<65)))
        AA = dim(Check)
        TF=AA[2]
        count=count+1
      }
        non_cereals_comp = non_cereals_comp_test[,Check[,1:dim(cereals_comp)[2]]]
        non_cereals_comp = rbind(non_cereals_comp,colSums(non_cereals_comp))
        non_cereals_comp = t(non_cereals_comp)
        non_cereals_comp = non_cereals_comp[order(non_cereals_comp[,10]),]
        non_cereals_comp = t(non_cereals_comp)
      
        ## find simulations with a total composition of 100%
        ABC = cereals_comp[6,] + non_cereals_comp[10,]
        Check = which(ABC<100);
        non_cereals_comp<-non_cereals_comp[-10,] 
        cereals_comp<-cereals_comp[-6,] 
        ABC =rbind(cereals_comp[,Check], non_cereals_comp[,Check])
        ABC <-rbind(ABC,colSums(ABC));
        CF_comp = ABC[c(1:14),20:(nruns+19)];
        return(CF_comp)

        }
}