# Introduction

Simple data visualizer for COVID-19 spread.

## Data

Data is provided by `Our world in data` and is obtained from: <https://covid.ourworldindata.org/data/owid-covid-data.xlsx>. 

## Options

* **Countries/Groups**: Select if to plot individually selected countries or predefined groups of countries such as `Europe`, `Africa`, etc.
* **Metric**: The metric to plot, for instance the number of cases or vaccinations.
* **Show in percentage of the population**: If ticked, allows to normalise the selected metrics by population size. The metrics will be reported normalised every 100 inhabitants (i.e. as a percentage of the whole population).
* **Fit to y-axis**: Some metrics cannot be plotted on the same chart in a easy to interpret way because the data is in extremely different scales. For instance, daily cases can be in the order of a few thousands, while total vaccinations can be millions. If plotting both metrics at the same time, the daily cases curve will appear as a flat line on the horizontal axis. To overcome this, select this options: all curves will be re-scaled so that they fit in the minimum and maximum of the axis. When you hover on the curve, the tooltip will still report the original value.

# About
<b>COVID-19 Tracker</b>
<br/>
Version: 0.2.0
<br/>
Author: Adrian Steve Joseph
