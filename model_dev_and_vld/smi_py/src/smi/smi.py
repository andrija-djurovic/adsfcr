import pandas as pd
import numpy as np

def smi(models, db, weights):
    um = models["model.id"].nunique()  
    if weights == "average":
        models = models.copy()
        models["weights"] = 1.0 / um
    ca_s = (models.groupby("coefficient", as_index = False)
        .apply(lambda g: pd.Series({
            'estimate': np.sum(g["weights"] * g["estimate"])})).reset_index(drop = True))
    coef_order = ca_s["coefficient"].tolist()
    ca_e = ca_s["estimate"].values
    X = np.column_stack(
        [np.ones(len(db))] +
        [db[var].values for var in coef_order if var != "(Intercept)"])
    smi_values = X @ ca_e
    weights_table = models[["model.id", "weights"]].drop_duplicates()

    return {"smi": smi_values,
            "coef": ca_s,
            "weights": weights_table}


