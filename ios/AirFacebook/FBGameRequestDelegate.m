//
//  FBGameRequestDelegate.m
//  AirFacebook
//
//  Created by Adam Schlesinger on 8/21/15.
//
//

#import "FBGameRequestDelegate.h"
#import "AirFacebook.h"

@implementation FBGameRequestDelegate
{
    NSString *callback;
}

- (id)initWithCallback:(NSString *)aCallback
{
    if( self = [super init] )
    {
        callback = aCallback;
    }
    
    return self;
}

- (void)gameRequestWithContent:(FBSDKGameRequestContent *)content enableFrictionless:(BOOL)frictionless
{
    FBSDKGameRequestDialog *dialog = [[FBSDKGameRequestDialog alloc] init];
    dialog.content = content;
    dialog.delegate = self;
    dialog.frictionlessRequestsEnabled = frictionless;
    
    [dialog show];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results
{
    NSString *resultString = [AirFacebook jsonStringFromObject:results andPrettyPrint:NO];
    [AirFacebook log:@"REQUEST_COMPLETE JSON: %@", resultString];
    [AirFacebook dispatchEvent:callback withMessage:resultString];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error
{
    [AirFacebook log:@"REQUEST_ERROR error: %@", [error description]];
    [AirFacebook dispatchEvent:callback withMessage:[error description]];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog
{
    [AirFacebook log:@"REQUEST_CANCEL"];
    [AirFacebook dispatchEvent:callback withMessage:@"OK"];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

@end
