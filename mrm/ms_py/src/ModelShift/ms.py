import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
from patsy import dmatrix

from .checks import *
from .methods import *
from .utils import *
from .woe import *

def ms_pd(db, target, rf, data_shift, encoding, method, woe_tbl = None, lr_i = None): 
    """
    ms_pd performs testing of predictive power of the PD rating model. 
    
        Parameters:
        ------------
            db: Modeling dataset.
            target: Vector of target (dependent variable) name.
            rf: Vector of risk factor names.
            data_shift: A data frame with column names from `rf`, and with the 
            last column named `n`.
            encoding: Encoding method with the available options: `dummy` and `WoE`.
            method: Model shift method with the available options: `mm` 
            (matrix multiplication), `wbr` (weighted binomial regression), 
            `wfr` (weighted fractional regression).
            woe_tbl: The manually created WoE table. A data frame with three 
            columns: `"rf"`, `"bin"`, and `"woe"`. The default value is `None`.
            lr_i: The glm object of the initial model. The default is None. 
            If supplied, the function uses the given model instead of estimating it.
    
        Returns:
        ------------
           For the selected method `mm`, the command `ms_pd` returns: 
           model shift (`ms`) and summary table (`db.s`). 
           For the selected methods `wbr` and `wfr`, the command `ms_pd` returns: 
           initial model (`lr_i`), simulated model (`lr_s`), model shift (`ms`), 
           and summary table (`db.s`).
    
    """
      
    #input checks 
    checks_init(db = db, 
                target = target, 
                rf = rf, 
                data_shift = data_shift, 
                encoding = encoding, 
                method = method,
                woe_tbl = woe_tbl)
    
    #names checks
    target = list(check_names([target]))[0]
    rf = list(check_names(rf))
    db_n = check_names(db.columns)
    db.columns = [db_n.get(x) for x in db.columns]
    db_n = check_names(data_shift.columns[:-1])
    data_shift.columns =  [db_n.get(x) for x in data_shift.columns[:-1]] + \
                          [data_shift.columns[-1]]
    if woe_tbl is not None:
       woe_tbl["rf"] = woe_tbl["rf"].map(check_names(x = woe_tbl["rf"])).values
    
    #model shift
    if method == "mm": 
       res = mm_m(db = db, 
                  target = target, 
                  rf = rf, 
                  data_shift = data_shift, 
                  encoding = encoding, 
                  woe_tbl = woe_tbl, 
                  lr_i = lr_i)
    if method == "wbr": 
       res = wbr_m(db = db, 
                   target = target, 
                   rf = rf, 
                   data_shift = data_shift, 
                   encoding = encoding, 
                   woe_tbl = woe_tbl, 
                   lr_i = lr_i)
    if method == "wfr": 
       res = wfr_m(db = db, 
                   target = target, 
                   rf = rf, 
                   data_shift = data_shift, 
                   encoding = encoding, 
                   woe_tbl = woe_tbl, 
                   lr_i = lr_i)
     
    return(res)


