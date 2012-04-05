//
//  AirFBRequest.h
//  AirFacebook
//
//  Created by Thibaut Crenn on 3/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import "FBRequest.h"

@interface AirFBRequest : NSObject <FBRequestDelegate>
{
    id *context;
    NSString* name;
    
}

@property (nonatomic, assign) id* context;
@property (nonatomic, retain) NSString* name;

@end
