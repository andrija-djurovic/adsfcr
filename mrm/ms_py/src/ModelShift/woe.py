import numpy as np
import pandas as pd

#woe calculation on the aggregated table
def woe_agg_tbl(tbl, y, x, n, type_):
    rf_l = len(x)
    res = [None] * rf_l
    for i in range(rf_l):
        rf_i = x[i]
        tbl_i = tbl[[y, rf_i, n]].copy()
        if type_ == "binary":
            #number of bad cases 
            tbl_i["nb"] = np.where(tbl_i[y] == 0, 0, tbl_i[n])
        else:
            #number of bad cases 
            tbl_i["nb"] = tbl_i[n] * tbl_i[y]
        #number of good cases	
        tbl_i["ng"] = tbl_i[n] - tbl_i["nb"]
        #risk factor aggregation and woe calculation
        res_i = tbl_i.groupby(rf_i, as_index = False, observed = True).agg(
            no = (n, "sum"),
            ng = ("ng", "sum"),
            nb = ("nb", "sum")
            )
        res_i["pct.o"] = res_i["no"] / res_i["no"].sum()
        res_i["pct.g"] = res_i["ng"] / res_i["ng"].sum()
        res_i["pct.b"] = res_i["nb"] / res_i["nb"].sum()
        res_i["dr"] = res_i["nb"] / res_i["no"]
        so, sg, sb = res_i["no"].sum(), res_i["ng"  ].sum(), res_i["nb"].sum()
        res_i["dist.g"] = res_i["ng"] / sg
        res_i["dist.b"] = res_i["nb"] / sb
        res_i["woe"] = np.log(res_i["dist.g"] / res_i["dist.b"])
        res_i["iv.b"] = (res_i["dist.g"] - res_i["dist.b"]) * res_i["woe"]
        res_i["iv.s"] = res_i["iv.b"].sum()
        woe_v = dict(zip(res_i[rf_i], res_i["woe"]))
        woe_t = tbl_i[rf_i].map(woe_v).astype(float).values
        res[i] = woe_t
    res = pd.DataFrame({f"{col}_woe": res[idx] for idx, col in enumerate(x)})
    
    return res

#woe db_s encoding 
def woe_dbs_e(tbl, woe):
    rf = woe["rf"].unique()
    rf_l = len(rf)
    rf_woe = [f"{rf_i}_woe" for rf_i in rf]
    res = [None]*rf_l
    for i in range(rf_l):
        rf_i = rf[i]
        woe_i = woe[["rf", "bin", "woe"]].loc[woe["rf"] == rf_i, ["bin", "woe"]].drop_duplicates()
        woe_v = dict(zip(woe_i["bin"], woe_i["woe"]))
        res[i] = tbl[rf_i].map(woe_v).astype(float).values
    
    res = pd.DataFrame({rf_woe[idx]: res[idx] for idx in range(rf_l)})
    return res


#woe db encoding
def woe_db_e(db, db_s, rf):
    rf_l = len(rf)
    rf_woe = [f"{col}_woe" for col in rf]
    res = [None] * rf_l
    for i in range(rf_l):
        rf_i = rf[i]
        rf_woe_i = rf_woe[i] 
        woe_i = db_s[[rf_i, rf_woe_i]].drop_duplicates()
        woe_v = dict(zip(woe_i[rf_i], woe_i[rf_woe_i]))
        res[i] = db[rf_i].map(woe_v).astype(float).values
    res = pd.DataFrame({rf_woe[idx]: res[idx] for idx in range(rf_l)})
    
    return res
