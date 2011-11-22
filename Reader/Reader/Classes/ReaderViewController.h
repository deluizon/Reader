//
//  ReaderViewController.h
//  Reader
//
//  Created by David Samuel on 6/4/10.
//  Copyright Institut Teknologi Bandung 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class mainView;

@interface ReaderViewController : UIViewController {
	mainView* _mainView;
}

@property (nonatomic,retain)mainView* _mainView;

@end

