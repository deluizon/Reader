//
//  mainView.h
//  Reader
//
//  Created by David Samuel on 6/4/10.
//  Copyright 2010 Institut Teknologi Bandung. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MagnifierView.h"

#define Y_TOLERANCE 20			// X tolerance of the swipe condition
#define X_TOLERANCE 20			// X tolerance of the swipe condition

typedef  enum{
	S0,S1
} STATE;		//state of swipe, S0 means begin to touch, S1 means end of swipe

@interface mainView : UIWebView <UIWebViewDelegate,UIGestureRecognizerDelegate,UIAccelerometerDelegate>{	//change it so our main view inherits from UIWebView
	NSMutableArray *arrayPages;			//array of pages
	
	//gesture & touch
	STATE stateSwipe;					
	CGPoint startLocation,endLocation;	
	NSTimeInterval startTime,endTime;
	
	//sound of turned page
	SystemSoundID audioSID;		
	
	//magnifying capability
	UILongPressGestureRecognizer *magnifyTouch;	//the gesture recognizer
	UIPanGestureRecognizer *panTouch;
	NSTimer *timer;				//to determine when the magnifier will appear
	MagnifierView *magnifier;	//the magnifier
	
	
	//shaking capability
	BOOL shake;
	UIAccelerometer *accelerometer;
	UIAccelerationValue totalG;
}

@property(nonatomic,retain)NSMutableArray *arrayPages;
@property(nonatomic,retain)NSTimer *timer;				
@property(nonatomic,retain)MagnifierView *magnifier;
@property(nonatomic,retain)UIAccelerometer *accelerometer;


-(void)produceHTMLForPage:(NSInteger)pageNumber;								//method for generating the HTML for appropriate page
-(NSString*)produceImage:(NSString*)imageName withType:(NSString*)imageType;	//method for attaching image to the HTML

-(void)play:(NSTimer*)theTimer;			//method for playing the short sound

@end
