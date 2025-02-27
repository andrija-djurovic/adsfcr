#woe calculation
def woe_calc(db, x, y):
    tbl_s = db.groupby(db[x].rename("bin"), observed = True).agg(
            no = (x, "count"),
            ng = (y, lambda s: np.nansum(1 - s)),
            nb = (y, lambda s: np.nansum(s))).reset_index()
    so, sg, sb = tbl_s["no"].sum(), tbl_s["ng"].sum(), tbl_s["nb"].sum()
    tbl_s = tbl_s.assign(
        pct_o = tbl_s["no"] / so,
        pct_g = tbl_s["ng"] / sg,
        pct_b = tbl_s["nb"] / sb,
        dr = tbl_s["nb"] / tbl_s["no"],
        dist_g = tbl_s["ng"] / sg,
        dist_b = tbl_s["nb"] / sb
        )
    tbl_s["woe"] = np.log(tbl_s["dist_g"] / tbl_s["dist_b"])
    tbl_s["iv_b"] = (tbl_s["dist_g"] - tbl_s["dist_b"]) * tbl_s["woe"]
    tbl_s["iv_s"] = tbl_s["iv_b"].sum() 
    woe_v = tbl_s.set_index("bin")["woe"].to_dict()
    woe_trans = list(map(woe_v.get, db[x]))
    
    return {"summary_tbl": tbl_s, "x_trans": woe_trans}