# Overview
Supporting information for the paper entitled 'Climate change impacts on aflatoxin
B1 in maize and aflatoxin M1 in milk' in the PLOS ONE journal. 

HJ Van der Fels-Klerx1*, LC Vermeulen1, AK Gavai1, C Liu1
1RIKILT Wageningen University and Research, Wageningen, the Netherlands


## Goal : 
This study aimed to investigate the impacts of climate change on aflatoxin B1 
production in maize and its consequences on aflatoxin M1 contamination in dairy 
cow’s milk, using a full chain modelling approach.

## Keywords : 

Crop phenology model, Forecasting model, Carryover model, Ensemble modelling, 
Data infrastructure, Systems modelling, Aflatoxin B1, Aflatoxin M1, Milk, Maize

## Abstract :
> Various models and datasets related to aflatoxins in the maize and dairy 
production chain have been developed and used but they have not yet been linked 
with each other. This study aimed to investigate the impacts of climate change 
on aflatoxin B1 production in maize and its consequences on aflatoxin M1 
contamination in dairy cow’s milk, using a full chain modelling approach. 
To this end, available models and input data were chained together in a 
modelling framework. As a case study, we focused on maize grown in Eastern 
Europe and imported to the Netherlands to be fed – as part of dairy cows’ 
compound feed – to dairy cows in the Netherlands. Three different climate 
models, one aflatoxin B1 prediction model and five different carryover models 
were used. For this particular case study of East European maize, most of the 
calculations suggest an increase (up to 50%) of maximum mean AfM1 in milk by 
2030, except for one climate (DMI) model suggesting a decrease. All calculations
suggest a stable, with a slight increase (up to 0.6%), chance of finding AfM1 in
milk above the EC limit of 0.05 µg/kg by 2030. Results varied mainly with the 
climate model data and carryover model considered. The model framework 
infrastructure is flexible so that forecasting models for other mycotoxins or 
other food safety hazards as well as other production chains, together with 
necessary input databases, can easily be included as well. This modelling 
framework for the first time links datasets and models related to aflatoxin B1 
in maize and related aflatoxin M1 the dairy production chain to obtain a unique 
predictive methodology based on Monte Carlo simulation. Such an integrated 
approach with scenario analysis provides possibilities for policy makers and 
risk managers to study the effects of changes in the beginning of the chain on 
the end product. 

## General Setup:
Structure of the project with the Git Repo. Each of the models consists of a data folder (input/output)
with associated metadata attached to it. The source code associated with each of the models are in the
same folder.

Following folders exist:
1. carry-overModels
2. cropPhenologyModels
3. forecastingModels 
4. workflows

Set up of the data and model flow is illustrated in Fig 1.pdf. Box 1-2 show
the two models that are linked. Box A-D provide the input for the forecasting
model, and box E-H are the input for the Carryover model. Box F and I are 
predicted model outcomes. 

## Acknowledgements :
The authors acknowledge the Joint Research Centre of the European Commission for
providing the calibrated temperature sums for maize from the MARS Crop Growth
Monitoring System and its related databases. This study is supported by the 
Ministry of Economic Affairs, the Netherlands, through the KB programme. 
