#'@importFrom stats rnorm qnorm pnorm qbeta rbinom 
#'@export
lra_nf <- function(odr, cl) {
      odr.m <- mean(odr)
      odr.m.se <- sd(odr) / sqrt(length(odr))
      moc <- qnorm(p = cl) * odr.m.se
      res <- data.frame(lra = odr.m, moc = moc)
return(res)
}

#'@importFrom stats rnorm qnorm pnorm qbeta rbinom 
#'@export
lra_ne <- function(odr, cl, ess_factor) {
      odr.m <- mean(odr)
      odr.m.se <- sd(odr) / sqrt(length(odr) / ess_factor)
      moc <- qnorm(p = cl) * odr.m.se
      res <- data.frame(lra = odr.m, moc = moc)
return(res)
}

#'@importFrom stats qnorm pnorm qbeta rbinom 
#'@export
odr_jeffreys_ci <- function(odr, n, cl) {
      odr_m <- mean(odr)
      jub <- qbeta(p = cl,
                   shape1 = n*odr + 0.5,
                   shape2 = n - n*odr + 0.5)
      moc <- mean(jub) - mean(odr)
      res <- data.frame(lra = odr_m, moc = moc)
return(res)     
}

#'@importFrom stats rnorm qnorm pnorm qbeta rbinom 
#'@export
odr_clopper_pearson_ci <- function(odr, n, cl) {
      odr_m <- mean(odr)
      cpub <- qbeta(p = cl,
                    shape1 = n*odr + 1,
                    shape2 = n - n*odr)
      moc <- mean(cpub) - mean(odr)
      res <- data.frame(lra = odr_m, moc = moc)
return(res)     
}

#'@importFrom stats rnorm qnorm pnorm qbeta rbinom  
#'@export
odr_na_ci <- function(odr, n, cl) {
      odr_m <- mean(odr)
      nub <- odr + qnorm(cl) * sqrt((odr*(1 - odr))/n)
      moc <- mean(nub) - odr_m
      res <- data.frame(lra = odr_m, moc = moc)
return(res)
}

#'@importFrom stats rnorm qnorm pnorm qbeta rbinom 
#'@export
odr_mc <- function(odr, n, cl, sim) {
      odr_m <- mean(odr)
      nd <- odr * n 
      T <- length(odr)
      odr_m_s <- rep(NA, sim)
      for   (i in 1:sim) {
            odr_s <-  rep(NA, T)
            for   (t in 1:T) { 
                  n_t <- n[t]
                  d_t <- rbinom(n = 1, 
                                size = n_t, 
                                prob = odr[t])
                  odr_t <- d_t / n_t
                  odr_s[t] <- ifelse(round(odr_t, 6) == 0, 1/1e6, 
                              ifelse(round(odr_t, 6) == 1, 1 - 1/1e6, odr_t))                  
                  }
            odr_m_s[i] <- mean(odr_s)
            }
      moc <- unname(quantile(x = odr_m_s, prob = cl)) - odr_m 
      res <- data.frame(lra = odr_m, moc = moc)
return(res)
}

#'@importFrom stats rnorm qnorm pnorm qbeta rbinom 
#'@export
odr_al <- function(odr, n, cl) {
      odr_m <- mean(odr)
      T <- length(odr)
      odr_m_se <- sqrt(1/T^2 * (odr_m * (1 - odr_m) * sum(1 / n)))
      moc <- qnorm(p = cl) * odr_m_se
      res <- data.frame(lra = odr_m, moc = moc)
return(res)
}

#'@export
lra_boot_ind <- function(odr, cl, sim) {
      odr_m <- mean(odr)
      odr_m_s <- rep(NA, sim)
      for   (i in 1:sim) {
            odr_m_s[i] <- mean(sample(x = odr, replace = TRUE))
            }
      moc <- unname(quantile(x = odr_m_s, prob = cl)) - odr_m 
      res <- data.frame(lra = odr_m, moc = moc)
return(res)     
} 
   
#'@importFrom stats rnorm qnorm pnorm qbeta rbinom
#'@export
lra_odr_vasicek <- function(pd, n, rho, phi, cl, sim) {
      T <- length(n)
      odr_m_s <- rep(NA, sim)
      for   (i in 1:sim) {
            pd_c_s <- sim_pd_vasicek(pd = pd, 
                                    rho = rho, 
                                    phi = phi, 
                                    T = T)
            odr_s <-  rep(NA, T)
            for   (t in 1:T) { 
                  n_t <- n[t]
                  d_t <- rbinom(n = 1, 
                                size = n_t, 
                                prob = pd_c_s[t])
                  odr_t <- d_t / n_t
                  odr_s[t] <- ifelse(round(odr_t, 6) == 0, 1/1e6, 
                              ifelse(round(odr_t, 6) == 1, 1 - 1/1e6, odr_t))                  
                  }
            odr_m_s[i] <- mean(odr_s)
            }
      moc <- unname(quantile(x = odr_m_s, prob = cl)) - pd 
      res <- data.frame(lra = pd, moc = moc)
return(res) 
}
sim_pd_vasicek <- function(pd, rho, phi, T) {
      z <- rep(NA, T)             
      z[1] <- rnorm(n = 1)
      for   (i in 2:T) {
             z[i] <- phi * z[i-1] + sqrt(1 - phi^2) * rnorm(n = 1)
             }
      pd_c <- pnorm((qnorm(p = pd) - sqrt(rho)*z) / sqrt(1 - rho))
return(pd_c)
}






