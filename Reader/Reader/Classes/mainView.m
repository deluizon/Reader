//
//  mainView.m
//  Reader
//
//  Created by David Samuel on 6/4/10.
//  Copyright 2010 Institut Teknologi Bandung. All rights reserved.
//

#import "mainView.h"
#import "page.h"
#import <objc/runtime.h>		//necessary for tweaking the UIWebView

/*@interface mainView (Private)													//adding method for mainView
- (void)fireZoomingEndedWithTouches:(NSSet*)touches event:(UIEvent*)event;		//when two finger is ended touching the UIWebView mainView
- (void)fireZoomingStartedWithTouches:(NSSet*)touches event:(UIEvent*)event;	//when two finger is start touching the UIWebView mainView
- (void)fireTappedWithTouch:(UITouch*)touch event:(UIEvent*)event;				//when there is one touch end on UIWebView
- (void)fireTappedWithBegan:(UITouch*)touch event:(UIEvent*)event;				//when there is one touch begin on UIWebView
- (void)fireTappedMoved:(UITouch*)touch event:(UIEvent*)event;					//when the touch is moved

@end

@implementation UIView (__TapHook)

- (void)__touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event				
{
	
	
	id webView = [[self superview] superview];
	if (touches.count > 1) {
		if ([webView respondsToSelector:@selector(fireZoomingEndedWithTouches:event:)]) {
			[webView fireZoomingEndedWithTouches:touches event:event];
		}
	}
	else {
		if ([webView respondsToSelector:@selector(fireTappedWithTouch:event:)]) {
			[webView fireTappedWithTouch:[touches anyObject] event:event];
		}
	}
	[self __touchesEnded:touches withEvent:event];
}

-(void)__touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	
	id webView = [[self superview]superview];
	if(touches.count>1){
		if([webView respondsToSelector:@selector(fireZoomingStartedWithTouches:event:)]){
			[webView fireZoomingStartedWithTouches:touches event:event];
		}
	}
	else{
		
		if([webView respondsToSelector:@selector(fireTappedWithBegan:event:)]){
			[webView fireTappedWithBegan:[touches anyObject] event:event];
		}
	}
	[self __touchesBegan:touches withEvent:event];
}

-(void)__touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	id webView = [[self superview]superview];
	if([webView respondsToSelector:@selector(fireTappedMoved:event:)]){
		[webView fireTappedMoved:[touches anyObject]event:event];
	}
	[self __touchesMoved:touches withEvent:event];
}

@end

static BOOL hookInstalled = NO;

static void installHook()		//this is the method for enabling gesture touch on UIWebView mainView
{
	if (hookInstalled) return;
	
	hookInstalled = YES;
	
	Class klass = objc_getClass("UIWebDocumentView");										//get the class of UIWebDocumentView
	Method targetMethod = class_getInstanceMethod(klass, @selector(touchesEnded:withEvent:));			//get the default method
	Method newMethod = class_getInstanceMethod(klass, @selector(__touchesEnded:withEvent:));			//method we created
	method_exchangeImplementations(targetMethod, newMethod);								//change the default event handler with the one we created before
	
	Method targetMethod2 = class_getInstanceMethod(klass, @selector(touchesBegan:withEvent:));			//get the default method
	Method newMethod2 = class_getInstanceMethod(klass, @selector(__touchesBegan:withEvent:));			//method we created
	method_exchangeImplementations(targetMethod2, newMethod2);		//change the default event handler with the one we created before
	
	Method targetMethod3 = class_getInstanceMethod(klass, @selector(touchesMoved:withEvent:));			//get the default method
	Method newMethod3 = class_getInstanceMethod(klass, @selector(__touchesMoved:withEvent:));			//method we created
	method_exchangeImplementations(targetMethod3, newMethod3);	
}
*/

@implementation mainView
@synthesize arrayPages,timer,magnifier,accelerometer;

-(id)initWithFrame:(CGRect)frame{	//initialization of this object will call this method
	if(self=[super initWithFrame:frame]){
		UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wood_bg.jpg"]];	//init a background
		self.backgroundColor=[UIColor clearColor];
		[self addSubview: background];			//add the background to our mainview
		[self sendSubviewToBack:background];	//move the background view to the back of UIWebView
		[background release];					//don't forget to release what's been allocated
		
		
		//init the arrayPages
		arrayPages =[[NSMutableArray alloc]initWithCapacity:5];
		//we hard code the page the page, but you can fill the content from anywhere later, e.g the XML web service
		page *pageone =[[page alloc]init];
		pageone.title=@" This is Page One";
		pageone.imageName=@"monkey";
		pageone.description=@"This is a monkey";
		[arrayPages addObject:pageone];
		[pageone release];
		
		page *pagetwo =[[page alloc]init];
		pagetwo.title=@"This is Page Two";
		pagetwo.imageName=@"dog";
		pagetwo.description=@"This is a dog";
		[arrayPages addObject:pagetwo];
		[pagetwo release];
		
		//initialization for this UIWebView delegate (javascript function)
		self.delegate=self;
		
		//initialization for swiping
		//installHook();		//install the hook
		
		magnifyTouch =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(magnifyTouchHandler:)];
		magnifyTouch.minimumPressDuration=0.5;
		magnifyTouch.numberOfTouchesRequired=1;
		magnifyTouch.delaysTouchesBegan=YES;
		magnifyTouch.delegate=self;
		[self addGestureRecognizer:magnifyTouch];
		[magnifyTouch release];
		
		UISwipeGestureRecognizer *swipeLeft =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftHandler)];
		swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
		[self addGestureRecognizer:swipeLeft];
		[swipeLeft release];
		
		UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightHandler)];
		swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
		[self addGestureRecognizer:swipeRight];
		[swipeRight release];
		
		panTouch = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panTouchHandler:)];
		panTouch.delaysTouchesBegan=YES;
		[panTouch release];
		
		self.accelerometer = [UIAccelerometer sharedAccelerometer];
		self.accelerometer.updateInterval = .1;
		self.accelerometer.delegate = self;
		
		
	}
	return self;
}

-(void)magnifyTouchHandler:(UILongPressGestureRecognizer*)touch{
	NSLog(@"pembesar");
	 
	 // just create one magnifier and re-use it.
	 if(magnifier == nil){
	 magnifier = [[MagnifierView alloc] init];
	 magnifier.viewToMagnify = self;
	 }
	[self.superview addSubview:magnifier];
	 magnifier.touchPoint = [touch locationInView:self];
	 [magnifier setNeedsDisplay];
	if(touch.state==UIGestureRecognizerStateEnded){
		[self.timer invalidate];
		self.timer=nil;
		[magnifier removeFromSuperview];
	}
	
}

-(void)panTouchHandler:(UIPanGestureRecognizer*)touch{
	NSLog(@"sam");
	magnifier.touchPoint = [touch locationInView:self];
	[magnifier setNeedsDisplay];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
	shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	
	return YES;
}

-(void)swipeLeftHandler{
	NSString *filePath=[[NSBundle mainBundle]pathForResource:@"page-flip-1" ofType:@"wav"];
	NSURL *aFileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
	OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL,&audioSID);
	if(error==0)
	{
		[self play:nil];	//play the sound
	}
	
	
	/*[UIView beginAnimations:nil context:NULL];
	 [UIView setAnimationDuration:1.0];
	 
	 [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
	 forView:self cache:YES];*/
	//[UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationTransitionCurlUp animations:^{self.alpha=0.0;} completion:^ (BOOL finished) {}];
	
	[self produceHTMLForPage:2];
}

-(void)swipeRightHandler{
	NSString *filePath=[[NSBundle mainBundle]pathForResource:@"page-flip-1" ofType:@"wav"];
	NSURL *aFileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
	OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL,&audioSID);
	if(error==0)
	{
		[self play:nil];	//play the sound
	}
	NSLog(@"caucau");
	
	/*[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
						   forView:self cache:YES];*/
	[self produceHTMLForPage:1];	
}

-(void)produceHTMLForPage:(NSInteger)pageNumber{

	NSMutableString* string =[[NSMutableString alloc]initWithCapacity:10];	//init a mutable string, initial capacity is not a problem, it is flexible
	[string appendString:
	@"<html>"
		"<head>"
		"<meta name=\"viewport\" content=\"width=320\"/>"
			"<script>"
				"function imageClicked(){"
					"var clicked=true;"
					"window.location=\"/click/\"+clicked;"
					"}"
			"</script>"
		"</head>"
		"<body>"
	 ];
		
	[string appendString:[NSString stringWithFormat:@"<center><h1>%@</h1></center>",[[arrayPages objectAtIndex:pageNumber-1]title]]];
	[string appendString:@"<center><a href=\"javascript:void(0)\" onMouseDown=\"imageClicked()\">"];
	[string appendString:[self produceImage:[[arrayPages objectAtIndex:pageNumber-1]imageName] withType:@"jpg"]];
	[string appendString:@"</a></center>"];
	[string appendString:[NSString stringWithFormat:@"<br><br><center>%@<center>",[[arrayPages objectAtIndex:pageNumber-1]description]]];
	[string appendString:@"</body>"
	 "</html>"
	 ];		//creating the HTMLString
	[self loadHTMLString:string baseURL:nil];		//load the HTML String on UIWebView
	[string release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {	//linking the javascript to call the iPhone control
	if ( [request.mainDocumentURL.relativePath isEqualToString:@"/click/false"] ) {	
		NSLog( @"not clicked" );
		return false;
	}
	
	if ( [request.mainDocumentURL.relativePath isEqualToString:@"/click/true"] ) {		//the image is clicked, variable click is true
		NSLog( @"image clicked" );
		
		UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"JavaScript called" message:@"You've called iPhone provided control from javascript!!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return false;
	}
	
	return true;
}

/*
-(void)fireTappedWithBegan:(UITouch*)touch event:(UIEvent*)event{		//When there is a touch start on the UIWebView
	int noTouchesInEvent = ((NSSet *)[event allTouches]).count;			//Get all touch on the event
	
	if((stateSwipe==S0)&&(noTouchesInEvent==1)){						//Make sure the state of swipe is starting and there is only one touch in the event
		startLocation=[touch locationInView:self];						//get the start location point
		startTime=[touch timestamp];									//get the time
		stateSwipe=S1;													//state of the swipe is changed to S1
	}
	else{
		stateSwipe=S0;
	}
	
}

- (void)fireTappedWithTouch:(UITouch*)touch event:(UIEvent*)event{		//when a touch is ending
	int noTouchesInEvent = ((NSSet*)[event allTouches]).count;			//get all touch on the event 

	if((stateSwipe==S1)&&(noTouchesInEvent==1)){						//Make sure the state of swipe has already on the S1, and there is only one touch in the event
		endLocation=[touch locationInView:self];						//get the end location
		endTime=[touch timestamp];										

	
		stateSwipe=S0;											
		if((fabs(startLocation.y-endLocation.y)<=Y_TOLERANCE)&&
		   (fabs(startLocation.x-endLocation.x)>=X_TOLERANCE)){	//checking the swipe so it fulfill the minimal condition of swiping which is the swiping is acceptable
			
			//initializing the sound for turned image
			NSString *filePath=[[NSBundle mainBundle]pathForResource:@"page-flip-1" ofType:@"wav"];
			NSURL *aFileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
			OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL,&audioSID);
			if(error==0)
			{
				[self play:nil];	//play the sound
			}
			
			
			if(endLocation.x>startLocation.x){				//checking the direction of swiping
				
				[UIView beginAnimations:nil context:NULL];	//start setting the animation of curling down page
				[UIView setAnimationDuration:1.0];			//set the duration
				
				[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown	//animation of curling down
									   forView:self cache:YES];
				[self produceHTMLForPage:1];				//change the page to page 1
				
				}
			
			else{
				
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:1.0];
			
				[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
									   forView:self cache:YES];
				[self produceHTMLForPage:2];
				
				}
		}
		[UIView commitAnimations];			//execute the animation
	}
	
}

-(void)fireTappedMoved:(UITouch*)touch withEvent:(UIEvent*)event{
}*/

-(NSString*)produceImage:(NSString*)imageName withType:(NSString*)imageType{
	NSMutableString *returnString=[[[NSMutableString alloc]initWithCapacity:100]autorelease];
	NSString *filePath = [[NSBundle mainBundle]pathForResource:imageName ofType:imageType];
	if(filePath){
		[returnString appendString:@"<IMG SRC=\"file://"];
		[returnString appendString:filePath];
		[returnString appendString:@"\" ALT=\""];
		[returnString appendString:imageName];
		[returnString appendString:@"\">"];
		return returnString;
	}
	else
		return @"";
}

-(void)play:(NSTimer*)theTimer{					//implementation of the play sound
	AudioServicesPlaySystemSound(audioSID);
}

-(void)drawRect:(CGRect)rect{		//method that's called to draw the view
	[self produceHTMLForPage:1];
} 



- (void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)aceler {
	
    if (fabsf(aceler.x) > 1.5)
    {
        shake = YES;
        [NSTimer scheduledTimerWithTimeInterval:.75 target:self selector:@selector(endShake) userInfo:nil repeats:NO];
        return;
    }
	
    if(shake)
    {
        totalG += aceler.x;
    }
}

- (void) endShake {
    shake = NO;
    if (totalG < 0) [self swipeLeftHandler];
    if(totalG > 0) [self swipeRightHandler];
    totalG = 0;
}


-(void)dealloc{			
	[arrayPages release];
	[super dealloc];
}



@end
