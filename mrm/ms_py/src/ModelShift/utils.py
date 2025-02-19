import numpy as np
import pandas as pd

#data shift distribution
def ds_dist(db_s, data_shift):
    ds_rf = data_shift.columns[:-1]
    ns = db_s.groupby(ds_rf.tolist(), observed = True)["n"].transform(lambda x: x / x.sum())
    db_s = pd.merge(left = db_s, 
                    right = data_shift, 
                    on = ds_rf.tolist(), 
                    how = "left",
                    suffixes = ("", "_ds"))
    if db_s["n_ds"].isna().any():
        raise Error("data_shift contains incomplete information.")
    db_s["n_s"] = ns * db_s["n_ds"]
    return db_s

