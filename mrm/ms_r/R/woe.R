#woe calculation on the aggregated table
woe.agg.tbl <- function(tbl, y, x, n, type) {     
      rf.l <- length(x)
      res <- vector("list", rf.l)
      for   (i in 1:rf.l) {
            rf.i <- x[i]
            tbl.i <- tbl[, c(y, rf.i, n)]
            if    (type%in%"binary") {
                  #number of bad cases 
                  tbl.i$nb <- ifelse(tbl.i[, y] == 0, 0, tbl.i[, n])
                  } else {
                  #number of bad cases    
                  tbl.i$nb <- tbl.i[, n] * tbl.i[, y] 
                  }
            #number of good cases
            tbl.i$ng <- tbl.i[, n] - tbl.i[, "nb"]
            #risk factor aggregation and woe calculation
            res.i <- tbl.i %>% 
                     group_by_at(c("bin" = rf.i)) %>% 
                     summarise(no = sum(!!sym(n)),
                               ng = sum(ng, na.rm = TRUE),
                               nb = sum(nb, na.rm = TRUE)) %>%
                     ungroup() %>%
                     mutate(pct.o = no / sum(no, na.rm = TRUE),
                            pct.g = ng / sum(ng, na.rm = TRUE),
                            pct.b = nb / sum(nb, na.rm = TRUE),
                            dr = nb / no,
                            so = sum(no, na.rm = TRUE),
                            sg = sum(ng, na.rm = TRUE),
                            sb = sum(nb, na.rm = TRUE), 
                            dist.g = ng / sg,
                            dist.b = nb / sb,
                            woe = log(dist.g / dist.b),
                            iv.b = (dist.g - dist.b) * woe,  
                            iv.s = sum(iv.b)) %>%
                     as.data.frame()
            woe.v <- res.i$woe
            names(woe.v) <- res.i$bin
            woe.t <- unname(woe.v[tbl.i[, rf.i]])
            res[[i]] <- woe.t
            }
      names(res) <- paste0(x, ".woe")
	res <- as.data.frame(bind_cols(res))
return(res)
}

#woe db.s encoding 
woe.dbs.e <- function(tbl, woe) {
      rf <- unique(woe$rf)
      rf.l <- length(rf)
      rf.woe <- paste0(rf, ".woe")
      res <- vector("list", rf.l)
      for   (i in 1:rf.l) {
            rf.i <- rf[i]
            woe.v <- woe$woe[woe$rf%in%rf.i]
            names(woe.v) <-  woe$bin[woe$rf%in%rf.i]
            res[[i]] <- unname(woe.v[tbl[, rf.i]])
            }
      names(res) <- rf.woe
	res <- as.data.frame(bind_cols(res))
return(res)
}

#woe db encoding
woe.db.e <- function(db, db.s, rf) {
      rf.l <- length(rf)
      rf.woe <- paste0(rf, ".woe")
      res <- vector("list", rf.l)
      for   (i in 1:rf.l) {
            rf.i <- rf[i]
            rf.woe.i <-  rf.woe[i]
            woe.i <- unique(db.s[, c(rf.i, rf.woe.i)])
            woe.v <- woe.i[, rf.woe.i]
            names(woe.v) <- woe.i[, rf.i]
            res[[i]] <- unname(woe.v[db[, rf.i]])
            }
      names(res) <- rf.woe
	res <- as.data.frame(bind_cols(res))
return(res)
}
