//
//  FilterOperation.m
//  Strength Mark
//
//  Created by Steve Reinert on 5/31/14.
//  Copyright (c) 2014 Salt River Software. All rights reserved.
//

#import "FilterOperation.h"
#import "LevenshteinDistance.h"
#import "DistanceString.h"

@implementation FilterOperation

-(id) initWithSearchString:(NSString *)searchString andExerciseList:(NSArray *)searchExercises {
    if (self = [super init]) {
        self.searchExercises = searchExercises;
        self.searchString = searchString;

        FilterOperation __weak *weakSelf = self;
        self.completionBlock = ^{
            [(NSObject *)weakSelf.delegate performSelectorOnMainThread:@selector(filterOperationDidFinish:) withObject: weakSelf waitUntilDone: NO];
        };
        
    }
    
    return self;
}

-(void) main {
    @autoreleasepool {
        self.filteredList = [self filterExerciseArray: self.searchExercises withSearchText: self.searchString andScopeText: nil];
    }
}


-(NSMutableArray *) filterExerciseArray:(NSArray *)listContent withSearchText:(NSString *)searchText andScopeText:(NSString *)scopeText  {
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchText];
    NSArray *filteredArray = [listContent filteredArrayUsingPredicate: pred];
    
    NSInteger itemCount = [filteredArray count];
    
    // Create array of structures the size of the results list for sorting
    NSMutableArray *weightedArray = [[NSMutableArray alloc] initWithCapacity: itemCount];
    
    int i = 0;
    
    // Calculate the levenshtein distance value for each word in the list to sort with
    for (NSString *beer in filteredArray) {
        if ([self isCancelled]) {
            break;
        }
        
        float value = [LevenshteinDistance weightedDistance:searchText StringB: beer];
        // Add struct to array
        DistanceString *ds = [DistanceString new];
        ds.value = value;
        ds.phrase = beer;
        
        weightedArray[i++] = ds;
    }
    
    [weightedArray sortUsingComparator:^(id obj1, id obj2) {
        DistanceString *d1 = obj1;
        DistanceString *d2 = obj2;
        
        if (d1.value < d2.value) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    NSMutableArray *sortedArray = [weightedArray valueForKeyPath:@"@unionOfObjects.phrase"];
    return sortedArray;
}

@end
