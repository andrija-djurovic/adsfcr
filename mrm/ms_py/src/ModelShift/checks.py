import numpy as np
import pandas as pd

#checks
class Error(Exception):
    """Check errors"""
    pass

def checks_init(db, target, rf, data_shift, encoding, method, woe_tbl):
    eo = {"dummy", "WoE"}
    mo = {"mm", "wbr", "wfr"}
    #object types
    cond_01 = not isinstance(db, pd.DataFrame) or \
              not isinstance(data_shift, pd.DataFrame) 
    #missing values
    cond_02 = db.isna().sum().sum() > 0 or \
              data_shift.isna().sum().sum() > 0
    #available options
    cond_03 = encoding not in eo
    cond_04 = method not in mo
    #target
    y = db[target]
    cond_05 = not set(y.unique()).issubset({0, 1})
    #rf and target names
    cond_06 = any(col not in db.columns for col in rf + [target]) or \
              any(col not in db.columns for col in data_shift.columns[:-1])
    #rf type
    cond_07 = any(~db[rf].dtypes.apply(lambda x: x.name in ["category", "object"]))
    cond_08 = any(~data_shift.iloc[:, :-1].dtypes.apply(lambda x: x.name in ["category", "object"]))
    
    #data_shift last column
    cond_09 = data_shift.columns[-1] != "n"
    #woe table
    if woe_tbl is None:
        cond_10 = False
    else:
        ex_n = {"rf", "bin", "woe"}
        cond_10 = not ex_n.issubset(set(woe_tbl.columns))
    #summary
    cond_all = [cond_01, cond_02, cond_03, cond_04, cond_05, 
                cond_06, cond_07, cond_08, cond_09, cond_10]
    #error checks
    error_messages = {
        1: "db or data_shift is not a DataFrame.",
        2: "db or data_shift contains missing values.",
        3: "Available options for encoding are: dummy, WoE.",
        4: "Available options for method are: mm, wbr, wfr.",
        5: "Target is not a binary (0/1) variable.",
        6: "rf or target argument does not match column names in db or data_shift.",
        7: "rf in db must be of character (object) or categorical type.",
        8: "rf in data_shift must be of character (object) or categorical type.",
        9: "The last column of data_shift must be named 'n'.",
        10: "woe_tbl column names must include: rf, bin, woe."
        }
    for i, cond in enumerate(cond_all, start = 1):
        if cond:
            raise Error(error_messages[i])
    
    return None

def check_names(x):
    names_c = []
    for i in list(range(len(x))):
        s_i = x[i]
        s_i = "".join([c if c.isalnum() else " " for c in s_i])
        s_i = s_i.strip()
        s_i = s_i.replace(" ", "_")
        names_c.append(s_i)
    names_dict = dict(zip(x, names_c))
    return(names_dict)


