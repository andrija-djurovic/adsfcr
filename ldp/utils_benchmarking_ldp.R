#confidence intervals for multinomial proportion
mltnp.ci <- function(tendency, cl) {
      #frequency table
      ft <- table(tendency)
      #number of observations
      n <- sum(ft, na.rm = TRUE)
      #tendency indicator length (3)
      k <- length(ft)
      #proportions
      p <- ft / n
      #confidence interval elements
      q.chi <- qchisq(1 - (1 - cl)/k, df = 1)
      lci <- (q.chi + 2*ft - sqrt(q.chi*(q.chi + 4*ft*(n - ft)/n))) / (2*(n + q.chi))
      uci <- (q.chi + 2*ft + sqrt(q.chi*(q.chi + 4*ft*(n - ft)/n))) / (2*(n + q.chi))  
      #summary table
      res <- cbind(est = p, 
                   lower = pmax(0, lci), 
                   upper = pmin(1, uci))
return(res)
}

#average deviation confidence interval
d.ci <- function(deviation, cl) {
      #frequency table
      ft <- table(deviation)
      #number of obligors
      n <- length(deviation)
      #deviation probabilities
      p <- ft / n
      #possible sums
      p.sums <- seq(from = min(deviation)*n, 
                    to = max(deviation)*n, 
                    by = 1)
      #average deviation (D values)
      d.avg <- p.sums / n
      #cumulative probabilities
      cnv.res <- convolve.p(p = p, 
                            n = n)
      cdf.avg <- cumsum(cnv.res)
      #confidence level index
      idx.l <- which(cdf.avg >= (1 - cl) / 2)[1]
      idx.u <- which(cdf.avg >= (1 + cl) / 2)[1]
      #confidence interval for average deviation
      res <- data.frame(est = mean(deviation),
                        lower = d.avg[idx.l],
                        upper = d.avg[idx.u])
return(res)
}

#convolve n times function
convolve.p <- function(p, n) {  
      p.i <- p
      for   (i in 2:n) {
            p.i <- convolve(x = p.i, 
                            y = rev(p), 
                            type = "open")
            }
return(p.i)
}




