import pandas as pd
from itertools import combinations, product

def lv(db, x, n):
    result = pd.DataFrame()
    for var in x:
        max_lag = n[var]
        for lag in range(1, max_lag + 1):
            col_name = f"{var}_lag{lag}"
            result[col_name] = db[var].shift(lag)
    return result

def pg(n):
    groups = {}
    for var, max_lag in n.items():
        group = [var]  # Include the original variable (no lag)
        for lag in range(1, max_lag + 1):
            group.append(f"{var}_lag{lag}")
        groups[var] = group
    return groups


def pg_c(groups, max_pred):
    group_names = list(groups.keys())
    all_combinations = []
    
    #generate combinations for 1 to max_pred predictors
    for num_pred in range(1, max_pred + 1):
        #select which groups to include
        for selected_groups in combinations(group_names, num_pred):
            #get all members of selected groups
            group_members = [groups[g] for g in selected_groups]
            #create all combinations (one from each selected group)
            for combo in product(*group_members):
                all_combinations.append(combo)
    
    return all_combinations

def get_lag(x):
    lgs = []
    for xi in x:
        if isinstance(xi, str) and "_lag" in xi:
            part = xi.rsplit("_lag", 1)[-1]
            lgs.append(int(part) if part.isdigit() else 0)
        else:
            lgs.append(0)
    return lgs

