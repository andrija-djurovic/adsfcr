library(nloptr)

#----------portfolio, some defaults, multi-year, correlation (inter obligor and year-to-year)----------#
#likelihood function
ll <- function(pd, n, d) {
      prod((pd^d)*(1 - pd)^(n - d))	
}
#single simulation
ss <- function(pd, n, d, rho, theta) {
      #number of years
      T <- length(n)
      #systemic factor
      z <- rep(NA, T)
      z[1] <- rnorm(n = 1)
      #correlated systemic factor
      if    (T > 1) {
            for   (i in 2:T) {
                  z[i] <- theta * z[i-1] + sqrt(1 - theta^2) * rnorm(n = 1)
                  }
            }
      #conditional pd
      pd.c <- pnorm(q = (qnorm(p = pd) - z*sqrt(rho)) / sqrt(1 - rho))
      #likelihood
      ll.c <- ll(pd = pd.c, 
                 n = n, 
                 d = d)
return(ll.c)
}
#expectation of the vasicek multi-year model
ev.my <- function(pd, n, d, rho, theta, N) {
      #N simulations
      sim <- replicate(n = N, 
                       exp = ss(pd = pd, 
                                n = n,
                                d = d, 
                                rho = rho, 
                                theta = theta)
                       )
      #expectations
      ev <- mean(sim)        
return(ev)
}
#maximum likelihood and pd
mll.f <- function(pd, n, d, rho, theta, N) {
      #likelihood for pd.r
      ll.s <- ev.my(pd = pd,
                    n = n,
                    d = d,  
                    rho = rho, 
                    theta = theta, 
                    N = N)
return(-ll.s)
}
#pd upper bound
pd.ub <- function(pd, n, d, rho, theta, mll, cl, N) {
      #cutpoint
      if    (sum(d) == 0) {
             cp <- -2*log(1 - cl)
             } else {
             cp <- qchisq(p = cl, df = 1)
             }
      #likelihood for pd.r
      ll.s <- ev.my(pd = pd,
                    n = n,
                    d = d,  
                    rho = rho, 
                    theta = theta, 
                    N = N)
      #likelihood ratio
      lr <- -2*log(ll.s / mll)
      #minimization metric
      res <- (lr - cp)^2
return(res)
}