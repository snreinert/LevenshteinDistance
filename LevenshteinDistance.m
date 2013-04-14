/*
 * LevenshteinDistance.m
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

#import "LevenshteinDistance.h"

#define PHRASE_WEIGHT    1.0
#define WORD_WEIGHT      0.5
#define MIN_WEIGHT       10
#define MAX_WEIGHT       1
#define LENGTH_WEIGHT    -0.3



@implementation LevenshteinDistance


#pragma Edit Distance

+(int) calcStringA:(NSString *) stringA StringB:(NSString *) stringB {
    int stringALen = [stringA length];
    int stringBLen = [stringB length];
    
    // This will hold the calculations that we'll use to find the edit distance
    int dist[stringALen + 1][stringBLen + 1];
    
    // loop counters
    int stringAPos, stringBPos;
    
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
    const char *cStringA = [stringA cStringUsingEncoding: [NSString defaultCStringEncoding]];
    const char *cStringB = [stringB cStringUsingEncoding: [NSString defaultCStringEncoding]];

    
    // Start loop at 1 so that initial values don't underrun the array
    for (stringBPos = 1; stringBPos <= stringBLen; stringBPos++) {
        for (stringAPos = 1; stringAPos <= stringALen; stringAPos++) {

            /* Create a char array of the next character to check.  The index decremented is by 1 so that we get
             * the first character in each string.
             */
            
            char subStringA[] = { cStringA[stringAPos-1], '\0'};
            char subStringB[] = { cStringB[stringBPos-1], '\0'};
            
            // Case insensitive string comparison of the two single character strings
            int strcmpResult = strcasecmp(subStringA, subStringB);
            
            // Compute cost as a positive 1; each operation in levenshtein distance has a maximum step cost of 1 and min of 0
            int cost = abs(strcmpResult) > 0 ? 1 : 0;
            
            // Insert cost (inserting a character in stringA)
            int costInsert = dist[stringAPos-1][stringBPos] + 1;
            
            // Deletion cost (removing a character from stringB)
            int costDelete = dist[stringAPos][stringBPos - 1] + 1;
            
            // Substitution cost (different character at this position)
            int costSub = dist[stringAPos - 1][stringBPos - 1] + cost;            
            
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

+(float) weightedValueForPhraseValue:(int) phrase wordValue:(int) wordValue lengthValue:(int) lengthValue {
    
    float value = MIN(PHRASE_WEIGHT * phrase, WORD_WEIGHT * wordValue) * MIN_WEIGHT +
                   MAX(PHRASE_WEIGHT * phrase, WORD_WEIGHT * wordValue) * MAX_WEIGHT +
                   LENGTH_WEIGHT * lengthValue;
    
    return value;
}



+(int) valuePhraseA:(NSString *) stringA PhraseB:(NSString *) stringB {
    return [LevenshteinDistance calcStringA: stringA StringB: stringB];
}   

+(int) valueWordsA:(NSString *) stringA WordB:(NSString *) stringB {
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFOptionFlags flags = kCFStringTokenizerUnitWord;

    
    CFRange rangeA = CFRangeMake(0, [stringA length]);
    CFStringTokenizerRef tokenizerRefA = CFStringTokenizerCreate(kCFAllocatorDefault, (CFStringRef) stringA, rangeA, flags, locale);
    
    CFRange rangeB = CFRangeMake(0, [stringB length]);
    CFStringTokenizerRef tokenizerRefB = CFStringTokenizerCreate(kCFAllocatorDefault, (CFStringRef) stringB, rangeB, flags, locale);
    
    int wordBest = 0;
    int wordsTotal = 0;
    
    CFStringTokenizerTokenType nextTokenA = kCFStringTokenizerTokenNone;
    
    // Calculate the distance for each word or token in stringA to each word in stringB
    while ((nextTokenA = CFStringTokenizerAdvanceToNextToken(tokenizerRefA)) != kCFStringTokenizerTokenNone) {
        wordBest = [stringB length];
        
        CFRange wordATokenRange = CFStringTokenizerGetCurrentTokenRange (tokenizerRefA);
        NSRange nswordATokenRange = NSMakeRange(wordATokenRange.location, wordATokenRange.length);
        
        // Grab the token from stringA
        NSString *wordAToken = [stringA substringWithRange: nswordATokenRange];

        // Setup tokenizer for stringB
        CFStringTokenizerTokenType nextTokenB = kCFStringTokenizerTokenNone;
        
        while ((nextTokenB = CFStringTokenizerAdvanceToNextToken(tokenizerRefB)) != kCFStringTokenizerTokenNone) {
            
            CFRange wordBTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizerRefB);
            
            NSRange nswordBTokenRange = NSMakeRange(wordBTokenRange.location, wordBTokenRange.length);
            NSString *wordBToken = [stringB substringWithRange: nswordBTokenRange];
            
            // Only take the best match between any two words in string A and B
            int comparisonD = [self calcStringA:wordAToken StringB:wordBToken];
            
            if (comparisonD < wordBest) {
                wordBest = comparisonD;
            }
            
            if (comparisonD == 0) {
                break;
            }
        }
        
        wordsTotal += wordBest;
    }
    // CFRelease is the contract required for any CFCreate functions
    CFRelease(tokenizerRefA);
    CFRelease(tokenizerRefB);
    CFRelease(locale);
    
    return wordsTotal;
}

+(float) weightedDistance:(NSString *)stringA StringB:(NSString *)stringB {
    int phraseValue = [LevenshteinDistance valuePhraseA:stringA
                                                PhraseB:stringB];
    
    int wordValue = [LevenshteinDistance valueWordsA:stringA
                                               WordB:stringB];
    
    int len = [stringA length] - [stringB length];
    
    float weightedValue = [LevenshteinDistance weightedValueForPhraseValue:phraseValue wordValue:wordValue lengthValue: len];
    return weightedValue;
}

@end
