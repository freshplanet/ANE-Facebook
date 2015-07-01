//
//  FBShareDelegate.m
//  AirFacebook
//
//  Created by Ján Horváth on 16/06/15.
//
//

#import "FBShareDelegate.h"

@implementation FBShareDelegate
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

-(BOOL)shareContent:(FBSDKShareLinkContent *)content usingShareApi:(BOOL)useShareApi
{
    if(useShareApi){
        
        [FBSDKShareAPI shareWithContent:content delegate:self];
    } else {
        
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.fromViewController = rootViewController;
        dialog.shareContent = content;
        dialog.mode = [[AirFacebook sharedInstance] defaultShareDialogMode];
        dialog.delegate = self;
        [dialog show];
    }
    
    return YES;
}

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSString *resultString = [AirFacebook jsonStringFromObject:results andPrettyPrint:NO];
    [AirFacebook log:@"SHARE_COMPLETE JSON: %@", resultString];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"SHARE_SUCCESS_%@", callback] withMessage:resultString];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [AirFacebook log:@"SHARE_ERROR error: %@", [error description]];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"SHARE_ERROR_%@", callback] withMessage:[error description]];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [AirFacebook log:@"SHARE_CANCEL"];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"SHARE_CANCELLED_%@", callback] withMessage:@"OK"];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

@end
