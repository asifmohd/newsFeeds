//
//  FacebookViewController.m
//  NewsFeed
//
//  Created by Mohd Asif on 18/05/14.
//  Copyright (c) 2014 Asif. All rights reserved.
//

#import "FacebookViewController.h"
#import "Card.h"
#import "Card+Create.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSMutableArray *imageSizeArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIManagedDocument *managedDocument;
@property (strong, nonatomic) NSManagedObjectContext *managedContext;
@property (nonatomic) BOOL documentReady;

@end

@implementation FacebookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    FBLoginView *loginView;
    loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"read_streams"]];
    self.documentReady = NO;
    [self initDatabase];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initDatabase {
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    
    self.managedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.managedContext setPersistentStoreCoordinator:psc];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[filemgr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *docName = @"MyDocument";
    NSError *err;
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:docName];
    
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:@{NSSQLitePragmasOption: @{@"journal_mode": @"delete"}} error:&err]) {
        NSLog(@"Error occured when creating persistent store : %@", err);
    }
    else
    {
        self.documentReady = YES;
        [self getData];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (cell) {
    //    UIImageView *photoImgView = (UIImageView *)[cell viewWithTag:30];
    //    return photoImgView.image.size.height + 130;
    //    }
    if (self.imageSizeArray[indexPath.row]) {
        return [(NSNumber *) self.imageSizeArray[indexPath.row] floatValue] + 130;
    }
    return 200;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Message Cell" forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    
    // setup profile picture
    Card *myCard = [Card cardWithFBData:self.dataArray[row] inManagedObjectContext:self.managedContext];
    UIImageView *img = (UIImageView *)[cell viewWithTag:10];
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", NULL);
    dispatch_async(myQueue, ^{
        UIImage *profilePicImg = [[UIImage alloc] initWithData:(NSData *)myCard.profilePicImg];
        dispatch_async(dispatch_get_main_queue(),^{[img setImage:profilePicImg];});
    });
    
    
    // Setting the heading label
    UILabel *headingLabel = (UILabel *)[cell viewWithTag:15];
    if (headingLabel) {
        if (self.dataArray[row][@"story"])
            headingLabel.attributedText = [[NSAttributedString alloc] initWithString:self.dataArray[row][@"story"]];
        else if (self.dataArray[row][@"message"])
            headingLabel.attributedText = [[NSAttributedString alloc] initWithString:self.dataArray[row][@"message"]];
    }
    
    // Setting the photo if the dataArray has one
    UIImageView *photoImgView = (UIImageView *)[cell viewWithTag:30];
    photoImgView.hidden = NO;
    photoImgView.image = nil;
    if ([self.dataArray[row][@"type"] isEqualToString:@"photo"]) {
        dispatch_async(myQueue, ^{
            NSData *imgData = [[NSData alloc] initWithData:myCard.picture];
            // alternate method to get image using _n
            //            if (!imgData) {
            //                NSMutableString *string = [[NSMutableString alloc] initWithString:self.dataArray[row][@"picture"]];
            //                [string replaceCharactersInRange:NSMakeRange([string length] - 5, 1) withString:@"n"];
            //                NSLog(@"Image url is : %@", string);
            //                NSData *imgData = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:string]];
            //            }
            UIImage *photoImg = [[UIImage alloc] initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [photoImgView setImage:photoImg];
                photoImgView.contentMode = UIViewContentModeScaleAspectFill;
                [self.imageSizeArray addObject:@(photoImgView.frame.size.height)];
            });
        });
    }
    
    // Setting the message if the type is of status
    UILabel *statusMessage = (UILabel *) [cell viewWithTag:20];
    statusMessage.text = nil;
    if ([self.dataArray[row][@"type"] isEqualToString:@"status"]) {
        photoImgView.hidden = YES;
        statusMessage.text = self.dataArray[row][@"message"];
        statusMessage.font = [UIFont systemFontOfSize:11];
        [statusMessage sizeToFit];
    }
    
    // Configure the cell...
    
    return cell;
}

- (void) getData {
    int limit = 5;
//    NSString *field = @"fields=from,message,type,story,picture,link,actions,created_time,updated_time,shares,likes,object_id&";
    NSString *graphPath = [NSString stringWithFormat:@"me/home?limit=%d", limit];
    [FBRequestConnection startWithGraphPath:graphPath completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"%d", [(FBGraphObject *)result[@"data"] count]);
            NSLog(@"Result[data] : %@", result[@"data"]);
            dispatch_queue_t myQueue2 = dispatch_queue_create("myQueue2", NULL);
            if ([result[@"data"] isKindOfClass:[NSArray class]]) {
                dispatch_async(myQueue2, ^{
                    NSMutableArray *mutableDataArray = [[NSMutableArray alloc] init];
                    for (NSDictionary *entry in (NSArray *)result[@"data"]) {
                        // save to Database
                        Card *card = [Card cardWithFBData:entry inManagedObjectContext:self.managedContext];
                        if (!card.uniqueId) {
                            card.from_id = entry[@"from"][@"id"];
                            card.from_name = entry[@"from"][@"name"];
                            card.uniqueId = entry[@"id"];
                            card.message = entry[@"message"];
                            card.picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", entry[@"object_id"]]]];
                            card.profilePicImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal", entry[@"from"][@"id"]]]];
                            card.actions_comment_link = entry[@"actions"][0][@"link"];
                            if ([entry[@"actions"] count] == 2)
                                card.actions_like_link = entry[@"actions"][1][@"link"];
                            card.type = entry[@"type"];
                            card.status_type = entry[@"status_type"];
                            card.object_id = entry[@"object_id"];
                            card.shares_count = entry[@"shares"][@"count"];
                            NSLog(@"Inserted new card with uniqueId : %@", entry[@"id"]);
                        }
                        else
                            NSLog(@"Card with uniqueId: %@ already exists", card.uniqueId);
                        [mutableDataArray addObject:entry];
    //                    NSLog(@"entries uniqueId : %@", entry[@"id"]);
                    }
                    self.dataArray = result[@"data"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [self.managedContext save:NULL];
                    });
                });
            }
            else
                NSLog(@"Result is not a type of NSArray in getData");
        }
        else
            NSLog(@"Error in FBRequestConnection completionHandler: %@", error);
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
