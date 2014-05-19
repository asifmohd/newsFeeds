//
//  Card+Create.m
//  NewsFeed
//
//  Created by Mohd Asif on 18/05/14.
//  Copyright (c) 2014 Asif. All rights reserved.
//

#import "Card+Create.h"

@implementation Card (Create)

+ (Card *) cardWithFBData:(NSDictionary *) FBData
   inManagedObjectContext:(NSManagedObjectContext *) context {
    Card *card;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
    request.fetchBatchSize = 5;
    request.fetchLimit = 10;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId = %@", FBData[@"id"]];
    request.predicate = predicate;
    NSError *err;
    NSArray *cards = [context executeFetchRequest:request error:&err];
    NSLog(@"Predicate is %@", predicate);
    if (!err) {
        if (![cards count]) {
            card = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:context];
        }
        else {
            NSLog(@"Data with id %@ already exists", FBData[@"id"]);
            card = [cards firstObject];
        }
    }
    return card;
}

@end
