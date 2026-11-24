# MOTOR INSURANCE PRICING PROJECT
# Step 11: Gamma Severity Model

library(CASdatasets)
data("freMTPL2sev")

# Claim-level dataset
sev_data<-freMTPL2sev

# Add policy risk characteristics to each claim

severity_data<-merge(
  sev_data,
  train_freq[,c("IDpol","DrivAge","VehAge",
                "VehPower","BonusMalus","Area")],
  by="IDpol"
)

# Training severity claims
train_sev<-severity_data

# Separately prepare test severity claims
test_sev<-merge(
  sev_data,
  test_freq[,c("IDpol","DrivAge","VehAge",
               "VehPower","BonusMalus","Area")],
  by="IDpol"
)

# Check number of claim records
nrow(train_sev)
nrow(test_sev)

# Check claim amounts
summary(train_sev$ClaimAmount)

# Fit Gamma severity model
severity_model<-glm(
  ClaimAmount ~ DrivAge+VehAge+VehPower+
    BonusMalus+Area,
  family = Gamma(link = "log"),
  data = train_sev
)

summary(severity_model)

# Predict average claim severity
test_sev$PredictedSeverity<-predict(
  severity_model,
  newdata = test_sev,
  type = "response"
)

# Compare actual and predicted claim costs
severity_AE<-sum(test_sev$ClaimAmount)/
  sum(test_sev$PredictedSeverity)
severity_AE

# View first six predictions
head(test_sev[,
              c("IDpol","ClaimAmount","PredictedSeverity")
])

poisson_deviance(
  test_freq$ClaimNb,
  test_freq$PredictedClaims
)

poisson_deviance(
  test_freq$ClaimNb,
  test_freq$NB_PredictedClaims
)
