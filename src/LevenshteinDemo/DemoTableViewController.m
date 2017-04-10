/*
 * DemoTableViewController.m
 * Copyright 2013, 2017 Salt River Software, LLC
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
#import "SearchResultsTableViewController.h"

@interface DemoTableViewController ()<UISearchControllerDelegate, UISearchBarDelegate> {
}

@property (nonatomic, retain) NSArray *dataSet;
@property (nonatomic, retain) NSMutableArray *filteredData;
@property (nonatomic) UISearchController *searchController;

@end

@implementation DemoTableViewController

#pragma mark - Properties

-(NSArray *) dataSet {
    if (_dataSet == nil) {
        
        _dataSet = [NSArray arrayWithObjects:
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
        
    }
    
    return _dataSet;
}

#pragma mark - View Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    SearchResultsTableViewController *stvc = [self.storyboard instantiateViewControllerWithIdentifier: @"SearchResultsTableView"];
    stvc.dataSet = self.dataSet;
    stvc.contextFrame = self.view.frame;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController: stvc];
    self.searchController.searchResultsUpdater = stvc;
    self.searchController.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame: self.searchController.searchBar.frame];
    [self.tableView.tableHeaderView addSubview: self.searchController.searchBar];
    
    UISearchBar *sb = self.searchController.searchBar;
    [sb sizeToFit];
    sb.tintColor = [UIColor colorWithRed: 0.882 green: 0.400 blue: 0.333 alpha: 1];
    sb.searchBarStyle = UISearchBarStyleMinimal;
    sb.translucent = NO;
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
    return [self.dataSet count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BeerCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = self.dataSet[indexPath.row];
    
    return cell;
}

#pragma mark - UISearchBarDelegate

-(UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

-(void) willPresentSearchController:(UISearchController *)searchController {
    [searchController.searchBar sizeToFit];
}

@end
