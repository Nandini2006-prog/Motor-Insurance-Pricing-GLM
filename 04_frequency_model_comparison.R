install.packages("MASS")

# MOTOR INSURANCE PRICING PROJECT
# Step 9: Negative Binomial Comparison

library(MASS)

# 1. Fit Negative Binomial GLM
nb_model<-glm.nb(
  ClaimNb ~ DrivAge+VehAge+VehPower+
    BonusMalus+Area+
    offset(log(Exposure)),
  data = train_freq
)

summary(nb_model)

# 3. Compare training AIC
AIC(frequency_model,nb_model)


# 4. Predict expected claims on test data
test_freq$NB_PredictedClaims<-predict(
  nb_model,
  newdata = test_freq,
  type = "response"
)

# 5. Calculate test A/E ratio

NB_AE<-sum(test_freq$ClaimNb)/
  sum(test_freq$NB_PredictedClaims)
NB_AE

# 6. Compare test Poisson deviance
# (A common predictive score for both models)
poisson_deviance<-function(actual,predicted){
  2*sum(
    ifelse(actual==0,0,
           actual*log(actual/predicted))
  )
}
poisson_deviance(
  test_freq$ClaimNb,
  test_freq$PredictedClaims
)
poisson_deviance(
  test_freq$ClaimNb,
  test_freq$NB_PredictedClaims
)
