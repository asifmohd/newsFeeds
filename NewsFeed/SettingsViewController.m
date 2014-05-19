//
//  SettingsViewController.m
//  NewsFeed
//
//  Created by Mohd Asif on 17/05/14.
//  Copyright (c) 2014 Asif. All rights reserved.
//

#import "SettingsViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SettingsViewController()

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginView.readPermissions = @[@"public_profile", @"read_stream"];
	// Do any additional setup after loading the view, typically from a nib.
}


@end
