#power of heterogeneity test - analytical solution
ht.power.a <- function(n1, n2, p1, p2, alpha) {
      delta <- p1 - p2
      q1 <- 1 - p1
      q2 <- 1 - p2
      n.fac <- 1/n1 + 1/n2
      z <- qnorm(1 - alpha)
      p.bar <- (n1 * p1 + n2 * p2)/(n1 + n2)
      q.bar <- 1 - p.bar
      pwr <- pnorm((-z * sqrt(p.bar * q.bar * n.fac) - delta) / 
                    sqrt((p1 * q1)/n1 + (p2 * q2)/n2))
return(pwr)
}

#power of heterogeneity test - monte-carlo simulation
ht.power.s <- function(n1, n2, p1, p2, alpha, sim, seed) {
      res <- rep(NA, sim)
      for (i in 1:sim) {
           set.seed(seed + i)
           x1 <- rbinom(n = n1, 
                        size = 1, 
                        prob = p1)
           x2 <- rbinom(n = n2, 
                        size = 1, 
                        prob = p2)
           res[i] <- prop.test(x =  c(sum(x1), sum(x2)),
                               n = c(n1, n2),
                               alternative = "less",
                               correct = FALSE)$p.value
           }
      pwr <- mean(res < alpha) 
return(pwr)
}
