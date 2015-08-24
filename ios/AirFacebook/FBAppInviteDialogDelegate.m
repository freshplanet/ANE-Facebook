//
//  FBAppInviteDialogDelegate.m
//  AirFacebook
//
//  Created by Ján Horváth on 30/06/15.
//
//

#import "FBAppInviteDialogDelegate.h"
#import "AirFacebook.h"

@implementation FBAppInviteDialogDelegate
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

- (void)showAppInviteDialogWithContent:(FBSDKAppInviteContent *)content
{
    [FBSDKAppInviteDialog showWithContent:content
                                 delegate:self];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    NSString *resultString = [AirFacebook jsonStringFromObject:results andPrettyPrint:NO];
    [AirFacebook log:@"APPINVITE_COMPLETE JSON: %@", resultString];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"APPINVITE_SUCCESS_%@", callback] withMessage:resultString];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    [AirFacebook log:@"APPINVITE_ERROR error: %@", [error description]];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"APPINVITE_ERROR_%@", callback] withMessage:[error description]];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

@end
