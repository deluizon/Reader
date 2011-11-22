//
//  ReaderViewController.m
//  Reader
//
//  Created by David Samuel on 6/4/10.
//  Copyright Institut Teknologi Bandung 2010. All rights reserved.
//

#import "ReaderViewController.h"
#import "mainView.h"


@implementation ReaderViewController
@synthesize _mainView;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	_mainView = [[mainView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];		//initialize a mainView
	self.view=_mainView;	//make the mainView as the view of this controller
	[_mainView release];	//don't forget to release what you've been allocated
	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_mainView release];
    [super dealloc];
}

@end
