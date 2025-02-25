import numpy as np
import pandas as pd
import warnings
from scipy.stats import norm, chi2
import nlopt

#----------portfolio, some defaults, multi-year, correlation (inter obligor and year-to-year)----------#
#likelihood function
def ll(pd, n, d):
    return np.prod((pd**d) * (1 - pd)**(n - d))
#single simulation
def ss(pd, n, d, rho, theta):
    #number of years
    T = len(n)
    #systemic factor
    z = np.empty(T)
    z[0] = np.random.normal()
    #correlated systemic factor
    if T > 1:
        for i in range(1, T):
            z[i] = theta * z[i-1] + np.sqrt(1 - theta**2) * np.random.normal()
    #conditional pd
    pd_c =  norm.cdf(x = (norm.ppf(q = pd) - z*np.sqrt(rho)) / np.sqrt(1 - rho))
    #likelihood
    ll_c = ll(pd = pd_c, 
              n = n, 
              d = d)
    return ll_c
#expectation of the vasicek multi-year model
def ev_my(pd, n, d, rho, theta, N):
    #N simulations
    sim = np.array([ss(pd, n, d, rho, theta) for _ in range(N)])
    #expectation
    ev = np.mean(sim)
    return ev
#maximum likelihood and pd
def mll_f(pd, grad, n, d, rho, theta, N):
    #likelihood for pd.r
    ll_s = ev_my(pd = pd,
                 n = n,
                 d = d,  
                 rho = rho, 
                 theta = theta, 
                 N = N)
    return(-ll_s)
#pd upper bound
def pd_ub(pd, grad, n, d, rho, theta, mll, cl, N):
    #cutpoint
    if sum(d) == 0:
        cp = -2 * np.log(1 - cl)
    else:
        cp = chi2.ppf(q = cl, df = 1)
    #likelihood for pd_r
    ll_s = ev_my(pd = pd, 
                 n = n, 
                 d = d, 
                 rho = rho, 
                 theta = theta, 
                 N = N)
    #likelihood ratio
    lr = -2 * np.log(ll_s / mll)
    #minimization metric
    res = (lr - cp)**2

    return res