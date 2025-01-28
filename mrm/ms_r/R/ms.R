#' PD Model Shift
#'
#' \code{ms.pd} performs testing of predictive power of the PD rating model. 
#'@param db Modeling dataset.
#'@param target Vector of target (dependent variable) name.
#'@param rf Vector of risk factor names.
#'@param data.shift A data frame with column names from \code{rf}, and with the last column named \code{n}.
#'@param encoding Encoding method with the available options: `dummy` and `WoE`.
#'@param method Model shift method with the available options: \code{mm} (matrix multiplication), \code{wbr} (weighted binomial regression), \code{wfr} (weighted fractional regression).
#'@param woe.tbl The manually created WoE table. A data frame with three columns: `"rf"`, `"bin"`, and `"woe"`. The default value is `NULL`.
#'@param lr.i The `glm` object of the initial model. The default is `NULL`. If supplied, the function uses the given model instead of estimating it.
#'@return For the selected method \code{mm}, the command \code{ms.pd} returns: model shift (\code{ms}) and summary table (\code{db.s}). For the selected methods \code{wbr} and \code{wfr}, the command \code{ms.pd} returns: initial model (\code{lr.i}), simulated model (\code{lr.s}), model shift (\code{ms}), and summary table (\code{db.s}).
#'@import dplyr
#'@export
ms.pd <- function(db, target, rf, data.shift, encoding, method, woe.tbl = NULL, lr.i = NULL) {
      #input checks
      checks.init(db = db, 
                  target = target, 
                  rf = rf, 
                  data.shift = data.shift, 
                  encoding = encoding, 
                  method = method,
                  woe.tbl = woe.tbl)

      #names checks
      target <- unname(check.names(x = target))
      rf <-  unname(check.names(x = rf))
      db.n <- unname(check.names(x = names(db))) 
      names(db.n) <- db.n
      ds.n <- unname(check.names(x = names(data.shift)[-ncol(data.shift)]))
      names(data.shift)[-ncol(data.shift)] <- ds.n
      if    (!is.null(woe.tbl)) { 
            woe.tbl$rf <- unname(check.names(x = woe.tbl$rf))
            }

      #model shift
      if    (method%in%"mm") {
            res <- mm.m(db = db, 
                        target = target, 
                        rf = rf, 
                        data.shift = data.shift, 
                        encoding = encoding,
                        woe.tbl = woe.tbl, 
                        lr.i = lr.i)
            }
     
      if    (method%in%"wbr") {
            res <- wbr.m(db = db, 
                         target = target, 
                         rf = rf, 
                         data.shift = data.shift, 
                         encoding = encoding,
                         woe.tbl = woe.tbl, 
                         lr.i = lr.i)
            }
      if    (method%in%"wfr") {
            res <- wfr.m(db = db, 
                         target = target, 
                         rf = rf, 
                         data.shift = data.shift, 
                         encoding = encoding,
                         woe.tbl = woe.tbl, 
                         lr.i = lr.i)
            }
return(res)
}

