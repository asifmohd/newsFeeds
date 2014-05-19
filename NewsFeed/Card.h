//
//  Card.h
//  NewsFeed
//
//  Created by Mohd Asif on 18/05/14.
//  Copyright (c) 2014 Asif. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * actions_comment_link;
@property (nonatomic, retain) NSString * actions_like_link;
@property (nonatomic, retain) NSNumber * shares_count;
@property (nonatomic, retain) NSString * from_id;
@property (nonatomic, retain) NSString * from_name;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * object_id;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSString * status_type;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSData * profilePicImg;

@end
