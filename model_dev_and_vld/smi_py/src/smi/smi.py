import pandas as pd

def smi(models, db, weights):
    #number of unique models
    um = models["model.id"].nunique()  
    #assign average weights if requested
    if weights == "average":
        models = models.copy()
        models["weights"] = 1.0 / um
    #weighted average of coefficients across models
    ca_s = (models.groupby("coefficient", as_index = False)
        .apply(lambda g: pd.Series({
            'estimate': np.sum(g["weights"] * g["estimate"])
        })).reset_index(drop = True))
    #construct x in the exact coefficient order
    coef_order = ca_s["coefficient"].tolist()
    ca_e = ca_s["estimate"].values
    #intercept + selected variables
    X = np.column_stack(
        [np.ones(len(db))] +
        [db[var].values for var in coef_order if var != "(Intercept)"])
    #matrix multiplication
    smi_values = X @ ca_e
    #extract model weights table
    weights_table = models[["model.id", "weights"]].drop_duplicates()

    return {"smi": smi_values,
            "coef": ca_s,
            "weights": weights_table}

