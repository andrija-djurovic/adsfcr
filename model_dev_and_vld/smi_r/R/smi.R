#' Supervised Macroeconomic Index
#'@import dplyr
#'@export
smi <- function(models, db, weights) {
      um <- length(unique(models$model.id))
      if    (weights%in%"average") {
            models$weights <- 1 / um
            }
      #average coefficients
      ca.s <- models %>% 
              group_by(coefficient) %>%
              summarise(estimate = sum(weights*estimate)) %>%
              as.data.frame()
      #sme construction
      ca.e <- ca.s$estimate
      X <- cbind(1, db[, ca.s$coefficient[-1]])
      smi <- c(as.matrix(t(ca.e))%*%t(X))
      #summary
      weights <- unique(models[, c("model.id", "weights")])
      res <- list(smi = smi, coef = ca.s, weights = weights) 
return(res)
}

