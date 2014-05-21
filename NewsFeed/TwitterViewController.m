//
//  TwitterViewController.m
//  NewsFeed
//
//  Created by Mohd Asif on 21/05/14.
//  Copyright (c) 2014 Asif. All rights reserved.
//

#import "TwitterViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TwitterViewController ()

@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation TwitterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (BOOL) userHasAccessToTwitter {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void) fetchTimelineForUser: (NSString *) username {
    if ([self userHasAccessToTwitter]) {
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                              @"/1.1/statuses/user_timeline.json"];
                NSDictionary *params = @{@"screen_name" : username,
                                         @"include_rts" : @"0",
                                         @"trim_user" : @"1",
                                         @"count" : @"1"};
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                
                [request setAccount:[twitterAccounts lastObject]];
                
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (responseData) {
                        if (urlResponse.statusCode >= 200 && urlResponse.statusCode <300) {
                            NSError *jsonError;
                            NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                            if (timelineData) {
                                NSLog(@"Timeline response: %@\n", timelineData);
                            }
                            else {
                                NSLog(@"JSON Error : %@", [jsonError localizedDescription]);
                            }
                        }
                        else {
                            NSLog(@"The response status code is %d", urlResponse.statusCode);
                        }
                    }
                }];
            }
            else {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
    else {
        NSLog(@"User does not have access to Twitter");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchTimelineForUser:@"arshadasif0312"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
