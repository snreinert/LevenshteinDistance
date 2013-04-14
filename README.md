LevenshteinDistance and Search
* * *

Use Levenshtein Distance values to sort a list in a table search.

This is an Objective-C and C implementation of the code found [here](http://stackoverflow.com/questions/5859561/getting-the-closest-string-match).

It is used to sort by the lowest value [levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance) of the search string and the table strings.  
This effect is that the most relevant/closest match results are shown at the top.  Match closeness decreases as it gets further down the list.

This project contains some example code using the LevenshteinDistance module in a UIViewController with a UITableViewDelegate, UITableViewDataSource, and UISearchDisplayController.
