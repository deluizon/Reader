//
//  page.h
//  Reader
//
//  Created by David Samuel on 6/6/10.
//  Copyright 2010 Institut Teknologi Bandung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface page : NSObject {
	NSString *title;			//title of the page
	NSString* imageName;		//name of the image
	NSString *description;		//a little text for description
	
}

@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *imageName;
@property(nonatomic,retain) NSString *description;

@end
