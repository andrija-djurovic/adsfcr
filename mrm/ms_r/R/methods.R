#matrix multiplication (first-order approximation) method
mm.m <- function(db, target, rf, data.shift, encoding, woe.tbl, lr.i) {
      #db summary table
      db.s <- db %>%
              group_by_at(rf) %>%
              summarise(n = n(),
                        dr = mean(!!sym(target)), 
                        .groups = "drop") %>%
              as.data.frame()
      #distribution of data shift
      db.s <- ds.dist(db.s = db.s, 
                      data.shift = data.shift)
      #initial proportions
      pn.1 <- (db.s$n * db.s$dr) / sum(db.s$n)
      pn.0 <- (db.s$n * (1 - db.s$dr)) / sum(db.s$n)
      #shifted proportions
      pn.s.1 <- (db.s$n.s * db.s$dr) / sum(db.s$n.s)
      pn.s.0 <- (db.s$n.s * (1 - db.s$dr)) / sum(db.s$n.s)
      #proportions change
      dx.p <- pn.1 - pn.s.1 #dx plus
      dx.m <- pn.0 - pn.s.0 #dx minus     
      #encoding
      if   (encoding%in%"WoE") {
           if     (!is.null(woe.tbl)) {
                  woe.e <- woe.dbs.e(tbl = db.s, 
                                     woe = woe.tbl)
                  } else {
                  woe.e <- woe.agg.tbl(tbl = db.s, 
                                       y = "dr", 
                                       x = rf, 
                                       n = "n", 
                                       type = "frac")
                  }
                  db.s <- cbind.data.frame(db.s, woe.e)
                  db <- cbind.data.frame(db, woe.db.e(db = db, db.s = db.s, rf = rf))
                  frm <- as.formula(paste0("dr ~ ", paste0(paste0(rf, ".woe"), collapse = " + ")))
                  cnts <- NULL
           } else {
           frm <- as.formula(paste0("dr ~ ", paste0(rf, collapse = " + ")))
           cnts <- as.list(rep(x = "contr.treatment", times = length(rf)))
           names(cnts) <- rf
           }
      #regression model
      if    (is.null(lr.i)) { 
            lr.i <- glm(formula = frm,
                        family = "quasibinomial",
                        weights = db.s$n, 
                        contrasts = cnts,
                        data = db.s)
            }
      #add model predictions
      db$lgod <- unname(predict(object = lr.i,
                                newdata = db,
                                type = "link"))
      db$prob <- unname(predict(object = lr.i,
                                newdata = db,
                                type = "response"))
      #data points
      x <- db %>%
           group_by_at(rf) %>%
           summarise(`1` = sum(!!sym(target) == 1) / nrow(db),
                     `0` = sum(!!sym(target) == 0) / nrow(db),
                     .groups = "drop") %>%
           as.data.frame()
      #model points
      y <- db %>%
           group_by_at(rf) %>%
           summarise(`1` = sum(prob) / nrow(db),
                     `0` = sum(1 - prob) / nrow(db),
                     .groups = "drop") %>%
           as.data.frame()
      #design matrix (N x M)
      if    (encoding%in%"WoE") {
            D <- as.matrix(cbind.data.frame("(Intercept)" = 1, db.s[, paste0(rf, ".woe")]))
            } else {
            frm.dm <- as.formula(paste0("~ 1 + ", paste0(rf, collapse = " + ")))
            D <- model.matrix(object = frm.dm ,
                              contrasts = cnts, 
                              data = db.s)
            }
      #diagonal matrix for y(a,1)                                          
      Yplus <- diag(y[, "1"])
      #diagonal matrix for y(a,-1)                                                  
      Yminus <- diag(y[, "0"])
      #adjust for zeros
      diag(Yplus)[diag(Yplus) == 0] <- 1e-10
      diag(Yminus)[diag(Yminus) == 0] <- 1e-10 
      #diagonal matrix of modeled odds ratios
      Z <- Yplus %*% solve(Yminus)    
      #identity matrix                  
      I <- diag(nrow(Z)) 
      #Y matrix                               
      Y <- solve(I + Z) %*% solve(I + solve(Z)) %*% (Yplus + Yminus)
      #matrix C (M x M)
      C <- t(D) %*% Y %*% D
      #compute dp                       
      term.1 <- solve(I + Z) %*% dx.p
      term.2 <- solve(I + solve(Z)) %*% dx.m
      dp <- solve(C) %*% t(D) %*% (term.1 - term.2)
      ms <- c(dp)
      names(ms) <- row.names(dp)
return(list(ms = ms, db.s = db.s))
} 

#weighted binomial regression method
wbr.m <- function(db, target, rf, data.shift, encoding, woe.tbl, lr.i) {
      #db summary table
      db.s <- db %>%
              group_by_at(c(rf, target)) %>%
              summarise(n = n(),
                        .groups = "drop") %>%
              as.data.frame()
      #distribution of data shift
      db.s <- ds.dist(db.s = db.s, 
                      data.shift = data.shift)
      #encoding
      if   (encoding%in%"WoE") {
           if     (!is.null(woe.tbl)) {
                  woe.e <- woe.dbs.e(tbl = db.s, 
                                     woe = woe.tbl)
                  } else {
                  woe.e <- woe.agg.tbl(tbl = db.s, 
                                       y = target, 
                                       x = rf, 
                                       n = "n", 
                                       type = "binary")
                  }
           db.s <- cbind.data.frame(db.s, woe.e)
           frm <- as.formula(paste0(target, " ~ ", paste0(paste0(rf, ".woe"), collapse = " + ")))
           cnts <- NULL
           } else {
           frm <- as.formula(paste0(target, " ~ ", paste0(rf, collapse = " + ")))
           cnts <- as.list(rep(x = "contr.treatment", times = length(rf)))
           names(cnts) <- rf
           }
      #binomial regression - initial
      if    (is.null(lr.i)) { 
            lr.i <- glm(formula = frm,
                        family = "binomial",
                        weights = db.s$n, 
                        contrasts = cnts,
                        data = db.s)
            }
      lr.i.c <- summary(lr.i)$coefficients
      #binomial regression - simulation 
      lr.s <- glm(formula = frm,
                  family = "binomial",
                  weights = db.s$n.s, 
                  contrasts = cnts,
                  data = db.s)
      lr.s.c <- summary(lr.s)$coefficients
      #model shift
      ms <- lr.i.c[, "Estimate"] - lr.s.c[, "Estimate"]
      #result summary
      res <- list(lr.i = lr.i, lr.s = lr.s, ms = ms, db.s = db.s) 
return(res)
} 

#weighted quasi-binomial (fractional) regression method
wfr.m <- function(db, target, rf, data.shift, encoding, woe.tbl, lr.i) {
      #db summary table
      db.s <- db %>%
              group_by_at(rf) %>%
              summarise(frac = mean(!!sym(target)), 
                        n = n(),
                        .groups = "drop") %>%
              as.data.frame()
      #distribution of data shift
      db.s <- ds.dist(db.s = db.s, 
                      data.shift = data.shift)
      #encoding
      if   (encoding%in%"WoE") {
           if     (!is.null(woe.tbl)) {
                  woe.e <- woe.dbs.e(tbl = db.s, 
                                     woe = woe.tbl)
                  } else {
                  woe.e <- woe.agg.tbl(tbl = db.s, 
                                       y = "frac", 
                                       x = rf, 
                                       n = "n", 
                                       type = "frac")
                  }
           db.s <- cbind.data.frame(db.s, woe.e)
           frm <- as.formula(paste0("frac ~ ", paste0(paste0(rf, ".woe"), collapse = " + ")))
           cnts <- NULL
           } else {
           frm <- as.formula(paste0("frac ~ ", paste0(rf, collapse = " + ")))
           cnts <- as.list(rep(x = "contr.treatment", times = length(rf)))
           names(cnts) <- rf
           }
      #quasi-binomial regression - initial
      if    (is.null(lr.i)) { 
            lr.i <- glm(formula = frm,
                        family = "quasibinomial",
                        weights = db.s$n, 
                        contrasts = cnts,
                        data = db.s)
            }
      lr.i.c <- summary(lr.i)$coefficients
      #quasi-binomial regression - simulation 
      lr.s <- glm(formula = frm,
                  family = "quasibinomial",
                  weights = db.s$n.s, 
                  contrasts = cnts,
                  data = db.s)
      lr.s.c <- summary(lr.s)$coefficients
      #model shift
      ms <- lr.i.c[, "Estimate"] - lr.s.c[, "Estimate"]
      #result summary
      res <- list(lr.i = lr.i, lr.s = lr.s, ms = ms, db.s = db.s) 
return(res)
} 