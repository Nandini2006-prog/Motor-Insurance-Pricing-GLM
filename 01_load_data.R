#Motor insurance Pricing Using Frequency-Severity GLM
# step 1: Load the datasets

install.packages(
  "CASdatasets",
  repos = c(
    "https://dutangc.perso.math.cnrs.fr/RRepository/pub/",
    "https://cloud.r-project.org"
  ),
  type = "source"
)

library(CASdatasets)
data("freMTPL2freq")
data("freMTPL2sev")

freq<-freMTPL2freq
sev<-freMTPL2sev

dim(freq)
dim(sev)

head(freq)
head(sev)

names(freq)
names(sev)

str(sev)

colSums(is.na(freq))
colSums(is.na(sev))

sum(duplicated(freq$IDpol))

sum(freq$Exposure<=0,na.rm = TRUE)

summary(freq$ClaimNb)
summary(sev$ClaimAmount)
