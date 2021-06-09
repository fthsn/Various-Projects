# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

%reset -f
# Regression Template

# Importing the libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os 

os.chdir("/Users/ftmfth/Documents/Projects/GeneralFiles/Python/")

customers = pd.read_csv('customers.csv')
customers = customers.set_index('customer')

firms = pd.read_csv('firms.csv')
firms = firms.set_index('firm')


firms[customers]

customers.dtypes
customers.con
type(customers)     

    for customer in customers:
        data = get_input(token, customer)
        if len(data) == 0:
            continue
        data = pd.DataFrame(
            data, columns=["firm", "item", "week", "sales", "is_sales", "frequency"]
        )

        data = data.sort_values(["week", "item"])
        item_set = data.item.unique()
        next_week = int(data.iloc[-1].week + 1)

        for i in item_set:
            data.loc[len(data)] = [data["firm"][0], i, next_week, 0, 0, 0]
            # data.loc[len(data)] = [data['firm'][0], i, next_week+1, 0, 0, 0]
            # data.loc[len(data)] = [data['firm'][0], i, next_week+2, 0, 0, 0]
            # data.loc[len(data)] = [data['firm'][0], i, next_week+3, 0, 0, 0]

        data = data.sort_values(["week", "item"])

        # To predict total sales with amount
        # data['Last_Week_Sales'] = nanToZero(data.groupby(['item'])['sales'].shift())
        # data['Last_Week_Sales_2'] = nanToZero(data.groupby(['item'])['sales'].shift(2))
        # data['Last_Week_Sales_3'] = nanToZero(data.groupby(['item'])['sales'].shift(3))
        # To predict is_sales
        data["Last_Week_Is_Sales"] = nan_to_zero(
            data.groupby(["item"])["is_sales"].shift()
        )
        data["Last_Week_Is_Sales_2"] = nan_to_zero(
            data.groupby(["item"])["is_sales"].shift(2)
        )
        data["Last_Week_Is_Sales_3"] = nan_to_zero(
            data.groupby(["item"])["is_sales"].shift(3)
        )

        mean_error = []
        week_output = []
        for week in range(next_week - 1, next_week + 1):

            train = data[data["week"] < week]
            val = data[data["week"] == week]
            xtr, xts = (
                train.drop(["is_sales", "sales", "frequency"], axis=1),
                val.drop(["is_sales", "sales", "frequency"], axis=1),
            )
            ytr, yts = train["is_sales"].values, val["is_sales"].values

            mdl = RandomForestRegressor(n_estimators=1000, n_jobs=-1, random_state=0)
            mdl.fit(xtr, ytr)
            p = mdl.predict(xts)

            error = rmsle(yts, p)
            val = val.reset_index(drop=True)
            prediction = pd.DataFrame({"prediction": p})
            prediction = prediction.reset_index(drop=True)
            val = val.join(prediction)
            week_output.append(val)
            mean_error.append(error)
        analyze_churn(token, week_output)
        print('Mean Error = %.5f' % mean(mean_error))
