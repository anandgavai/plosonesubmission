source("CF_composition.R")
source("CF_contamination.R")
source("Milk_farm.R")
options(warn=-1)
## Constants

farm_Aflatoxin_model<-function(CF_scenario,factor,contamination_scenario,nruns){ 
total_weeks = 52; # number of weeks over which the model runs
total_cows = 69; # total number of cows in the farm
dry_weeks = 4; # dry period in between lactation cycles
lactation_total = 45; # weeks in a row of lactation cycle


## Compound feed composition scenario: CF_Scenario = 1,2,3
## 1 = 2013 high protein diet
## 2 = 2013 low protein diet
## 3 = distribution data from min and max inclusion rates

CF_scenario = CF_scenario

## Milk yield scenario in farm
# 1 = one new cow starts to lactate per week: see presentation for figure
# 2 = all cows together
# 3 = high yield
# 4 = low yield
factor = factor

l<-Milk_farm(total_weeks,dry_weeks,total_cows,lactation_total,factor)
CO_1<-l$CO_1
CO_2<-l$CO_2
CO_3<-l$CO_3
Milk_yield <- l$Milk_yield

## ingredients Contamination scenario
## 1 = KAP data distribution
## 2 = high maize contamination

Contamination_scenario = rep(1,(total_weeks/2)) # fortnights
high_maize_contamination = 13 ## identifies the fortnight in which the high maize contaminated batch is used. 

Contamination_scenario[high_maize_contamination] <- contamination_scenario


#   If contaminated silage maize is also included in the simulation: 
#   prop_maize_silage= 0.27; % proportion of silage maize used for feed
#   AFB1_cont_maize_silage = 1.0 ;% Contamination of silage maize set to LOQ = 1 ug/kg



## AfB1 intake
AFB1_intake_final = NULL
count = 0
week=1
while (week < total_weeks){  #assumption that feed changes every two weeks
  count = count + 1
  ## Afb1 contamination of compound feed ingredients: 
    Cont_scenario = Contamination_scenario ## selects contamination scenario
    ## runs CF_contamination function for AFB1 content of selected scenario
    AFB1_cont = CF_contamination(Cont_scenario, nruns,maizePred)
  
  ## Compound feed composition: percentage inclusion rate of each ingredient
    CF_comp = CF_composition( CF_scenario, nruns )  # output: CF_comp
    
  ## feed intake
  #  set.seed(123)
    Total_feed_intake = rnorm(nruns,18.7,1.3) ## kg DM / cow / day = total daily feed intake
    CF_in_diet = rnorm(nruns,4.3,0.2)  ## kg DM / cow / day = total compound feed in diet
    prop_CF_in_diet = (CF_in_diet/Total_feed_intake) ## proportion of total compound feed in daily intake 
    
  ## Totaly contamination of AFB1 in the whole compound feed   
    AFB1_cont_CF = colSums(AFB1_cont * (CF_comp/100)) ## total ug/kg over all CF

  ## Aflatoxiin intake per cow per day in ug/day
    AFB1_intake = ((Total_feed_intake * prop_CF_in_diet * AFB1_cont_CF) / 0.85) # ug/day (0.85 is correction for dw)
    ## if contaminated silage maize is include : 
    ## AFB1_intake = Total_feed_intake .* ((prop_CF_in_diet .* AFB1_cont_CF ./ 0.85)+(prop_maize_silage*AFB1_cont_maize_silage/0.3)); % ug/day
    ## AFB1_intake_silage(week,:) = Total_feed_intake .* prop_maize_silage*AFB1_cont_maize_silage/0.3;  
    AFB1_intake = cbind(AFB1_intake,AFB1_intake)
    AFB1_intake_final= cbind(AFB1_intake_final,AFB1_intake)
    week = week+2
}
dim(AFB1_intake_final)
#test<-colSums(AFB1_intake_final)/1000
#write.csv(test,file="M:/My Documents/RIKILT/Projecten/KB Big DAta/testR.csv")

## calculate the carry over of Afb1 in feed to Afm1 in milk 
# with 5 equations: 
  # first three use different carry over equations : CO_1 - 3
# carry over rate 1 (Maseoro et al 2007)
# carry over rate 2 (Veldman et al 1992)
# carry over rate 3 (Britzi et al 2013)
# 4th is from Van Eijkeren et al 2006
# 5th is from pettersson in 1998 (only dependent on afb1 intake)

AFM1_1 = array(rep(0,nruns),dim=c(nruns,total_weeks,total_cows))
AFM1_2 = array(rep(0,nruns),dim=c(nruns,total_weeks,total_cows))
AFM1_3 = array(rep(0,nruns),dim=c(nruns,total_weeks,total_cows))
AFM1_4 = array(rep(0,nruns),dim=c(nruns,total_weeks,total_cows))
AFM1_5 = array(rep(0,nruns),dim=c(nruns,total_weeks,total_cows))


## Coefficients requires for carry over equation 4
alpha = 0.032; beta = 17; ## Van Eijkeren et al 2006

for(cow in 1:total_cows){
  for (j in 1:total_weeks){
      AFM1_1[,j,cow] = (AFB1_intake_final[,j]* (CO_1[cow,j]/100) )/ Milk_yield[cow,j] ## ug AFM1 / kg milk 
      AFM1_2[,j,cow] = (AFB1_intake_final[,j]* (CO_2[cow,j]/100) )/ Milk_yield[cow,j]    
      AFM1_3[,j,cow] = (AFB1_intake_final[,j]* (CO_3[cow,j]/100) )/ Milk_yield[cow,j]    
      AFM1_4[,j,cow] = (AFB1_intake_final[,j]* alpha)/(beta+Milk_yield[cow,j])    
      AFM1_5[,j,cow] = ((AFB1_intake_final[,j]* 0.787)+10.5)/1000  # Pettersson 1998 (ng/kg milk)
  }
}

AFM1list<-list(AFM1_1=AFM1_1,AFM1_2=AFM1_2,AFM1_3=AFM1_3,AFM1_4=AFM1_4,AFM1_5=AFM1_5)
return(AFM1list)

}

#################### Validation Script ###################################3
#test<-NULL
#for (i in 1:dim(AFM1_1)[1]){
#    print(which(AFM1_4[i,,]>0.05))
#}

