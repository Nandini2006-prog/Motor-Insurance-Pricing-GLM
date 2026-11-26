# Motor Insurance Pricing Using Frequency–Severity GLMs

### An Actuarial Pricing Project in R

## 1. Project Overview

This project develops a risk-based motor insurance pricing framework using Generalized Linear Models (GLMs) in R.

The objective is to estimate policy-level pure premiums by separately modelling claim frequency (expected number of claims) and claim severity (expected cost per claim).

The project also evaluates model performance through statistical model comparison, Actual-to-Expected (A/E) ratios, geographical segment validation, and large-claim sensitivity analysis.

## 2. Dataset

**Dataset:** French Motor Third-Party Liability (freMTPL2)  
**Source:** `CASdatasets` R package

The analysis uses:

- **677,991 policy records** from `freMTPL2freq`
- **26,444 individual claim records** from `freMTPL2sev`

Key variables include driver age, vehicle age, vehicle power, BonusMalus, geographical area, exposure, claim counts, and claim amounts.

The dataset is used for educational and portfolio modelling purposes.

## 3. Methodology

### Data Preparation

- Checked missing values, duplicate policy identifiers, exposure values, and claim counts.
- Reconciled claim-level records with policy-level information.
- Created a reproducible 80:20 train-test split at the policy level.
- Accounted for different policy durations using an exposure offset.

### Claim Frequency Modelling

Two models were fitted:

- **Poisson GLM** with a log link and exposure offset.
- **Negative Binomial GLM** to account for overdispersion.

Both models use driver age, vehicle age, vehicle power, BonusMalus, and area as predictors.

### Claim Severity Modelling

A **Gamma GLM with a log link** was fitted to positive individual claim amounts using the same selected risk characteristics.

### Pure Premium Estimation

Annual pure premiums were estimated as:

**Annual Pure Premium = Predicted Annual Claim Frequency × Predicted Claim Severity**

Expected claim costs over the observed policy duration were calculated by multiplying annual pure premiums by exposure.

## 4. Key Results

| Metric | Result |
|---|---|
| Poisson Pearson dispersion | 1.8044 |
| Poisson AIC | 173,476.8 |
| Negative Binomial AIC | 172,948.8 |
| Poisson–Gamma test A/E | 1.0116 |
| Negative Binomial–Gamma test A/E | 1.0057 |
| Share of test claim costs from largest ~1% of claims | 38.95% |

The Negative Binomial model achieved a lower AIC than the Poisson model, supporting its use as the preferred frequency model among the two candidates.

The Negative Binomial–Gamma framework achieved good overall aggregate calibration on the testing dataset.

However, area-wise validation revealed considerable variation in Actual-to-Expected ratios.

## 5. Area-Wise Validation

| Area | Actual-to-Expected Ratio |
|---|---|
| A | 1.598 |
| B | 0.506 |
| C | 1.714 |
| D | 0.645 |
| E | 0.767 |
| F | 0.980 |

Although the overall A/E ratio was close to 1, individual areas exhibited substantial differences between observed and predicted claim costs.

This demonstrates the importance of validating actuarial pricing models at both portfolio and segment levels.

## 6. Large-Claim Sensitivity Analysis

The largest approximately 1% of individual claims accounted for **38.95% of total test claim costs**.

To investigate the influence of extreme claims, the largest individual claim in each area was excluded from actual costs in a diagnostic sensitivity calculation, while model predictions remained unchanged.

For Area C, the A/E ratio decreased from **1.714 to 1.173** after this adjustment.

This suggests that extreme claims materially influenced the observed geographical validation results.

The adjusted ratios are sensitivity diagnostics, not results from refitted pricing models.

## 7. Tools and Technologies

- R and RStudio
- `CASdatasets`
- `MASS`
- Generalized Linear Models
- Statistical Model Validation
- Data Analysis and Visualization

## 8. Project Structure

```text
Motor-Insurance-Pricing-GLM/
├── 01_load_data.R
├── 02_data_cleaning.R
├── 03_frequency_model.R
├── 04_frequency_model_comparison.R
├── 05_severity_model.R
├── 06_pure_premium.R
├── 07_model_validation.R
├── main.R
├── Motor-Insurance-Pricing-GLM.Rproj
├── README.md
└── outputs/
    ├── tables/
    │   ├── model_comparison.csv
    │   ├── area_validation.csv
    │   ├── pure_premium_predictions.csv
    │   └── fitted_models.rds
    └── charts/
        └── area_validation.png
```

## 9. How to Run the Project

1. Install R and RStudio.
# Install required packages if not already installed
install.packages("MASS")

# CASdatasets must also be installed
# Check whether it is available
packageVersion("CASdatasets")

# Run the complete project
source("main.R")
```

5. Review the generated CSV tables and validation charts in the `outputs` directory.

## 10. Limitations and Future Improvements

- Results are based on a single random train-test split.
- The models use a limited selection of available risk characteristics.
- Extreme claims can strongly influence aggregate cost validation.
- Further evaluation using additional predictive performance metrics and cross-validation would strengthen the analysis.
- Commercial premium loadings have not been included.

Potential extensions include alternative severity distributions, more comprehensive model diagnostics, and additional risk-factor analysis.

## 11. Conclusion

The project demonstrates an end-to-end actuarial pricing workflow, from data validation and statistical modelling to policy-level pure premium estimation and portfolio-level validation.

The Negative Binomial–Gamma framework showed good aggregate calibration, while geographical and large-claim analyses highlighted the importance of understanding variation within an insurance portfolio.

**Project focus:** Actuarial Science | Insurance Pricing | GLMs | R | Risk Analytics
