#data shift distribution
ds.dist <- function(db.s, data.shift) {
      ds.rf <- names(data.shift)[-ncol(data.shift)]
      names(data.shift)[ncol(data.shift)] <- "n.ds" 
      ns <- ave(db.s$n, db.s[, ds.rf], FUN = function(x) x/sum(x))
      db.s <- merge(x = db.s,
                    y = data.shift,
                    by = ds.rf,
                    all.x = TRUE)
      if    (any(is.na(db.s$n.ds))) {
            stop("data.shift contains incompleted information.")
            }
      db.s$n.s <- ns * db.s$n.ds 
return(db.s) 
} 

