/*
 * DemoTableViewController.m
 * Copyright 2013 Salt River Software, LLC
 *
 * Licensed under the Eclipse Public License, Version 1.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "DemoTableViewController.h"
#import "LevenshteinDistance.h"
#import "DistanceString.h"

@interface DemoTableViewController () {
    NSArray *_dataSet;
    NSMutableArray *_filteredData;
}

@property (nonatomic, retain) NSArray *dataSet;
@property (nonatomic, retain) NSMutableArray *filteredData;

@end

@implementation DemoTableViewController

@synthesize tableView = _tableView;

#pragma mark - Properties

-(NSArray *) dataSet {
    if (_dataSet == nil) {
        
        NSArray *rawPhrases = [NSArray arrayWithObjects:
                               @"Ale",
                               @"Lager",
                               @"Stout",
                               @"Porter",
                               @"Pale Ale",
                               @"IPA",
                               @"Wheat Beer",
                               @"Pilsener",
                               @"Bitter",
                               @"Wheat",
                               @"Pilsner",
                               @"Bock",
                               @"Witbier",
                               @"Keg",
                               @"ESB",
                               @"Brown Ale",
                               @"Quadrupel",
                               @"Bokbier",
                               @"Stout Bier",
                               @"Fruitbier",
                               @"Blond Bier",
                               @"Trappisten Bieren",
                               @"Speciaal Bieren",
                               @"Dubbel Bier",
                               @"Bruin Bier",
                               @"Voorjaarsbieren",
                               @"Amber Bier",
                               @"Biologisch Bier",
                               @"Kerstbier Winterbier",
                               @"Tripel Bier",
                               @"Lambik Bier", nil];
        
        NSMutableArray *raw = [NSMutableArray arrayWithCapacity: [rawPhrases count]];
        
        for (NSString *s in rawPhrases) {
            DistanceString *ds = [[DistanceString alloc] init];
            
            ds.phrase = s;
            ds.value = 0; // uncalculated
            [raw addObject: ds];
        }
        
        _dataSet = [NSArray arrayWithArray: raw];
    }
    
    return _dataSet;
}

#pragma mark - Init


- (void)viewDidLoad
{
    [super viewDidLoad];

	self.filteredData = [NSMutableArray arrayWithCapacity: [self.dataSet count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchDisplayController isActive]) {
        return [self.filteredData count];
    } else {
        return [self.dataSet count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DefaultCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    // Configure the cell...
    DistanceString *ds = nil;
    if ([self.searchDisplayController isActive]) {
        ds = [self.filteredData objectAtIndex: indexPath.row];
    } else {
        ds = [self.dataSet objectAtIndex: indexPath.row];
    }
    
    cell.textLabel.text = ds.phrase;
    
    return cell;
}


NSComparisonResult (^compareDistanceStrings)(id obj1, id obj2) = ^(id obj1, id obj2){
    DistanceString *de1 = (DistanceString *)obj1;
    DistanceString *de2 = obj2;

    if (de1.value < de2.value) {
        return NSOrderedAscending;
    } else if (de1.value > de2.value) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
    
    return NSOrderedSame;
};


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredData removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"phrase contains[cd] %@", searchText];
    NSArray *filteredArray = [self.dataSet filteredArrayUsingPredicate: pred];
    
    // Create array of structures the size of the results list for sorting
    NSMutableArray *weightedDistances = [[NSMutableArray alloc] initWithCapacity: [self.dataSet count]];
    
    // Calculate the levenshtein distance value for each word in the list to sort with
    for (DistanceString *phraseB in filteredArray) {
        float value = [LevenshteinDistance weightedDistance:searchText StringB: phraseB.phrase];
        
        phraseB.value = value;
        [weightedDistances addObject: phraseB];
    }
    [weightedDistances sortUsingComparator: compareDistanceStrings];
    
    self.filteredData = weightedDistances;
    
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}



@end
