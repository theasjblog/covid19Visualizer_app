## Type of maps

* **Trend**: The average increase in numbers from day to day, for the past 7 days of the selcted metric and day. This will be positive if the selected metric is increasing over time, negative otherwise. This is calculated by considering the difference between reported numbers day to day. For instance, if the new number of cases reported over three days are 1520, 1500, 1400, the trand will be ((1520-1500)+(1500-1400))/3 = -40.
* **Normalised trend**: As `Trend`, but normalised for every 100,000 individuals.
* **Rate**:The number of `cases`, `deaths` or `recovered` reported for the selected day.
* **Normalised rate**: As `Rate`, but normalised for every 100,000 individuals.
* **In/Out for UK quarantine**: UK uses several criteria to decide if travellers coming from a given country must quarantine on their arrival to UK. One of the criteria is the total number of cases over every 100,000 individual for the past 7 days. If this number is above 20, then the country will be considered for inclusion in the quarantine list. In this map, countries below the 20 thereshold are coloured in blue, countris above the threshold are coloured in red.
* **Total past 7 days normalised**: As `In/Out for UK quarantine`, but the map is coloured by actual number, rather than with respect of the threshold.
* **Total number**: Total number of `cases`, `deaths` or `recovered` up to the selected day.
* **Total number normalised**: As `Total number`, but normalised for every 100,000 individuals.

## Options

* **Metric**: Map one of `cases`, `death` or `recovered`. Note that not all metrics are available for all geographical areas or all map plots.
* **Day**: Map a specific day. Days are numbered since the beginning of John Hopkins University records.
* **Country**: The country/countries to map.
* **Map type**: The type of map to show