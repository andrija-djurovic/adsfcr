#ssq function
ssq <- function(beta.coef, X, y, weights) {   
      resid <- c((t(y) - as.matrix(t(beta.coef))%*%t(X)))
      resid.w <- sum(weights * resid^2)
return(resid.w)
}

#' Constrained OLS Regrssion
#'@import dplyr
#'@export
constr.ols <- function(db, target, predictors, lower, upper, weights) {
      warn.init <- getOption("warn") 
      options(warn = -1)
      on.exit(options(warn = warn.init))

      X <- cbind(1, db[, predictors, drop = FALSE])
      y <- db[, target]
      lower <- c(-Inf, lower)
      upper <- c(Inf, upper)
      cc <- complete.cases(cbind(y, X))
      #initial values
      db.i <- data.frame(y, X)
      frm <- paste0("y ~ ", paste(names(X)[-1], collapse = " + "))
      start.vls <- unname(coef(lm(formula = frm,
                                  data = db.i)))
      opt <- optim(par = start.vls,
                   fn = ssq,
                   X = X[cc, ],
                   y = y[cc],
                   weights = weights[cc],
                   lower = lower,
                   upper = upper,
                   method = "L-BFGS-B")
      #betas
      beta.opt <- opt$par
      names(beta.opt) <- c("(Intercept)", predictors) 
      #model fit
      pred.opt <- c(as.matrix(t(beta.opt))%*%t(X))
      #r-squared
      r.squared <- cor(x = y, 
                       y = pred.opt,
                       use = "complete.obs")^2
      #loglikelihood
      n <- sum(cc)
      k <- sum(abs(beta.opt[-1]) > 1/1e6) + 2 #betas + intercept + 1 for sigma.hat
      rss <- sum((y - pred.opt)^2, na.rm = TRUE)
      sigma.hat <- rss / n
      logL <- -n/2 * (log(2*pi) + log(sigma.hat) + 1)
      #aic
      aic <- 2 * k - 2 * logL
      #bic
      bic <- log(n) * k - 2 * logL
      #summary
      res <- list(beta = beta.opt, pred = pred.opt, r.squared = r.squared, aic = aic, bic = bic)    
return(res)
}

#' Constrained Models Estimation
#'@import dplyr
#'@export
model.est <- function(gr.c, ps, db, target, weights) {
      warn.init <- getOption("warn") 
      options(warn = -1)
      on.exit(options(warn = warn.init))

      smi.r <- nrow(gr.c)
      res <- vector("list", smi.r) 
      pred <- vector("list", smi.r) 
      
      for   (i in 1:smi.r) {
            predi.i <- unname(c(gr.c[i, ], recursive = TRUE))
            predi.i <- predi.i[!is.na(predi.i)]
            #predictor name
            pred.n <- sub("_lag[1-4]$", "", predi.i)
            #lower and upper bounds
            lower <- c()
            upper <- c()
            for   (j in 1:length(pred.n)) {
                  ps.j <- ps[pred.n[j]]
                  if    (ps.j == "+") {
                        lower <- c(lower, 0)
                        upper <- c(upper, Inf)
                        } 
                  if    (ps.j == "-") {
                        lower <- c(lower, -Inf)
                        upper <- c(upper, 0)
                        }
                  if    (ps.j == "+/-") {
                        lower <- c(lower, -Inf)
                        upper <- c(upper, Inf)
                        }
                  }
            #constrained ols      
            res.i <- constr.ols(db = db, 
                                target = target, 
                                predictors = predi.i, 
                                lower = lower, 
                                upper = upper, 
                                weights = weights)
            pred[[i]] <- res.i$pred
            #summary
            res.i <- data.frame(model.id = paste0("Model_", i), 
                                coefficient = names(res.i$beta), 
                                estimate = unname(res.i$beta), 
                                r.squared = res.i$r.squared,
                                aic = res.i$aic,
                                bic = res.i$bic,
                                zero.coeff = any(round(unname(res.i$beta), 6) == 0))
            res.i$predictor <- sub("_lag[1-4]$", "", res.i$coefficient)
            res.i$lag <- get.lag(x = res.i$coefficient)
            #storing
            res[[i]] <- res.i
            }	 
            res <- bind_rows(res)
return(list(models = res, pred = pred))
}

#' Bivariate Filtering
#'@import dplyr
#'@export
bf <- function(db, target, group, lower, upper, weights) {
      warn.init <- getOption("warn") 
      options(warn = -1)
      on.exit(options(warn = warn.init))

      pl <- length(group)
      res <- vector("list", pl)
      for   (i in 1:pl) {
            predictor.i <- group[i]
            res.i <- constr.ols (db = db, 
                                 target = target, 
                                 predictors = predictor.i , 
                                 lower = lower, 
                                 upper = upper, 
                                 weights = weights)
            res.i <- data.frame(predictor = predictor.i,
                                coefficient = names(res.i$beta), 
                                estimate = unname(res.i$beta), 
                                r.squared = res.i$r.squared)
            res[[i]] <- res.i
            }
      res <- do.call("rbind", res)
      if    (all(is.na(res$r.squared))) {
            pred.select <- NULL
            } else {
            pred.select <- unique(res$predictor[which.max(res$r.squared)])
            }
      res <- list(summary = res, selected = pred.select)
return(res)
}

