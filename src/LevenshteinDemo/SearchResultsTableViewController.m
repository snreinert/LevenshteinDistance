/*
 *  SearchResultsTableViewController.m
 *  LevenshteinDemo
 *
 *  Created by Steve Reinert on 4/3/17.
 *  Copyright © 2017 Salt River Software, LLC. All rights reserved.
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

#import "SearchResultsTableViewController.h"
#import "FilterOperation.h"

@interface SearchResultsTableViewController ()<FilterOperationDelegate>

@property (nonatomic) NSMutableArray *filteredListContent;
@property (nonatomic) NSOperationQueue *searchQueue;
@property (nonatomic) NSString *lastSearchQuery;
@property (nonatomic) BOOL resizedFrame;
@property (nonatomic) BOOL adjustedDuringLayout;




@end

@implementation SearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    
    /*
     * Adjust the positioning of the search results table view and the
     * content position.
     */
    self.tableView.contentOffset = CGPointMake(0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.adjustedDuringLayout = NO;
    
    
    CGRect frame = self.tableView.frame;
    
    // Make sure the search results table view doesn't cover the search bar
    frame.origin.y = 108;
    /*
     * Account for the height difference.
     */
    if (!self.resizedFrame) {
        frame.size.height -= 108;
        self.resizedFrame = YES;
    }
    
    self.tableView.frame = frame;
    
    
    [self.tableView reloadData];
    
}


#pragma mark - Keyboard management

-(void)keyboardOnScreen:(NSNotification *)notification
{
    
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    /*
     * Account for keyboard height to prevent keyboard coverage of bottom search results
     */
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0);
    self.tableView.scrollIndicatorInsets =  UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0);
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *countArray = self.filteredListContent;
    NSInteger count = [countArray count];
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SearchResult";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = self.filteredListContent[indexPath.row];
    return cell;
}


#pragma mark - Content Filtering

-(NSOperationQueue *) searchQueue {
    if (_searchQueue != nil) {
        return _searchQueue;
    }
    
    _searchQueue = [NSOperationQueue new];
    [_searchQueue setName: @"searchqueue"];
    [_searchQueue setQualityOfService: NSQualityOfServiceUserInitiated];
    
    return _searchQueue;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // First cancel any pending search operations, and create a new one
    if (self.searchQueue.operationCount > 0) {
        [self.searchQueue cancelAllOperations];
    }
    
    /*
     Update the filtered array based on the search text and scope.
     */
    NSArray *listData = self.dataSet;
    
    // Create new search operation, then add it to the queue
    FilterOperation *searchFilter = [[FilterOperation alloc] initWithSearchString: searchText andExerciseList: listData];
    
    searchFilter.delegate = self;
    [self.searchQueue addOperation: searchFilter];
}

#pragma mark - FilterOperationDelegate

// Called from the FilterOperation delegate when the search results return
-(void) filterOperationDidFinish:(FilterOperation *)filterOperation {
    self.filteredListContent = filterOperation.filteredList;
    
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating


-(void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.isActive) {
        
        UIEdgeInsets flattenTopEdge = self.tableView.contentInset;
        flattenTopEdge.top = 0;
        self.tableView.contentInset = flattenTopEdge;
        
        [[searchController searchBar] setShowsCancelButton: YES animated: YES];
        
        NSString *searchString = searchController.searchBar.text;
        if ([searchString length] > 0 &&
            ![searchString isEqualToString: self.lastSearchQuery]) {
            
            [self filterContentForSearchText: searchString scope: @""];
        }
    }
    
    self.lastSearchQuery = searchController.searchBar.text;
}

@end
