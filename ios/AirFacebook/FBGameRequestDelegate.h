//
//  FBGameRequestDelegate.h
//  AirFacebook
//
//  Created by Adam Schlesinger on 8/21/15.
//
//

#import <Foundation/Foundation.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FBGameRequestDelegate : NSObject<FBSDKGameRequestDialogDelegate>

- (id)initWithCallback:(NSString *)aCallback;
- (void)gameRequestWithContent:(FBSDKGameRequestContent *)content enableFrictionless:(BOOL)frictionless;

@end
