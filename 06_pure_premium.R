# MOTOR INSURANCE PRICING PROJECT
# Step 13: Pure Premium Calculation

# 1. Predict annual frequency using Poisson
test_freq$PoissonFrequency<-predict(
  frequency_model,
  newdata = test_freq,
  type = "response"
) / test_freq$Exposure

# 2. Predict annual frequency using Negative Binomial
test_freq$NBFrequency<-predict(
  nb_model,
  newdata = test_freq,
  type = "response"
) / test_freq$Exposure

#3.Predict expected severity for EVERY test policy
test_freq$ExpectedSeverity<-predict(
  severity_model,
  newdata = test_freq,
  type = "response"
)

# 4. Calculate annual pure premiums
test_freq$PoissonPurePremium<-
  test_freq$PoissonFrequency*test_freq$ExpectedSeverity

test_freq$NBPurePremium<-test_freq$NBFrequency*test_freq$ExpectedSeverity

# 5. Expected claim cost over actual policy exposure
test_freq$NBExpectedCost<-
  test_freq$NBPurePremium*
  test_freq$Exposure

# 6. View the first few results
head(test_freq[,c(
  "IDpol","Exposure",
  "PoissonFrequency","NBFrequency",
  "ExpectedSeverity",
  "PoissonPurePremium","NBPurePremium"
)])

# Step 14: Validate combined pure premium


# Aggregate actual claim costs by policy
actual_cost<-aggregate(
  ClaimAmount ~ IDpol,
  data = test_sev,
  FUN = sum
)

names(actual_cost)[2]<-"ActualClaimCost"

# Match actual costs to every test policy
test_freq$ActualClaimCost<-actual_cost$ActualClaimCost[
  match(test_freq$IDpol,actual_cost$IDpol)
]

# Policies with no claims have zero actual cost
test_freq$ActualClaimCost[
  is.na(test_freq$ActualClaimCost)
]<-0

# Total actual and expected claim costs
total_actual_cost<-sum(test_freq$ActualClaimCost)
total_expected_cost<-sum(test_freq$NBExpectedCost)

# Combined pure premium A/E ratio
pure_premium_AE<-total_actual_cost/total_expected_cost

total_actual_cost
total_expected_cost
pure_premium_AE

# Create output folder if it does not exist
dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

# Save policy-level pricing results
write.csv(
  test_freq,
  "outputs/tables/pure_premium_predications.csv",
  row.names = FALSE
)
