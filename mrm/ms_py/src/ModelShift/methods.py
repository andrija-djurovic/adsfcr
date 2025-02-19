import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
from patsy import dmatrix

from .utils import *
from .woe import *

#matrix multiplication (first-order approximation) method
def mm_m(db, target, rf, data_shift, encoding, woe_tbl, lr_i): 
    #db summary table
    db_s = db.groupby(rf, observed = True).agg(
               n =  (target, "size"),
               dr = (target, "mean")).reset_index()
    #distribution of data shift
    db_s = ds_dist(db_s = db_s, 
                   data_shift = data_shift)
    #initial proportions
    pn_1 = (db_s["n"] * db_s["dr"]) / db_s["n"].sum()
    pn_0 = (db_s["n"] * (1 - db_s["dr"])) / db_s["n"].sum()
    #shifted proportions
    pn_s_1 = (db_s["n_s"] * db_s["dr"]) / db_s["n_s"].sum()
    pn_s_0 = (db_s["n_s"] * (1 - db_s["dr"])) / db_s["n_s"].sum()
    #proportions change
    dx_p = pn_1 - pn_s_1  #dx plus 
    dx_m = pn_0 - pn_s_0  #dx minus
    #encoding
    if encoding == "WoE":
       if woe_tbl is not None:
          woe_e = woe_dbs_e(tbl = db_s, 
                            woe = woe_tbl)
       else:
          woe_e = woe_agg_tbl(tbl = db_s, 
                              y = "dr", 
                              x = rf, 
                              n = "n", 
                              type_= "frac")
       db_s = pd.concat([db_s, woe_e], axis = 1)
       db = pd.concat([db, woe_db_e(db = db, 
                                    db_s = db_s, 
                                    rf = rf)], axis = 1)
       frm = f"dr ~ {' + '.join([f'{col}_woe' for col in rf])}"
    else:
       frm = f"dr ~ {' + '.join(rf)}"
         
    if (lr_i == None):
        lr_i = smf.glm(formula = frm, 
                       data = db_s, 
                       freq_weights = db_s["n"], 
                       family = sm.families.Binomial()).fit()        
        
    #add model predictions for the linear predictor (link)
    db_c = db.copy()
    db_c["lgod"] = lr_i.predict(exog = db_c, which = "linear")
    #add model predictions for the probability (response)
    db_c["prob"] = lr_i.predict(exog = db_c)
    #data points
    x = db_c.groupby(rf, observed = True).agg(
          {target: [
            ("1", lambda x: (x == 1).sum() / db.shape[0]),
            ("0", lambda x: (x == 0).sum() / db.shape[0]),
            ]}).reset_index()
    x.columns = [col[0] if col[1] == "" else col[1] for col in x.columns]
    #model points
    y = db_c.groupby(rf, observed = True).agg(
          {"prob": [
           ("1", lambda x: x.sum() / db.shape[0]),
           ("0", lambda x: (1 - x).sum() / db.shape[0]),
           ]}).reset_index()
    y.columns = [col[0] if col[1] == "" else col[1] for col in y.columns]
    #design matrix (N x M)
    if encoding == "WoE":
       D = pd.DataFrame(
             np.column_stack([np.ones(len(db_s)), db_s[[f"{col}_woe" for col in rf]].values]),
             columns = ["Intercept"] + [f"{col}_woe" for col in rf]
             )
    else:
       frm_dm = " ~ 1 + " + " + ".join(rf)
       D = dmatrix(formula_like = frm_dm, 
                   data = db_s,
                   return_type = "dataframe")
    #diagonal matrix for y(a,1)   
    Yplus = np.diag(y["1"])
    #diagonal matrix for y(a,-1) 
    Yminus = np.diag(y["0"])
    #adjust for zeros
    np.fill_diagonal(Yplus, np.where(np.diag(Yplus) == 0, 1e-10, np.diag(Yplus)))
    np.fill_diagonal(Yminus, np.where(np.diag(Yminus) == 0, 1e-10, np.diag(Yminus)))
    #diagonal matrix of modeled odds ratios
    Z = Yplus @ np.linalg.inv(Yminus)
    #identity matrix 
    I = np.eye(len(Z))
    #Y matrix   
    Y = np.linalg.inv(I + Z) @ np.linalg.inv(I + np.linalg.inv(Z)) @ \
        (Yplus + Yminus)
    #M x M matrix C
    C = D.T @ Y @ D
    #compute dp (model parameter shift)
    term1 = np.linalg.inv(I + Z) @ dx_p
    term2 = np.linalg.inv(I + np.linalg.inv(Z)) @ dx_m
    ms = np.linalg.inv(C) @ D.T @ (term1 - term2)
    ms.index = D.columns
    
    return({"ms": ms, "db_s": db_s})


#weighted binomial regression method
def wbr_m(db, target, rf, data_shift, encoding, woe_tbl, lr_i):
    #db summary table
    db_s = db.groupby(rf + [target], 
                       observed = True).size().reset_index(name = "n")
    
    #distribution of data shift
    db_s = ds_dist(db_s = db_s, 
                   data_shift = data_shift)
    #encoding
    if encoding == "WoE":
        if woe_tbl is not None:
           woe_e = woe_dbs_e(tbl = db_s, 
                             woe = woe_tbl)
        else:
           woe_e = woe_agg_tbl(tbl = db_s, 
                               y = target, 
                               x = rf, 
                               n = "n", 
                               type_ = "binary")
        db_s = pd.concat([db_s, woe_e], axis = 1)
        frm = target + " ~ " + " + ".join([f"{col}_woe" for col in rf])
        cnts = None
    else:
        frm = target + " ~ " + " + ".join(rf)
    
    #binomial regression - initial
    if lr_i is None: 
       lr_i = smf.glm(formula = frm,
                      family = sm.families.Binomial(),
                      data = db_s,
                      freq_weights = db_s["n"]).fit()
    lr_i_c = lr_i.params
    
    #binomial regression - simulation 
    lr_s = smf.glm(formula = frm,
                   family = sm.families.Binomial(),
                   data = db_s,
                   freq_weights = db_s["n_s"]).fit()
    lr_s_c = lr_s.params
    #model shift
    ms = lr_i_c - lr_s_c
    #result summary
    res = {'lr_i': lr_i, 'lr_s': lr_s, 'ms': ms, 'db_s': db_s}
    
    return res

#weighted quasi-binomial (fractional) regression method
def wfr_m(db, target, rf, data_shift, encoding, woe_tbl, lr_i):
    #db summary table
    db_s = db.groupby(rf, observed = True).agg( 
        n = (target, "size"), 
        frac = (target, "mean")).reset_index()
    #distribution of data shift
    db_s = ds_dist(db_s = db_s, 
                   data_shift = data_shift)
    #encoding
    if encoding == "WoE":
        if woe_tbl is not None:
           woe_e = woe_dbs_e(tbl = db_s, 
                             woe = woe_tbl)
        else:
           woe_e = woe_agg_tbl(tbl = db_s, 
                               y = "frac", 
                               x = rf, 
                               n = "n", 
                               type_ = "frac")
        db_s = pd.concat([db_s, woe_e], axis=1)
        frm = "frac ~ " + " + ".join([f"{col}_woe" for col in rf])
    else:
        frm = "frac" + " ~ " + " + ".join(rf)
    #quasi-binomial regression - initial
    if lr_i is None: 
       lr_i = smf.glm(formula = frm,
                      family = sm.families.Binomial(),
                      data = db_s,
                      freq_weights = db_s["n"]).fit(scale = "X2")
    lr_i_c = lr_i.params
    
    #quasi-binomial regression - simulation 
    lr_s = smf.glm(formula = frm,
                   family = sm.families.Binomial(),
                   data = db_s,
                   freq_weights = db_s["n_s"]).fit(scale = "X2")
    lr_s_c = lr_s.params
    #model shift
    ms = lr_i_c - lr_s_c
    #result summary
    res = {'lr_i': lr_i, 'lr_s': lr_s, 'ms': ms, 'db_s': db_s}
    
    return res
