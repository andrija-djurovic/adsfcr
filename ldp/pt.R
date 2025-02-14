#optimization function 
opt.f <- function(pd, n, k, theta, rho, T, cl, N) {
      #simulated confidence interval
      cl.sim = 1 - mean(replicate(n = N, 
                                  expr = ss(pd = pd, 
                                            n = n, 
                                            k = k, 
                                            theta = theta, 
                                            rho = rho, 
                                            T = T)))
      #simulation error
      dev <- cl.sim - cl
return(dev)
}

#single simulation
ss <- function(pd, n, k, theta, rho, T) {
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
      pdc <- (qnorm(p = pd) - z*sqrt(rho)) / sqrt(1 - rho)
      #cumulative probability of default
      pd.c <- 1 - prod(1 - pnorm(q = pdc))
      #likelihood 
      lh <- binom.cum(n = n, 
                      p = pd.c, 
                      k = k)
return(lh)
}

#likelihood of observing no more than k defaults out of n obligors
binom.cum <-  function (n, p, k) {
      bc <- 1 - pbeta(q = p, 
                      shape1 = k + 1, 
                      shape2 = n - k)
return(bc)
}

#pluto-tasche ldp conservative estimates
ldp.pt <- function(n, k, theta, rho, T, cl, N, seed) {
      #n     - number of obligors per rating
      #k     - number of defaults per rating
      #theta - year-to-year correlation
      #rho   - asset correlation
      #T     - number of years
      #cl    - confidence level
      #N     - number of simulations
      #seed  - random seed

      nr <- length(n)
      n <- sapply(X = 1:nr,
                  FUN = function(x) sum(n[x:nr]))
      k <- sapply(X = 1:nr,
                  FUN = function(x) sum(k[x:nr]))
      res <- rep(x = NA, times = nr)
      for   (i in 1:nr) {
            set.seed(seed + i)
            n.i <- n[i]
            k.i <- k[i]
            res.i <- uniroot(f = opt.f, 
                             interval = c(0, 1), 
                             n = n.i,               
                             k = k.i,            
                             theta = theta, 
                             rho = rho, 
                             T = T, 
                             cl = cl, 
                             N = N)
            res[i] <- res.i[[1]]
            }
return(res)
}
