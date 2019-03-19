## Overview

TSUM1 and TSUM 2 data from the crop phenology model WOFOST (World FOod STudies) 
developed under EU Monitoring Agricultural ResourceS (MARS) project. Data used 
included gridded TSUM1 and TSUM2 for maize grown in Europe, per grid of 25*25 
KM. Data is protected. Metadata and some records are shown in de data folder.



## Data Dictionary


| ### Variable      | Definition                                      	|
|-----------------	|---------------------------------------------- 	|
| grid no         	| grid number                                   	|
| crop_no        	| 1=winter wheat, 2=grain maize, 95=spring barley  	|
| variety_no       	| unique number of crop variety                 	|
| start_type    	| type of starting date to calculate TSUM          	|
| start_date     	| starting date to calculate TSUM                  	|
| start_day     	| day of the month to start TSUM calculation      	|
| start_month    	| month that TSUM calculation started             	|
| tsum1           	| sum of average daily temperature from start_date. |
|                   |For winter wheat, Tbase = 0, Tmax = 30             |
|                   |For grain maize, Tbase = 10, Tmax= 30              | 
|                   |For spring barley, Tbase = 0, Tmax=35              |
|                   |which means tsum starts to cummulate when average T|
|                   |is between Tbase and Tmax.                         |
| tsum2            	| similar as tsum1, but for harvest date        	|

Data in Tab MAPSPAM areas are not used. 



## Variable Notes
tsum:
    For grain maize, Tbase = 10, Tmax= 30               
      
    which means tsum starts to cummulate when average T is between Tbase 
    and Tmax.         

