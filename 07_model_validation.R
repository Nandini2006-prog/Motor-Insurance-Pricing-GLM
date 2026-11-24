# MOTOR INSURANCE PRICING PROJECT
# Step 16: Model Validation

# Expected cost using Poisson-Gamma
test_freq$PoissonExpectedCost<-
  test_freq$PoissonPurePremium*test_freq$Exposure

# Expected cost using NB-Gamma
test_freq$NBExpectedCost<-
  test_freq$NBPurePremium*test_freq$Exposure


# Compare aggregate performance

model_comparison<-data.frame(
  Model= c("Poisson-Gamma","NB-Gamma"),
  ActualCost=rep(sum(test_freq$ActualClaimCost),2),
  ExpectedCost=c(
    sum(test_freq$PoissonExpectedCost),
    sum(test_freq$NBExpectedCost)
  )
)

model_comparison$AE_Ratio<-
  model_comparison$ActualCost/
  model_comparison$ExpectedCost

print(model_comparison)


# Aggregate results by area
area_validation<-aggregate(
  cbind(ActualClaimCost,NBExpectedCost) ~ Area,
  data = test_freq,
  FUN = sum
)

# Calculate Actual-to-Expected
area_validation$AE_Ratio<-
  area_validation$ActualClaimCost/
  area_validation$NBExpectedCost

print(area_validation)

# Create chart folder
dir.create(
  "outputs/charts",
  recursive = TRUE,
  showWarnings = FALSE
)

# Save A/E chart
png(
  "outputs/charts/area_validations.png",
  width=1000,
  height=650
)

barplot(
  area_validation$AE_Ratio,
  names.arg = area_validation$Area,
  main = "Actual vs Expected Claim Cost by Area",
  xlab = "Area",
  ylab = "A/E Ratio",
  col = "steelblue",
  ylim = c(0,max(1.2,area_validation$AE_Ratio)*1.1)
)

abline(h=1,col="red",lty=2,lwd=2)
dev.off()

# STEP 18: Large Claim Investigation

# 1. Find the 10 largest claims in test data
largest_claims<-test_sev[
  order(-test_sev$ClaimAmount),
  c("IDpol","Area","ClaimAmount")
]

head(largest_claims,10)

# 2. Find the 99th percentile claim amount
largest_claim_threshold<-quantile(
  test_sev$ClaimAmount,
  0.99
)
largest_claim_threshold

# 3. Percentage of total cost from top 1% claims
top_1_percent<-test_sev$ClaimAmount>=largest_claim_threshold

large_claim_share<-sum(
  test_sev$ClaimAmount[top_1_percent]
)/sum(test_sev$ClaimAmount)

large_claim_share*100


# 4. Claim count and average claim cost by area
area_claims<-aggregate(
  ClaimAmount ~ Area,
  data = test_sev,
  FUN = function(x) c(
    Count = length(x),
    Mean = mean(x),
    Max = max(x)
  )
)
print(area_claims)

# STEP 20: Large Claim Sensitivity Analysis

# 1. Find the largest claim in each area
largest_by_area<-aggregate(
  ClaimAmount ~ Area,
  data = test_sev,
  FUN = max
)

names(largest_by_area)[2]<-"LargestClaim"

# 2. Join with original area validation
sensitivity<-merge(
  area_validation,
  largest_by_area,
  by ="Area"
)

# 3. Calculate observed costs excluding
# the single largest claim in each area
sensitivity$AdjustedActualCost<-
  sensitivity$ActualClaimCost-
  sensitivity$LargestClaim

# 4. Diagnostic ratio using original
# expected costs as a fixed benchmark
sensitivity$AdjustedAE<-
  sensitivity$AdjustedActualCost/
  sensitivity$NBExpectedCost

# 5. Compare results
print(sensitivity[,c(
  "Area",
  "AE_Ratio",
  "LargestClaim",
  "AdjustedAE"
)])
