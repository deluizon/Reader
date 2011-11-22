//
//  ReaderAppDelegate.m
//  Reader
//
//  Created by David Samuel on 6/4/10.
//  Copyright Institut Teknologi Bandung 2010. All rights reserved.
//

#import "ReaderAppDelegate.h"
#import "ReaderViewController.h"

@implementation ReaderAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
