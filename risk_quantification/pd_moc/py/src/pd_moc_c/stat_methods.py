import pandas as pd
import numpy as np
from scipy.stats import norm, beta

def lra_nf(odr, cl):
    odr = np.array(odr)
    odr_m = np.mean(odr)
    odr_m_se = np.std(odr, ddof = 1) / np.sqrt(len(odr))
    moc = norm.ppf(cl) * odr_m_se
    res = pd.DataFrame({"lra": [odr_m], "moc": [moc]})
    return res

def lra_ne(odr, cl, ess_factor):
    odr = np.array(odr)
    odr_m = np.mean(odr)
    odr_m_se = np.std(odr, ddof = 1) / np.sqrt(len(odr) / ess_factor)
    moc = norm.ppf(cl) * odr_m_se
    res = pd.DataFrame({"lra": [odr_m], "moc": [moc]})
    return res

def odr_jeffreys_ci(odr, n, cl):
    odr = np.array(odr)
    n = np.array(n)
    odr_m = np.mean(odr)
    jub = beta.ppf(q = cl, 
                   a = n * odr + 0.5, 
                   b = n - n * odr + 0.5)
    moc = np.mean(jub) - np.mean(odr)
    res = pd.DataFrame({"lra": [odr_m], "moc": [moc]})
    return res

def odr_clopper_pearson_ci(odr, n, cl):
    odr = np.array(odr)
    n = np.array(n)
    odr_m = np.mean(odr)
    cpub = beta.ppf(q = cl, 
                    a = n * odr + 1, 
                    b = n - n * odr)
    moc = np.mean(cpub) - np.mean(odr)
    res = pd.DataFrame({"lra": [odr_m], "moc": [moc]})
    return res

def odr_na_ci(odr, n, cl):
    odr = np.array(odr)
    n = np.array(n)
    odr_m = np.mean(odr)
    nub = odr + norm.ppf(cl) * np.sqrt((odr * (1 - odr)) / n) 
    moc = np.mean(nub) - odr_m
    res = pd.DataFrame({"lra": [odr_m], "moc": [moc]})
    return res

def odr_mc(odr, n, cl, sim):
    odr = np.array(odr)
    n = np.array(n)
    odr_m = np.mean(odr)
    nd = odr * n
    T = len(odr)
    odr_m_s = np.repeat(np.nan, int(sim))
    for i in range(int(sim)):
        odr_s = np.repeat(np.nan, T)
        for t in range(T):
            n_t = n[t]
            d_t = np.random.binomial(n = 1, size = int(n_t), p = odr[t]).sum()
            odr_t = d_t / n_t
            if np.round(odr_t, 6) == 0:
                odr_s[t] = 1 / 1e6
            elif np.round(odr_t, 6) == 1:
                odr_s[t] = 1 - 1 / 1e6
            else:
                odr_s[t] = odr_t
        odr_m_s[i] = np.mean(odr_s)
    moc = np.quantile(odr_m_s, cl) - odr_m
    res = pd.DataFrame({"lra": [odr_m], "moc": [moc]})
    return res

def odr_al(odr, n, cl):
    odr_m = np.mean(odr)
    T = len(odr)
    odr_m_se = np.sqrt(1 / T**2 * (odr_m * (1 - odr_m) * np.sum(1 / np.array(n))))
    moc = norm.ppf(cl) * odr_m_se
    res = pd.DataFrame({'lra': [odr_m], 'moc': [moc]})
    return res

def lra_boot_ind(odr, cl, sim):
    odr     = np.array(odr)
    odr_m   = np.mean(odr)
    odr_m_s = np.repeat(np.nan, int(sim))
    for i in range(int(sim)):
        odr_m_s[i] = np.mean(np.random.choice(odr, size = len(odr), replace = True))
    moc = np.quantile(odr_m_s, cl) - odr_m
    res = pd.DataFrame({"lra": [odr_m], "moc": [moc]})
    return res

def lra_odr_vasicek(pd_, n, rho, phi, cl, sim):
    n = np.array(n)
    T = len(n)
    odr_m_s = np.repeat(np.nan, int(sim))
    for i in range(int(sim)):
        pd_c_s = sim_pd_vasicek(pd_ = pd_, 
                                rho = rho, 
                                phi = phi, 
                                T = T)
        odr_s = np.repeat(np.nan, T)
        for t in range(T):
            n_t = n[t]
            d_t = np.random.binomial(n = 1 , 
                                     size = int(n_t), 
                                     p = pd_c_s[t]).sum()
            odr_t = d_t / n_t
            
            if np.round(odr_t, 6) == 0:
                odr_s[t] = 1 / 1e6
            elif np.round(odr_t, 6) == 1:
                odr_s[t] = 1 - 1 / 1e6
            else:
                odr_s[t] = odr_t
        odr_m_s[i] = np.mean(odr_s)
    moc = np.quantile(odr_m_s, cl) - pd_
    res = pd.DataFrame({"lra": [pd_], "moc": [moc]})
    return res
def sim_pd_vasicek(pd_, rho, phi, T):
    z = np.repeat(np.nan, T)
    z[0] = np.random.normal()
    for i in range(1, T):
        z[i] = phi * z[i-1] + np.sqrt(1 - phi**2) * np.random.normal()
    pd_c = norm.cdf((norm.ppf(pd_) - np.sqrt(rho) * z) / np.sqrt(1 - rho))
    return pd_c
