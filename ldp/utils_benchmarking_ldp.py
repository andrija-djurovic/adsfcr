#confidence intervals for multinomial proportion
def mltnp_ci(tendency, cl):
    #frequency table
    ft  = np.unique(ar = tendency, 
                    return_counts = True)
    #number of observations
    n = sum(ft[1])
    #tendency indicator length (3)
    k = len(ft[1])
    #proportions
    p = ft[1] / n
    #confidence interval elements
    q_chi = stats.chi2.ppf(1 - (1 - cl) / k, df = 1)
    lci = (q_chi + 2 * ft[1] - np.sqrt(q_chi * (q_chi + 4 * ft[1] * (n - ft[1]) / n))) / (2 * (n + q_chi))
    uci = (q_chi + 2 * ft[1] + np.sqrt(q_chi * (q_chi + 4 * ft[1] * (n - ft[1]) / n))) / (2 * (n + q_chi))
    #summary table
    res = pd.DataFrame({"est": p, 
                        "lower": np.maximum(0, lci), 
                        "upper": np.minimum(1, uci)},
                       index = ft[0])
    
    return res

#average deviation confidence interval
def d_ci(deviation, cl):
    #frequency table
    ft  = np.unique(ar = deviation, 
                    return_counts = True)
    #number of obligors
    n = len(deviation)
    #deviation probabilities
    p = ft[1] / n
    #possible sums
    p_sums = np.arange(min(deviation).item() * n, max(deviation).item() * n + 1)
    #average deviation (D values)
    d_avg = p_sums / n
    #cumulative probabilities    
    cnv_res = convolve_p(p = p, 
                         n = n)
    cdf_avg = np.cumsum(cnv_res)
    #confidence level index
    idx_l = np.where(cdf_avg >= (1 - cl) / 2)[0][0]
    idx_u = np.where(cdf_avg >= (1 + cl) / 2)[0][0]
    
    #confidence interval for average deviation
    res = pd.DataFrame([{"est": np.mean(deviation), 
                        "lower": d_avg[idx_l], 
                        "upper": d_avg[idx_u]}]) 
    
    return res
#convolve n times function
def convolve_p(p, n):
    p_i = p
    for _ in range(1, n):
        p_i = np.convolve(a = p_i, 
                          v = p, 
                          mode = "full")
    return p_i