//
//  page.m
//  Reader
//
//  Created by David Samuel on 6/6/10.
//  Copyright 2010 Institut Teknologi Bandung. All rights reserved.
//

#import "page.h"


@implementation page
@synthesize title,imageName,description;

-(id)init{						//method called for the initialization of this object
	if(self=[super init]){}
	return self;
}

-(void)dealloc{					//method called when object is released
	[title release];			//release each member of this object
	[imageName release];
	[description release];
	[super dealloc];
}

@end
