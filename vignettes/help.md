# Introduction

Simple data visualizer for COVID-19 spread.

## Data

Data is provided by Johns Hopkins University (JHU) and is obtained from <https://github.com/CSSEGISandData/COVID-19>. 

JHU university refreshes the data daily, and new data is fetched every day.

## Plots

* Left: overlay charts from all the selected geographical regions and metric (`cases`, `death` or `recovered`)
* Right: data for all the metrics, with a chart for each individual country selected

### Options

* **Scale**: Plot the scale in linear or logarithmic scale.
* **Metric**: Plot one of `cases`, `death` or `recovered`. Note that not all metrics are available for all geographical areas.
* **Rate**: If ticked, the plot displays the net variation from the previous day for the selected metric. Otherwise, the plot displays the total cumulative number up until the selected date.
* **Smooth**: If ticked, the plot are smoothed. There is naturally considerably day-to-day variations in the reported numbers. Moreover, many geographical areas reports data irregularly, for instance every few days. This results in noisy plots. This option allows to smooth the displayed curves.
* **Normalise**: If ticked, the raw data are normalised to number of `cases`, `death` or `recovered` every 100,000 individuals. This is to account for countries with different population.
* **Day**: Plot a specific day. Days are numbered since the beginning of John Hopkins University records.
* **Geographical area**: The geographical area(s) to plot. This can be a country, a state/territory/province (i.e. `Ontario`) or a town (i.e. `Seattle`).

## Maps

* **Trend**: The average increase in numbers from day to day, for the past 7 days of the selected metric and day. This will be positive if the selected metric is increasing over time, negative otherwise. This is calculated by considering the difference between reported numbers day to day. For instance, if the new number of cases reported over three days are 1520, 1500, 1400, the trend will be ((1520-1500)+(1500-1400))/3 = -40.
* **Normalised trend**: As `Trend`, but normalised for every 100,000 individuals.
* **Rate**:The number of `cases`, `deaths` or `recovered` reported for the selected day.
* **Normalised rate**: As `Rate`, but normalised for every 100,000 individuals.
* **Total past 7 days normalised**: As `In/Out for UK quarantine`, but the map is coloured by actual number, rather than with respect of the threshold.
* **Total number**: Total number of `cases`, `deaths` or `recovered` up to the selected day.
* **Total number normalised**: As `Total number`, but normalised for every 100,000 individuals.

### Options

* **Metric**: Map one of `cases`, `death` or `recovered`. Note that not all metrics are available for all geographical areas or all map plots.
* **Day**: Map a specific day. Days are numbered since the beginning of John Hopkins University records.
* **Country**: The country/countries to map.
* **Map type**: The type of map to show
# About
<b>Covid-19 Visualizer</b>
<br/>
Version: V0.1.0
<br/>
Author: Adrian Steve Joseph
