#checks
checks.init <- function(db, target, rf, data.shift, encoding, method, woe.tbl) {
      eo <- c("dummy", "WoE")
      mo <- c("mm", "wbr", "wfr")
      #object types
      cond.01 <- !is.data.frame(db) | !is.data.frame(data.shift)
      #missing values
      #missing values
      db.mv <- any(colSums(is.na(db)) > 0)
      ds.mv <- any(colSums(is.na(data.shift)) > 0)
      cond.02 <- db.mv | ds.mv
      #available options
      cond.03 <- !sum(encoding%in%eo) == 1
      cond.04 <- !sum(method%in%mo) == 1
      #target
      y <- db[, target]
      cond.05 <- !sum(y%in%c(0, 1)) == length(y)
      #rf names
      db.rf <- any(!rf%in%names(db))
      ds.n <- names(data.shift)[-ncol(data.shift)]
      ds.rf <- any(!ds.n%in%names(db))
      cond.06 <- db.rf | ds.rf
      #rf type 
      cond.07 <- any(sapply(db[, rf], function(x) !any(c(is.character(x), is.factor(x)))))
      ds.n <- names(data.shift)[-ncol(data.shift)]
      cond.08 <- any(sapply(data.shift[,  ds.n, drop = FALSE], 
                     function(x) !any(c(is.character(x), is.factor(x)))))
      #data.shift 
      ds.lc <- names(data.shift)[ncol(data.shift)]
      cond.09 <- !"n"%in%ds.lc
      #woe tbl
      if    (is.null(woe.tbl)) {
            cond.10 <- FALSE
            } else {
            wt.n <- names(woe.tbl)
            ex.n <- c("rf", "bin", "woe")
            cond.10 <- !sum(ex.n%in%wt.n) == length(ex.n)
            } 
      
      #summary
      cond.all <- c(cond.01, cond.02, cond.03, cond.04, cond.05, cond.06, cond.07, 
                    cond.08, cond.09, cond.10)	
      if    (sum(cond.all) > 0) {
            which.cond <- min(which(cond.all))
            } else {
            which.cond <- 0
            }
      #error checks
      error <- switch(as.character(which.cond), 
                      "0" = "NULL",
                      "1" = "stop('db or data.shift is not a data frame.')",
                      "2" = "stop('db or data.shift contains missing values.')",
                      "3" = "stop('available options for encoding argument are: dummy, WoE.')",
                      "4" = "stop('available options for method argument are: mm, wbr, wfr.')",        
                      "5" = "stop('target is not 0/1 variable.')",
                      "6" = "stop('rf argument does not match names in db or data.shift.')",
                      "7" = "stop('rf in db has to be of character or factor type.')",
                      "8" = "stop('rf in data.shift has to be of character or factor type.')",
                      "9" = "stop('the last column of the data.shift data frame has to be named n')",
                      "10" = "stop('woe.tbl names do not match the expected names: rf, bin, woe.')")

return(eval(parse(text = error)))
}

#check names
check.names <- function(x) {
	x.c <- gsub("[^[:alnum:][[^\\.]|[^\\_]]", " ", x)
	x.c <- trimws(x.c)
	x.c <- gsub(" ", "_", x.c)
	names(x.c) <- x
return(x.c)
}
