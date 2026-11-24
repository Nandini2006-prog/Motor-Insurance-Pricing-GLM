# MOTOR INSURANCE PRICING USING GLMs
# Reproducible end-to-end project

library(CASdatasets)
library(MASS)

# 1. Load data
data("freMTPL2freq")
data("freMTPL2sev")

freq<- freMTPL2freq
sev<-freMTPL2sev

stopifnot(
  !anyNA(freq),
  !anyNA(sev),
  !anyDuplicated(freq$IDpol),
  all(freq$Exposure>0),
  all(freq$ClaimNb>=0),
  all(freq$ClaimNb==floor(freq$ClaimNb)),
  all(sev$ClaimAmount>0)
)

# Reconcile claim records by policy
counts<-table(sev$IDpol)
matched<-match(
  as.character(freq$IDpol),
  names(counts)
)
reconciled<-as.integer(counts[matched])
reconciled[is.na(reconciled)] <- 0

stopifnot(
  all(freq$ClaimNb==reconciled),
  all(sev$IDpol %in% freq$IDpol)
)

# 2. Train/test split
freq$Area<-factor(freq$Area)

set.seed(123)
idx<-sample(
  seq_len(nrow(freq)),
  floor(00.8*nrow(freq))
)

train_freq<-freq[idx, ]
test_freq<-freq[-idx, ]

# 3. Frequency models
formula_freq<-ClaimNb~
  DrivAge+VehAge+VehPower+
  BonusMalus+Area+
  offset(log(Exposure))

poisson_model<-glm(
  formula_freq,
  family = poisson(link = "log"),
  data = train_freq
)

# Fit Negative Binomial frequency model

nb_model <- MASS::glm.nb(
  formula_freq,
  data = train_freq
)

# Compare Poisson and Negative Binomial models
AIC(poisson_model, nb_model)

# 4. Claim-level severity datasets
risk_cols<-c(
  "IDpol","DrivAge","VehAge",
  "VehPower","BonusMalus","Area"
)

train_sev <- merge(
  sev,
  train_freq[, risk_cols],
  by = "IDpol"
)

test_sev <- merge(
  sev,
  test_freq[, risk_cols],
  by = "IDpol"
)

stopifnot(
  nrow(train_sev)+nrow(test_sev)==nrow(sev)
)

# 5. Gamma severity model
gamma_model<-glm(
  ClaimAmount~DrivAge + VehAge +
    VehPower + BonusMalus + Area,
  family = Gamma(link = "log"),
  data = train_sev
)

# 6. Predict annual frequency
test_freq$PoissonFrequency<-predict(
  poisson_model,
  newdata = test_freq,
  type = "response"
) / test_freq$Exposure

test_freq$NBFrequency<-predict(
  nb_model,
  newdata = test_freq,
  type = "response"
) / test_freq$Exposure

# 7. Predict claim severity
test_freq$ExpectedSeverity<-predict(
  gamma_model,
  newdata = test_freq,
  type="response"
)

# 8. Calculate annual pure premiums
test_freq$PoissonPurePremium<-
  test_freq$PoissonFrequency*
  test_freq$ExpectedSeverity

test_freq$NBPurePremium<-
  test_freq$NBFrequency*
  test_freq$ExpectedSeverity

test_freq$PoissonExpectedCost<-
  test_freq$PoissonPurePremium*
  test_freq$Exposure

test_freq$NBExpectedCost<-
  test_freq$NBPurePremium*
  test_freq$Exposure

# 9. Actual costs by policy
actual<-aggregate(
  ClaimAmount ~ IDpol,
  data = test_sev,
  FUN = sum
)

test_freq$ActualClaimCost<-actual$ClaimAmount[
  match(test_freq$IDpol,actual$IDpol)
]

test_freq$ActualClaimCost[
  is.na(test_freq$ActualClaimCost)
]<-0

sum(test_freq$ActualClaimCost)
sum(test_sev$ClaimAmount)

# 10. Model comparison
actual_total<-sum(test_freq$ActualClaimCost)

comparison<-data.frame(
  Model=c("Poisson-Gamma","NB-Gamma"),
  ActualCost=actual_total,
  ExpectedCost=c(
    sum(test_freq$PoissonExpectedCost),
    sum(test_freq$NBExpectedCost)
  )
)

comparison$AE_Ratio<-
  comparison$ActualCost/comparison$ExpectedCost
print(comparison)

# 11. Area-level validation
area_validation<-aggregate(
  cbind(ActualClaimCost,NBExpectedCost)~Area,
  data = test_freq,
  FUN = sum
)

area_validation$AE_Ratio<-
  area_validation$ActualClaimCost/area_validation$NBExpectedCost

print(area_validation)

# 12. Large claim diagnostics
threshold<-quantile(
  test_sev$ClaimAmount,0.99
)

large_claim_share<-sum(
  test_sev$ClaimAmount[
    test_sev$ClaimAmount>=threshold
  ]
)/sum(test_sev$ClaimAmount)

print(large_claim_share*100)

# 13. Create output folders
dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "outputs/charts",
  recursive = TRUE,
  showWarnings = FALSE
)

# Step 13: Large Claim Sensitivity Analysis

# Find largest claim in each area
largest_by_area <- aggregate(
  ClaimAmount ~ Area,
  data = test_sev,
  FUN = max
)

names(largest_by_area)[2] <- "LargestClaim"

# Merge with area validation results
sensitivity <- merge(
  area_validation,
  largest_by_area,
  by = "Area"
)

# Remove largest claim from actual costs
sensitivity$AdjustedActualCost <-
  sensitivity$ActualClaimCost -
  sensitivity$LargestClaim

# Calculate adjusted A/E ratio
sensitivity$AdjustedAE <-
  sensitivity$AdjustedActualCost /
  sensitivity$NBExpectedCost

# Display results
print(sensitivity[, c(
  "Area",
  "AE_Ratio",
  "LargestClaim",
  "AdjustedAE"
)])


# 14. Save results
write.csv(comparison,
  "outputs/tables/model_comparison.csv",
  row.names = FALSE
)

write.csv(
  area_validation,
  "outputs/tables/area_validation.csv",
  row.names = FALSE
)

write.csv(
  test_freq,
  "outputs/tables/pure_premium_predictions.csv",
  row.names = FALSE
)

# 15. Save area validation chart
png(
  "outputs/charts/area_validation.png",
  width = 1000,
  height = 650
)

barplot(
  area_validation$AE_Ratio,
  names.arg = area_validation$Area,
  main = "Actual vs Expected cost by area",
  xlab = "Area",
  ylab = "A/E Ratio",
  col = "steelblue",
  ylim = c(0,max(1.2,area_validation$AE_Ratio))
)

abline(h=1,col = "red",lty=2,lwd=2)
dev.off()

# 16. Save fitted models
saveRDS(
  list(
    poisson = poisson_model,
    negative_binomial = nb_model,
    gamma = gamma_model
  ),
  "outputs/tables/fitted_models.rds"
)

cat("\nProject completed successfully!\n")

