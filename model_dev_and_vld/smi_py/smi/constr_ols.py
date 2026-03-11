import pandas as pd
import numpy as np
from scipy.optimize import minimize

#ssq function
def ssq(beta_coef, X, y, weights):
    resid = y - X @ beta_coef
    resid_w = 0.5 * np.sum(weights * resid ** 2)
    return resid_w


#constrained ols regression
def constr_ols(db, target, predictors, lower, upper, weights):
    X = np.column_stack([np.ones(len(db)), db[predictors].values])
    y = db[target].values
    lower = np.concatenate(([-np.inf], lower))
    upper = np.concatenate(([np.inf], upper))
    cc = np.isfinite(np.column_stack([y, X])).all(axis = 1)

    #initial values
    db_i = pd.DataFrame(np.column_stack([y, X]),
                        columns = ["y"] + list(range(X.shape[1])))
    db_i = db_i[cc]
    y_lm = db_i["y"].values
    X_lm = db_i.iloc[:, 1:].values
    beta_start = np.linalg.lstsq(X_lm, y_lm, rcond = None)[0]
    #constrained ols
    opt = minimize(fun = ssq,
                   x0 = beta_start,
                   args = (X[cc, :], y[cc], weights[cc]),
                   bounds = list(zip(lower, upper)),
                   method="L-BFGS-B")
    #betas
    beta_opt = opt.x
    beta_names = ["(Intercept)"] + predictors
    #model fit
    pred_opt = X @ beta_opt
    #r-squared
    r_squared = np.corrcoef(y, pred_opt)[0, 1] ** 2
    #loglikelihood
    n = np.sum(cc)
    k = np.sum(np.abs(beta_opt[1:]) > 1/1e6) + 2
    rss = np.nansum((y - pred_opt)**2)
    sigma_hat = rss / n
    logL = -n/2 * (np.log(2*np.pi) + np.log(sigma_hat) + 1)
    #aic
    aic = 2 * k - 2 * logL
    #bic
    bic = np.log(n) * k - 2 * logL
    #summary
    res = {"beta": dict(zip(beta_names, beta_opt)),
           "pred": pred_opt,
           "r.squared": r_squared,
           "aic": aic,
           "bic": bic}

    return res


#constrained models estimation
def model_est(gr_c, ps, db, target, weights):
    smi_r = len(gr_c)
    res = [None] * smi_r
    pred = [None] * smi_r

    for i in range(smi_r):
        predi_i = list(gr_c[i])

        #predictor name
        pred_n = pd.Series(predi_i).str.replace(r"_lag[1-4]$", "", regex = True).values

        #lower and upper bounds
        lower = []
        upper = []
        for j in range(len(pred_n)):
            ps_j = ps[pred_n[j]]
            if ps_j == "+":
                lower.append(0)
                upper.append(np.inf)
            if ps_j == "-":
                lower.append(-np.inf)
                upper.append(0)
            if ps_j == "+/-":
                lower.append(-np.inf)
                upper.append(np.inf)

        #constrained ols
        res_i = constr_ols(db = db,
                           target = target,
                           predictors = predi_i,
                           lower = np.array(lower),
                           upper = np.array(upper),
                           weights = weights)

        pred[i] = res_i["pred"]

        #summary
        res_df = pd.DataFrame({"model.id": f"Model_{i+1}",
                               "coefficient": list(res_i["beta"].keys()),
                               "estimate": list(res_i["beta"].values()),
                               "r.squared": res_i["r.squared"],
                               "aic": res_i["aic"],
                               "bic": res_i["bic"],
                                "zero.coeff": any(np.round(list(res_i["beta"].values()), 6) == 0)})

        res_df["predictor"] = res_df["coefficient"].str.replace(r"_lag[1-4]$", "", regex = True)
        res_df["lag"] = get_lag(res_df["coefficient"].values)

        res[i] = res_df

    res = pd.concat(res, ignore_index=True)

    return {"models": res, "pred": pred}
