//
//  FilterOperation.h
//  Strength Mark
//
//  Created by Steve Reinert on 5/31/14.
//  Copyright (c) 2014 Salt River Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FilterOperationDelegate;

/**
 * This class is used to filter exercises.  It could be made more generic to
 * search for other strings too, but at the moment, that's not needed.
 */
@interface FilterOperation : NSOperation

-(id) initWithSearchString:(NSString *) searchString andExerciseList:(NSArray *) searchExercises;

/**
 * The filter expression.
 */
@property (nonatomic) NSString *searchString;
/**
 * The raw data to search.
 */
@property (nonatomic) NSArray *searchExercises;
/**
 * The result from the filter operation.
 */
@property (nonatomic) NSMutableArray *filteredList;
@property (nonatomic, assign) id<FilterOperationDelegate> delegate;


@end

@protocol FilterOperationDelegate <NSObject>

/**
 * This is called when the FilterOperation is finished.
 */
-(void) filterOperationDidFinish:(FilterOperation *) filterOperation;

@end