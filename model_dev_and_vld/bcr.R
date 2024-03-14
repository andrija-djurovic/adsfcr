library(openxlsx)

#data import
fp <- "https://andrija-djurovic.github.io/adsfcr/model_dev_and_vld/BCR_TABLES.xlsx"
tbl.1 <- read.xlsx(xlsxFile = fp, 
                   sheet = "Table1")
tbl.2 <- read.xlsx(xlsxFile = fp, 
                   sheet = "Table2")
tbl.3 <- read.xlsx(xlsxFile = fp, 
                   sheet = "Table3")

#optimization function 
opt.f <- function(pd, n, k, theta, rho, T, cl, N) {
      #simulated confidence interval
      cl.sim = 1 - mean(replicate(n = N, 
                                  ss(pd = pd, 
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
      z[1] <- rnorm(1)
      #correlated systemic factor
      if    (T > 1) {
            for   (j in 2:T) {
                  z[j] <- theta * z[j-1] + sqrt(1 - theta^2) * rnorm(1)
                  }
            }
      #conditional pd
      pdc <- (qnorm(pd) - z*sqrt(rho)) / sqrt(1 - rho)
      #cumulative probability of default
      pd.c <- 1 - prod(1 - pnorm(q = pdc))
      #likelihood 
      lh <- binom.cum(n = n, 
                      p = pd.c, 
                      k = k)
return(lh)
}

#likelihood of observing no more than k defaults out of n obligors
#numerical solution
#binom.cum <-  function (n, p, k) {
#      #initiate bc
#      bc <- 0
#      #P(x <= k)
#      for   (j in 0:k) {
#            bc <-  bc + choose(n = n, k = j) * (p^j) * ((1 - p)^(n - j))
#	      }
#return(bc)
#}
#analytical solution
binom.cum <-  function (n, p, k) {
      bc <- 1 - pbeta(q = p, 
                      shape1 = k + 1, 
                      shape2 = n - k)
return(bc)
}
