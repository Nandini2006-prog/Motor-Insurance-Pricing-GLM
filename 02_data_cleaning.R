freq$ClaimNb != floor(freq$ClaimNb)

cat("Non-positive or missing claim amounts:\n")
print(sum(is.na(sev$ClaimAmount) /
            sev$ClaimAmount<=0 ))

cat("Total claims:\n")
print(sum(freq$ClaimNb,na.rm = TRUE))

cat("Total exposure:\n")
print(sum(freq$Exposure,na.rm = TRUE))

cat("Observed claim frequency:\n")
print(sum(freq$ClaimNb,na.rm = TRUE)/
        sum(freq$Exposure,na.rm = TRUE))

sum(freq$ClaimNb,na.rm = TRUE)
nrow(sev)
length(unique(sev$IDpol))

sum(freq$Exposure<=0,na.rm = TRUE)
sum(freq$ClaimNb<=0,na.rm = TRUE)
sum(sev$ClaimAmount<=0,na.rm = TRUE)
sum(freq$ClaimNb)
nrow(sev)
sum(!sev$IDpol %in% freq$IDpol)
sum(freq$ClaimNb<0)

#Checking final data validation

# Check negative and non-integer claim counts
sum(freq$ClaimNb < 0)
sum(freq$ClaimNb != floor(freq$ClaimNb))

# Check missing values in severity
colSums(is.na(sev))

# Count severity records per policy
claim_counts <- as.data.frame(
  table(sev$IDpol),
  stringsAsFactors = FALSE
)

names(claim_counts) <- c("IDpol", "SeverityCount")

# Match ID types before joining
claim_counts$IDpol <- as.numeric(claim_counts$IDpol)

# Match claim counts to frequency policies
freq$SeverityCount <- claim_counts$SeverityCount[
  match(freq$IDpol, claim_counts$IDpol)
]

# Policies with no severity records have zero claims
freq$SeverityCount[is.na(freq$SeverityCount)] <- 0

# Count disagreements
sum(freq$ClaimNb != freq$SeverityCount)

# Display any disagreements
head(freq[
  freq$ClaimNb != freq$SeverityCount,
  c("IDpol", "ClaimNb", "SeverityCount")
])
