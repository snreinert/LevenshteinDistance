LevenshteinDistance and Search
* * *

Use Levenshtein Distance values to sort a list in a table search.


It is used to sort by the lowest [levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance) value of the search string compared to each string in the table.  
This goal is to have the most relevant/closest match results shown at the top.  Match closeness decreases from top to bottom.

The LevenshteinDistance modules are an Objective-C/C implementation of the code found [here](http://stackoverflow.com/questions/5859561/getting-the-closest-string-match).

This project contains some example code using the LevenshteinDistance module in a UIViewController with a UITableViewDelegate, UITableViewDataSource, and UISearchDisplayController.  

Run the project in Xcode 4 using the iOS Simulator to demonstrate it.
