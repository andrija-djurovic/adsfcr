import pandas as pd
import numpy as np
import math
from scipy.stats import beta, norm
from scipy.optimize import root_scalar

#data import
fp = "https://andrija-djurovic.github.io/adsfcr/model_dev_and_vld/BCR_TABLES.xlsx"
tbl_1 = pd.read_excel(io = fp, 
                      sheet_name="Table1")
tbl_2 = pd.read_excel(io = fp, 
                      sheet_name="Table2")
tbl_3 = pd.read_excel(io = fp, 
                      sheet_name="Table3")


#optimization function 
def opt_f(pd, n, k, theta, rho, T, cl, N):
    #simulated confidence interval
    cl_sim = 1 - np.mean([ss(pd, n, k, theta, rho, T) for _ in range(N)])
    #simulation error
    dev = cl_sim - cl
    return dev

def ss(pd, n, k, theta, rho, T):
    #systemic factor
    z = np.empty(T)
    z[0] = np.random.normal()
    #correlated systemic factor
    if T > 1:
        for j in range(1, T):
            z[j] = theta * z[j-1] + np.sqrt(1 - theta**2) * np.random.normal()
    #conditional pd
    pdc = (norm.ppf(pd) - z * np.sqrt(rho)) / np.sqrt(1 - rho)
    #cumulative probability of default
    pd_c = 1 - np.prod(1 - norm.cdf(x = pdc))
    #likelihood
    lh = binom_cum(n = n, 
                   p = pd_c, 
                   k = k)
    return lh

#likelihood of observing no more than k defaults out of n obligors
'''
#numerical solution
def binom_cum(n, p, k):
    #initialize bc
    bc = 0
    # P(x <= k)
    for j in range(k + 1):
        bc += math.comb(n, j) * (p ** j) * ((1 - p) ** (n - j))
    return bc
'''
#analytical solution
def binom_cum(n, p, k):
    bc = 1 - beta.cdf(p, k + 1, n - k)
    return bc
