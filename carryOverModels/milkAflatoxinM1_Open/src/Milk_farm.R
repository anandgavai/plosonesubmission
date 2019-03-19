Milk_farm<-function(total_weeks,dry_weeks,total_cows,lactation_total,factor) {

lactation = 1:lactation_total
dry_period = rep(0,dry_weeks)
total_lactation = c(lactation,dry_period)
total_lactation = rep(total_lactation,5); 
total_lactation = t(total_lactation)



## daily milk yield in lactation week t (Olori et al 1999)
a = 34.2;
b = -31.2;
c = -0.261;
k = 0.61;

t<-NULL
Milk_yield<-NULL
for (cow in 1:total_cows){
  t<-rbind(t,total_lactation[,(1+(cow-1)):((cow-1)+total_weeks)])
  Milk_yield<-rbind(Milk_yield,(a+(b*exp(-k*t[cow,]))+c*t[cow,])) # daily milk yield kg/day - uniform over each lactation week
}

idx<-which(t==0)
Milk_yield[idx] <- 0

Milk_yield_all_log = rep(Milk_yield[31,],total_cows)

if (factor == 1){
  Milk_yield = Milk_yield
}else if (factor==2){
  Milk_yield = Milk_yield_all_log
}else if (factor==3){
  Milk_yield = Milk_yield * 1.3
}else if (factor==4){
  Milk_yield = Milk_yield * 0.7
}

## Carry over rates per cow (rows) per week (columns)
## Carry over rate 1 (Masoero et al 2007)
CO_1=(Milk_yield*0.077) - 0.326

# carry over rate 2 (Veldman et al 1992)
CO_2 = (Milk_yield * 0.13) - 0.26

## carry over rate 3 (Britzi et al 2013)
CO_3 = 0.5154 * (exp(0.0521 * Milk_yield))

return(list(CO_1=CO_1,CO_2=CO_2,CO_3=CO_3, Milk_yield=Milk_yield))

}
