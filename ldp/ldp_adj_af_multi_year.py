import numpy as np
import pandas as pd
import warnings
from scipy.stats import norm, chi2

#suppress warning
warnings.filterwarnings("ignore", category = RuntimeWarning)

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

#pd inverval
def pd_interval(pd_r, n, d, rho, theta, cl, N):
    #cutpoint
    if sum(d) == 0:
        cp = -2 * np.log(1 - cl)
    else:
        cp = chi2.ppf(q = cl, df = 1)
    #likelihood for pd_r
    ll_s = np.array([ev_my(pd_s, n, d, rho, theta, N) for pd_s in pd_r])
    #maximum likelihood
    mll = np.max(ll_s)
    pd_mll = pd_r[np.where(ll_s == mll)][0]
    #likelihood ratio
    lr = -2 * np.log(ll_s / mll)
    #find interval
    lr_i = np.where(lr < cp)[0]
    pd_i = (np.min(pd_r[lr_i]), np.max(pd_r[lr_i]))
    #result summary
    res = {"ll": ll_s,
           "lr": lr,
           "pd_mll": pd_mll,
           "pd_i": pd_i}
    return res