#power of heterogeneity test - analytical solution
def ht_power_a(n1, n2, p1, p2, alpha):
    delta = p1 - p2
    q1 = 1 - p1
    q2 = 1 - p2
    n_fac = 1 / n1 + 1 / n2
    z = norm.ppf(1 - alpha)
    p_bar = (n1 * p1 + n2 * p2) / (n1 + n2)
    q_bar = 1 - p_bar
    pwr = norm.cdf((-z * np.sqrt(p_bar * q_bar * n_fac) - delta) / 
                   np.sqrt((p1 * q1) / n1 + (p2 * q2) / n2))
    return pwr

#power of heterogeneity test - monte-carlo simulation
def ht_power_s(n1, n2, p1, p2, alpha, sim, seed):
    res = np.full(sim, np.nan)
    for i in range(sim):
        np.random.seed(seed + i)
        x1 = np.random.binomial(n = 1, 
                                p = p1, 
                                size = n1)
        x2 = np.random.binomial(n = 1, 
                                p = p2, 
                                size = n2)
        count = np.array([np.sum(x1), np.sum(x2)])
        nobs = np.array([n1, n2])
        stat, p_value = proportions_ztest(count = count,
                                          nobs = nobs, 
                                          alternative = "smaller")
        res[i] = p_value 
    pwr = np.mean(res < alpha)
    return pwr

