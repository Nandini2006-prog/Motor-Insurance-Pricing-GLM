# MOTOR INSURANCE PRICING PROJECT
# Step 7: Frequency Model

library(CASdatasets)
data("freMTPL2freq")

# Create a clean modelling copy
freq_model_data<-freMTPL2freq

# Convert categorical variables to factors
freq_model_data$Area<-as.factor(freq_model_data$Area)

# Set seed so results are reproducible
set.seed(123)

# Randomly select 80% of policies for training
train_index<-sample(
  seq_len(nrow(freq_model_data)),
  size = floor(0.8*nrow(freq_model_data))
)

# Create training and testing datasets
train_freq<-freq_model_data[train_index, ]
test_freq<-freq_model_data[-train_index, ]

# Check dimensions
dim(train_freq)
dim(test_freq)

# Fit Poisson frequency model
frequency_model<-glm(
  ClaimNb ~ DrivAge+VehAge+VehPower+
    BonusMalus+Area+
    offset(log(Exposure)),
  family = poisson(link = "log"),
  data = train_freq
)

# Display model summary
summary(frequency_model)

dispersion<-sum(
  residuals(frequency_model,type = "pearson")^2
) / df.residual(frequency_model)

dispersion

# Predict expected claim counts
test_freq$PredictedClaims<-predict(
  frequency_model,
  newdata=test_freq,
  type = "response"
)


# Convert expected counts to annual frequency
test_freq$PredictedFrequency<-
  test_freq$PredictedClaims/test_freq$Exposure

# View first six predictions
head(test_freq[
  ,c("IDpol","ClaimNb","Exposure",
     "PredictedClaims","PredictedFrequency")
])

# Total actual claims
actual_claims<-sum(test_freq$ClaimNb)


# Total predicted claims
expected_claims<-sum(test_freq$PredictedClaims)

# Actual-to-Expected ratio
AE_ratio<-actual_claims/expected_claims

actual_claims
expected_claims
AE_ratio
