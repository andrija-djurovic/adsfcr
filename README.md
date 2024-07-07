# Applied Data Science for Credit Risk

<p align="center">
<img src="./figures/cover.jpg" alt="cover" width = "70%">
</p>

This repository is dedicated to my upcoming book, 📕 𝐀𝐩𝐩𝐥𝐢𝐞𝐝 𝐃𝐚𝐭𝐚 𝐒𝐜𝐢𝐞𝐧𝐜𝐞 𝐟𝐨𝐫 𝐂𝐫𝐞𝐝𝐢𝐭 𝐑𝐢𝐬𝐤 and other topics related to credit risk modeling. It will be regularly updated with GitHub pages, slides, and PDF documents covering various modeling subjects.

The motivation behind writing this book and creating the repository stems from the observed gap between academic literature, industry practices, and the evolving landscape of data science. While there's been a notable increase in literature on credit risk modeling, discrepancies persist.  The evolution of data science has led to significant automation in processes. Still, it has also brought the risk of overreliance on pre-programmed procedures, sometimes leading to the misuse of statistical methods.
Moreover, many practitioners entering credit risk modeling often overlook fundamental principles, hindering their professional development. Hence, the repository aims to serve as a centralized hub for continuous education and consolidating essential concepts.

The repository and book will encompass practical examples utilizing both `R` and `Python`.

Below are links providing an overview of the repository's main topics, which include summaries from the book and insights gleaned from practical experience.

<b>The Vasicek Distribution (Probability of Default Models)</b>:
- [The functional form and parameters estimation methods (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/vasicek_distribution/vasicek_distribution.pdf)
- [Shiny application for estimating the parameters of the Vasicek distribution](https://andrijadj.shinyapps.io/vasicek_distribution/)
- [Asset Correlation Estimation - Maximum Likelihood: Analytical vs Numerical Optimization Approach (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/vasicek_distribution/imm_vs_mle.pdf)
- [The Logistic Vasicek Distribution (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/vasicek_distribution/logistic_vasicek_distribution.pdf)
- [Asset Correlation Estimation - Maximum Likelihood: Normal vs Logistic Vasicek Distribution (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/vasicek_distribution/rho_normal_vs_logistic_vasicek.pdf)
- [Asset Correlation Estimators and Bias Quantification (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/vasicek_distribution/rho_bias_quantification.pdf)

<b>Loss Given Default</b>:
- [Loss Given Default as a Function of the Default Rate (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/lgd/lgd_as_a_function_of_dr.pdf)
- [The Vasicek LGD Model - The functional form and parameters estimation method (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/lgd/vasicek_lgd.pdf)

<b>Low Default Portfolios</b>:
- [Likelihood Approaches to Low Default Portfolios - Andrija Djurovic's Adjustment of Alan Forrest's Method to the Multi-Year Period Design (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/ldp/ldp_adj_af_adjustment.pdf)
    - [R code (functions)](https://github.com/andrija-djurovic/adsfcr/blob/main/ldp/ldp_adj_af_multi_year.R)
    - [Python code (functions)](https://github.com/andrija-djurovic/adsfcr/blob/main/ldp/ldp_adj_af_multi_year.py)
- [Conservative Estimation of Default Probabilities - BCR Method (pdf presentation, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/ldp/bcr.pdf)
    - [Simulation dataset](https://andrija-djurovic.github.io/adsfcr/ldp/BCR_TABLES.xlsx)
    - [R code (data & functions)](https://github.com/andrija-djurovic/adsfcr/blob/main/ldp/bcr.R)
    - [Python code (data & functions)](https://github.com/andrija-djurovic/adsfcr/blob/main/ldp/bcr.py)

<b>Measuring Concentration Risk</b>:
- [Measuring Concentration Risk - a partial portfolio approach (pdf presentation, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/concentration_risk/cr.pdf)
- [Simulation dataset](https://raw.githubusercontent.com/andrija-djurovic/adsfcr/main/concentration_risk/db.csv)
  

<b>Effective Interest Rate</b>:
- [Effective Interest Rate (html, `R` & `Python` code)](https://andrija-djurovic.github.io/adsfcr/effective_interest_rate/eir.html)
- [Effective Interest Rate (pdf, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/effective_interest_rate/eir.pdf)

<b>Loan Repayment Plan</b>:
- [Loan Repayment Plan (html, `R` & `Python` code)](https://andrija-djurovic.github.io/adsfcr/loan_repayment_plan/lrp.html)
- [Loan Repayment Plan (pdf, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/loan_repayment_plan/lrp.pdf)

<b>Model Development and Validation</b>:
- [Principal Component Analysis for IFRS9 Forward-Looking Modeling (pdf, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/model_dev_and_vld/pca.pdf)
- [Bootstrap Hypothesis Tests (html, GitHub page)](https://andrija-djurovic.github.io/adsfcr/model_dev_and_vld/bootstrap_ht.html)
- [Bootstrap Hypothesis Tests (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/model_dev_and_vld/bootstrap_ht.pdf)
- [Statistical Binning of Numeric Risk Factors (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/model_dev_and_vld/nrf_binning.pdf)
- [Hosmer-Lemeshow VS Z-score Test on Portfolio Level (html, GitHub slides)](https://andrija-djurovic.github.io/adsfcr/model_dev_and_vld/hl_vs_zscore.html#/)
- [Hosmer-Lemeshow VS Z-score Test on Portfolio Level (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/model_dev_and_vld/hl_vs_zscore.pdf)
- [Power Play: Probability of Default Predictive Ability Testing (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/model_dev_and_vld/statistical_power_of_pd_pp_tests.pdf)
- [Nested Dummy Encoding (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/model_dev_and_vld/nested_dummy_encoding.pdf)
- [Marginal Information Value (pdf, presentation)](https://github.com/andrija-djurovic/adsfcr/blob/main/model_dev_and_vld/marginal_information_value.pdf)

<b>OLS Regression</b>:
- [Consequences of Violating the Normality Assumption for OLS Regression (pdf, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/ols/normality.pdf)
- [Consequences of Heteroscedasticity for OLS Regression  (pdf, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/ols/heteroscedasticity.pdf)
- [Consequences of Multicollinearity for OLS Regression  (pdf, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/ols/multicollinearity.pdf)
- [Consequences of Autocorrelation for OLS Regression  (pdf, `R` & `Python` code)](https://github.com/andrija-djurovic/adsfcr/blob/main/ols/autocorrelation.pdf)
