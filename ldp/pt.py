import numpy as np
from scipy.stats import beta, norm
from scipy.optimize import brentq

#optimization function 
def opt_f(pd, n, k, theta, rho, T, cl, N):
    #simulated confidence interval
    cl_sim = 1 - np.mean([ss(pd, n, k, theta, rho, T) for _ in range(N)])
    #simulation error
    dev = cl_sim - cl
    return dev

#single simulation
def ss(pd, n, k, theta, rho, T):
    #systemic factor
    z = np.empty(T)
    z[0] = np.random.normal()
    #correlated systemic factor
    if T > 1:
        for i in range(1, T):
            z[i] = theta * z[i-1] + np.sqrt(1 - theta**2) * np.random.normal()
    #conditional pd
    pdc = (norm.ppf(q = pd) - z * np.sqrt(rho)) / np.sqrt(1 - rho)
    #cumulative probability of default
    pd_c = 1 - np.prod(1 - norm.cdf(x = pdc))
    #likelihood
    lh = binom_cum(n = n, 
                   p = pd_c, 
                   k = k)
    return lh

#likelihood of observing no more than k defaults out of n obligors
def binom_cum(n, p, k):
    bc = 1 - beta.cdf(p, k + 1, n - k)
    return bc

#pluto-tasche ldp conservative estimates
def ldp_pt(n, k, theta, rho, T, cl, N, seed):
    #n     - number of obligors per rating
    #k     - number of defaults per rating
    #theta - year-to-year correlation
    #rho   - asset correlation
    #T     - number of years
    #cl    - confidence level
    #N     - number of simulations
    #seed  - random seed
    
    nr = len(n)
    n = [sum(n[i:nr]) for i in range(nr)]
    k = [sum(k[i:nr]) for i in range(nr)]
    res = [None]*nr
    for i in range(nr):
        np.random.seed(seed + i)
        n_i = n[i]
        k_i = k[i]
        res[i] = brentq(f = opt_f, 
                        args = (n_i, k_i, theta, rho, T, cl, N), 
                        a = 0,
                        b = 1)
    return res

