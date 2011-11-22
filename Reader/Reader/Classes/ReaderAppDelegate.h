//
//  ReaderAppDelegate.h
//  Reader
//
//  Created by David Samuel on 6/4/10.
//  Copyright Institut Teknologi Bandung 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReaderViewController;

@interface ReaderAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ReaderViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ReaderViewController *viewController;

@end

