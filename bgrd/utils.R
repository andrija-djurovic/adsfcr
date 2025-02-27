#woe calculation
woe.calc <- function(db, x, y) {
      tbl.s <- db %>% 
               group_by_at(c("bin" = x)) %>%
               summarise(no = n(),
                         ng = sum(1 - !!sym(y), na.rm = TRUE),
                         nb = sum(!!sym(y), na.rm = TRUE)) %>%
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
      woe.v <- tbl.s$woe
      names(woe.v) <- tbl.s$bin
      woe.trans <- unname(woe.v[db[, x]])
return(list(summary.tbl = tbl.s, x.trans = woe.trans))
}

