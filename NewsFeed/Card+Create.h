//
//  Card+Create.h
//  NewsFeed
//
//  Created by Mohd Asif on 18/05/14.
//  Copyright (c) 2014 Asif. All rights reserved.
//

#import "Card.h"

@interface Card (Create)

+ (Card *) cardWithFBData:(NSDictionary *) FBData
   inManagedObjectContext:(NSManagedObjectContext *) context;

@end
