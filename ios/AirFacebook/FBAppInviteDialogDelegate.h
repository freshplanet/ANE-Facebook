//
//  FBAppInviteDialogDelegate.h
//  AirFacebook
//
//  Created by Ján Horváth on 30/06/15.
//
//

#import <Foundation/Foundation.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FBAppInviteDialogDelegate : NSObject<FBSDKAppInviteDialogDelegate>

- (id)initWithCallback:(NSString *)aCallback;
- (void)showAppInviteDialogWithContent:(FBSDKAppInviteContent *)content;

@end
