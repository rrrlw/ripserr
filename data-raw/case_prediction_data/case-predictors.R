case_predictors <- data.frame()
case_predictors[27, 1] <- NA
stateList <- structure(list(name = c("Acre", "Alagoas", "Amap?", "Amazonas", 
                                     "Bahia", "Cear?", "Distrito Federal", "Esp?rito Santo", "Goi?s", "Maranhao", "Mato Grosso", 
                                     "Mato Grosso do Sul", "Minas Gerais", "Par?", "Para?ba", "Paran?", 
                                     "Pernambuco", "Piau?", "Rio de Janeiro", "Rio Grande do Norte", 
                                     "Rio Grande do Sul", "Rond?nia", "Roraima", "Santa Catarina", 
                                     "Sao Paulo", "Sergipe", "Tocantins"), abb = c("AC", "AL", "AP", 
                                                                                   "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", 
                                                                                   "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", 
                                                                                   "TO")), row.names = c(15L, 17L, 26L, 21L, 10L, 23L, 8L, 9L, 18L, 
                                                                                                         11L, 5L, 7L, 19L, 22L, 3L, 20L, 16L, 6L, 24L, 1L, 12L, 25L, 2L, 
                                                                                         4L, 14L, 13L, 27L), class = "data.frame")


stateList <- stateList[order(stateList$name),]#sorted by state names
stateAbbSort <-sort(stateList$abb) #sorted vector of abbreviation

rownames(case_predictors) <- stateAbbSort

#----------------------Density = POP/Area----------------------#
Area <- read.csv("State Area 2020.csv", header = FALSE)
colnames(Area) <- c("State", "Area")

Population <- read.csv("Brazil Population 2013.csv", header = FALSE, fileEncoding="UTF-8-BOM")
colnames(Population) <- c("State", "Population")

curArea <- 0
curRow_A <- 1
curPop <- 0
curRow_P <- 1
pop_Density <- data.frame()

for(val in stateAbbSort){
  for(i in curRow_A : nrow(Area)){
    if(Area[i, 1] == val){
      curArea <- curArea + Area[i, 2]
    }else{
      curRow_A <- i
      break
    }
  }
  
  for(j in curRow_P : nrow(Population)){
    if(Population[j, 1] == val){
      curPop <- curPop + strtoi(Population[j,2], base = 0L)
    }else{
      curRow_P <- j
      break
    }
  }
  
  curDensity <- curPop/curArea
  
  pop_Density <- rbind(pop_Density, c(curArea, curPop, curDensity))
  curArea <- 0
  curPop <- 0
}

colnames(pop_Density) <- c("Area", "Population", "Density")
case_predictors[,1] <- pop_Density[,3]
colnames(case_predictors) <- "POP"

remove(pop_Density, Area, Population, curArea, curPop, curRow_A, curRow_P, curDensity)

#-----------------------------Temperature------------------------------#
Temperature <- read.csv("Temperature.csv")
removeRows <- vector()

for(i in 1 : nrow(Temperature)){ ##remove empty rows
  if(Temperature[i,6] == "#DIV/0!"){
    removeRows <- c(removeRows, c(i))
  }
}
Temperature <- Temperature[-removeRows,]

curTemp_Sum <- 0
curRow_T <- 1
TempAverage <- data.frame()

for(val in stateAbbSort){
  for(i in curRow_T : nrow(Temperature)){
    if(Temperature[i, 1] == val){
      curTemp_Sum <- curTemp_Sum + as.double(Temperature[i, 6])
      if(i == nrow(Temperature)){
        curTemp_Ave <- curTemp_Sum/(i - curRow_T)
        TempAverage <- rbind(TempAverage, c(curTemp_Ave))
      }
    }else{
      curTemp_Ave <- curTemp_Sum/(i - curRow_T)
      TempAverage <- rbind(TempAverage, c(curTemp_Ave))
      curRow_T <- i
      curTemp_Sum <- 0
      break
    }
  }
}
colnames(TempAverage) <- c("Average Temp")
rownames(TempAverage) <- stateAbbSort
case_predictors <- cbind(case_predictors, c(TempAverage[,1]))
colnames(case_predictors)[2] <- "TEMP"

remove(curTemp_Sum, curTemp_Ave, curRow_T, TempAverage, Temperature)

#------------------------Precipitation------------------------#
Precipitation <- read.csv("Precipitation.csv", fileEncoding = "latin1")
removeRows <- vector()

for(i in 1 : nrow(Precipitation)){ ##remove empty rows
  if(Precipitation[i,7] == "#DIV/0!"){
    removeRows <- c(removeRows, c(i))
  }
}
Precipitation <- Precipitation[-removeRows,]

curPrecip_Sum <- 0
curRow_P <- 1
PrecipAverage <- data.frame()

for(val in stateAbbSort){
  for(i in curRow_P : nrow(Precipitation)){
    if(Precipitation[i, 1] == val){
      curPrecip_Sum <- curPrecip_Sum + as.double(Precipitation[i, 7])
      if(i == nrow(Precipitation)){
        curPrecip_Ave <- curPrecip_Sum/(i - curRow_P)
        PrecipAverage <- rbind(PrecipAverage, c(curPrecip_Ave))
      }
    }else{
      curPrecip_Ave <- curPrecip_Sum/(i - curRow_P)
      PrecipAverage <- rbind(PrecipAverage, c(curPrecip_Ave))
      curRow_P <- i
      curPrecip_Sum <- 0
      break
    }
  }
}
colnames(PrecipAverage) <- c("Average Precip")
rownames(PrecipAverage) <- stateAbbSort
case_predictors <- cbind(case_predictors, c(PrecipAverage[,1]))
colnames(case_predictors)[3] <- "PRECIP"

remove(curPrecip_Sum, curPrecip_Ave, curRow_P, PrecipAverage, Precipitation)
#----------------------------Cases----------------------------#
Cases <- read.csv(("Dengue Cases 2013.csv"), header = FALSE)
case_predictors <- cbind(case_predictors, Cases[,2])
colnames(case_predictors)[4]<- "CASE"
remove(Cases, stateList)

usethis::use_data(case_predictors, overwrite = TRUE)
