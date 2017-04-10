/*
 *  LevenshteinDistance.h
 *
 *  Created by Steve Reinert on 3/3/13.
 *  Copyright (c) 2013 Salt River Software. All rights reserved.
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
 */

#import <Foundation/Foundation.h>

@interface LevenshteinDistance : NSObject

/**
 * Calculate the Levenshtein Distance between stringA and stringB.  Return
 * the raw (unweighted) value as defined by the Levenshtein Distance algorithm.
 */
+(NSInteger) calcStringA:(NSString *) stringA StringB:(NSString *) stringB;

/**
 * Calculate the Levenshtein Distance of two strings as a whole phrase instead of individual words separated by spaces.
 */
+(NSInteger) valuePhraseA:(NSString *) stringA PhraseB:(NSString *) stringB;
/**
 * Calculate the Levenshtein Distance of two strings as tokens, which are tokenized by locale.
 */
+(NSInteger) valueWordsA:(NSString *) stringA WordB:(NSString *) stringB;
/**
 * Calculate the weighted value of a phrase, word, and length result of previous calculations.  The lengthValue is the
 * difference in length between string A and string B.
 */
+(float) weightedValueForPhraseValue:(NSInteger) phrase wordValue:(NSInteger) wordValue lengthValue:(NSInteger) lengthValue;

/**
 * Return the weighted distance as an aggregate value.  Two calculations are performed: a phrase
 * distance calculation and a word distance calculation.  The word tokenizing is determined by the
 * user's current locale.
 *
 * A large phrase distance value is given more weight than individual word distance
 * values.  This is so that a whole phrase match (or low distance) is prefered over
 * indivdual words matching.  These parameters can be changed depending on the application.
 */
+(float) weightedDistance:(NSString *) stringA StringB:(NSString *) stringB;
@end
