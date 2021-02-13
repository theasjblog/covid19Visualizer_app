# Introduction

Simple data visualizer for COVID-19 spread.

## Data

Data is provided by `Our world in data` and is obtained from: <https://covid.ourworldindata.org/data/owid-covid-data.xlsx>. 


## Plots

* Left:  charts from all the selected geographical regions and metrics
* Right: map of the selected countries coloured based on the selected metric (if more than one was selected then the first one will be used).

## Options

* **Countries/Groups**: Select if to plot individually selected countries or predefined groups of countries such as `Europe`, `Africa`, etc.
* **Metric**: The metric to plot, for instance the number of cases or vaccinations.
* **Normalise**: If ticked, allows to normalise the selected metrics by some country-wide measurement, for instance the population. When ticked, two more options will appear: one to selected what to normalise for, for instance `population`, and one to define the multiplication factor. For instance, to know the percentage of the population affected, normalise by `population` and choose `100`: this will give you the number of individuals affected every 100 inhabitants.

# About
<b>COVID-19 Tracker</b>
<br/>
Version: 0.1.2
<br/>
Author: Adrian Steve Joseph
