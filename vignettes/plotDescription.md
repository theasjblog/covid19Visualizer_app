## Type of plots

* Left: overlay charts from all the selected geographical regions and metric (`cases`, `death` or `recovered`)
* Right: data for all the metrics, with a chart for each individual country selected

## Options

* **Scale**: Plot the scale in linear or logaritmic scale.
* **Metric**: Plot one of `cases`, `death` or `recovered`. Note that not all metrics are available for all geographical areas.
* **Rate**: If ticked, the plot displays the net variation from the previous day for the selected metric. Otherwise, the plot displays the total cumulative number up until the selected date.
* **Smooth**: If tickced, the plot are smoothed. There is naturally considerably day-to-day variations in the reported numbers. Moreover, many geographical areas reports data irregularly, for instance every few days. This results in noisy plots. This option allows to smooth the displayed curves.
* **Normalise**: If ticked, the raw data are normalised to number of `cases`, `death` or `recovered` every 100,000 in dividuals. This is to account for countries with different population sie.
* **Day**: Plot a specific day. Days are numbered since the beginning of John Hopkins University records.
* **Geographical area**: The geographical area(s) to plot. This can be a country, a state/territory/province (i.e. `Ontario`) or a town (i.e. `Seattle`).
