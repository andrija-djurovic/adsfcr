#' Create Lagged Variables
#'@import dplyr
#'@export
lv <- function(db, x, n) {
      p.l <- length(x)
      no <- nrow(db)
      res <- vector("list", p.l)
      for   (i in 1:p.l) {
            x.i <- x[i]
            n.i <- n[i]
            if    (n.i == 0) {
                  res[[i]] <- NULL
                  } else {
                  lv <- sapply(X = 1:n.i, 
                               FUN = function(k) c(rep(NA, k), db[, x.i][1:(no - k)]))
                  res.i <- data.frame(lv)
                  vn <- paste0(names(n.i), "_lag", 1:n.i)
                  names(res.i) <- vn
                  res[[i]] <- res.i
                  }
            }
      check <- !sapply(X = res, FUN = is.null)
      res <- res[check]
      if    (length(res) > 0) {
            res <- do.call("cbind", res)
            }
return(res)
}

#' Create Predictor's Groups
#'@import dplyr
#'@export
pg <- function(n) { 
      n.l <- length(n)
      groups <- vector("list", n.l)
      for   (i in 1:n.l) {
            pn.i <- names(n)[i]
            pl.i <- n[i]
            if    (pl.i > 0) {
                  group <- paste0(pn.i, "_lag", 1:pl.i) 
                  } else {
                  group <- pn.i
                  }
            groups[[i]] <- c(pn.i, group)
            }
      names(groups) <- names(n)
return(groups)
}

#' Create Predictor's Groups Combinations
#'@import dplyr
#'@export
pg.c <- function(groups, max.pred) {
      g.l <- length(groups)
      g.c <- vector("list", max.pred)
      for   (i in 1:max.pred) {
            g.cmbn <- combn(x = 1:g.l, 
                            m = i, 
                            simplify = FALSE)
            pr.c <- lapply(X = g.cmbn, 
                           FUN = function(idx) expand.grid(unname(groups[idx])))
            pr.c <- do.call(what = "rbind", 
                            args = pr.c)
            g.c[[i]] <- pr.c
            }
      g.c <- bind_rows(g.c)
      g.c <- data.frame(sapply(X = g.c, 
                               FUN = as.character))
return(g.c)
}


#get lag
get.lag <- function(x) {
      lag <- sub(".*_lag([1-4])$", "\\1", x)
      lgs <- ifelse(grepl("_lag[1-4]$", x), as.integer(lag), 0)
return(lgs)
}


