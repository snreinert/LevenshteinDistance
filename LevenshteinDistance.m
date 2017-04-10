/*
*  LevenshteinDistance.m
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

#import "LevenshteinDistance.h"

#define PHRASE_WEIGHT    10.0
#define WORD_WEIGHT      0.5
#define MIN_WEIGHT       5
#define MAX_WEIGHT       1
#define LENGTH_WEIGHT    -0.3


@implementation LevenshteinDistance


#pragma Edit Distance

+(NSInteger) calcStringA:(NSString *) stringA StringB:(NSString *) stringB {
    stringA = [stringA uppercaseString];
    stringB = [stringB uppercaseString];
    NSInteger stringALen = [stringA length];
    NSInteger stringBLen = [stringB length];
    
    // This will hold the calculations that we'll use to find the edit distance
    NSInteger dist[stringALen + 1][stringBLen + 1];
    
    // loop counters
    NSInteger stringAPos, stringBPos;
    
    /* Init the distance array.  The first dimension [i] is associated with stringA
     * and the second [j] is associated with stringB.
     */
    for (stringAPos = 0; stringAPos <= stringALen; stringAPos++) {
        dist[stringAPos][0] = stringAPos;
    }
    
    for (stringBPos = 0; stringBPos <= stringBLen; stringBPos++) {
        dist[0][stringBPos] = stringBPos;
    }
    
    // Work with C strings instead of NSString so positional access is more direct
    
    // Start loop at 1 so that initial values don't underrun the array
    for (stringBPos = 1; stringBPos <= stringBLen; stringBPos++) {
        for (stringAPos = 1; stringAPos <= stringALen; stringAPos++) {

            /* Create a char array of the next character to check.  The index decremented is by 1 so that we get
             * the first character in each string.
             */
            
            
            unichar subStringA = [stringA characterAtIndex: stringAPos - 1];
            unichar subStringB = [stringB characterAtIndex: stringBPos - 1];
            
            // Case insensitive string comparison of the two single character strings
            NSInteger strcmpResult = subStringA - subStringB;
            

            
            // Compute cost as a positive 1; each operation in levenshtein distance has a maximum step cost of 1 and min of 0
            NSInteger cost = labs(strcmpResult) > 0 ? 1 : 0;
            
            // Insert cost (inserting a character in stringA)
            NSInteger costInsert = dist[stringAPos-1][stringBPos] + 1;
            
            // Deletion cost (removing a character from stringB)
            NSInteger costDelete = dist[stringAPos][stringBPos - 1] + 1;
            
            // Substitution cost (different character at this position)
            NSInteger costSub = dist[stringAPos - 1][stringBPos - 1] + cost;
            
            // Find the minimum cost operation and store it
            if (costInsert <= costDelete) {
                if (costInsert <= costSub) {
                    dist[stringAPos][stringBPos] = costInsert;
                } else {
                    dist[stringAPos][stringBPos] = costSub;
                }
            } else {
                if (costDelete <= costSub) {
                    dist[stringAPos][stringBPos] = costDelete;
                } else {
                    dist[stringAPos][stringBPos] = costSub;
                }
            }
        }
    }
    
    // Return the distance cost found at the last indexes; this is our Levenshtein Distance
    return dist[stringALen][stringBLen];
    
}

+(float) weightedValueForPhraseValue:(NSInteger) phrase wordValue:(NSInteger) wordValue lengthValue:(NSInteger) lengthValue {
    float minVal = MIN(PHRASE_WEIGHT * phrase, WORD_WEIGHT * wordValue) * MIN_WEIGHT;
    float maxVal = MAX(PHRASE_WEIGHT * phrase, WORD_WEIGHT * wordValue) * MAX_WEIGHT;
    
    float lenVal = LENGTH_WEIGHT * lengthValue;
    float value =  minVal + maxVal + lenVal;

    return value;
}



+(NSInteger) valuePhraseA:(NSString *) stringA PhraseB:(NSString *) stringB {
    return [LevenshteinDistance calcStringA: stringA StringB: stringB];
}   

+(NSInteger) valueWordsA:(NSString *) stringA WordB:(NSString *) stringB {
    NSArray *tokensA = [stringA componentsSeparatedByString:@" "];
    NSArray *tokensB = [stringB componentsSeparatedByString:@" "];

    NSInteger wordBest = 0;
    NSInteger wordsTotal = 0;
    
    
    // Calculate the distance for each word or token in stringA to each word in stringB
    for (NSString *wordAToken in tokensA) {
        wordBest = [stringB length];

        for (NSString *wordBToken in tokensB) {
            
            // Only take the best match between any two words in string A and B
            NSInteger comparisonD = [self calcStringA:wordAToken StringB:wordBToken];
            
            if (comparisonD < wordBest) {
                wordBest = comparisonD;
            }
            
            if (comparisonD == 0) {
                break;
            }
        }
        
        wordsTotal += wordBest;
    }
    return wordsTotal;
}


+(float) weightedDistance:(NSString *)stringA StringB:(NSString *)stringB {
    NSInteger phraseValue = [LevenshteinDistance valuePhraseA:stringA
                                                PhraseB:stringB];
    
    NSInteger wordValue = [LevenshteinDistance valueWordsA:stringA
                                               WordB:stringB];
    
    NSInteger len = [stringA length] - [stringB length];
    
    float weightedValue = [LevenshteinDistance weightedValueForPhraseValue:phraseValue wordValue:wordValue lengthValue: len];
    return weightedValue;
}

@end
