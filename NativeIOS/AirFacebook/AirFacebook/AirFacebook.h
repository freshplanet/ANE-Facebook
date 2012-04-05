//
//  AirFacebook.h
//  AirFacebook
//
//  Created by Thibaut Crenn on 3/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "FBDialog.h"
#import "FlashRuntimeExtensions.h"
#import "AirFBRequest.h"


@interface AirFacebook : NSObject <FBSessionDelegate, FBDialogDelegate>
{
    Facebook *facebook;
    
}

- (void) extendAccessTokenIfNeeded;
- (void) initFacebookWithAppId:(NSString*)appId andAccessToken:(NSString*)accessToken andExpirationTimestamp:(NSString*)expirationTimestamp;
- (BOOL) handleOpenURL:(NSURL *)url;
- (void) requestWithGraphPath:(NSString*)path andCallback:(NSString*)callbackName;
- (void) requestWithGraphPath:(NSString*)path andParams:(NSMutableDictionary*)params andCallback:(NSString*)callbackName;

- (void) dialog:(NSString *)action andParams:(NSMutableDictionary *)params;

@property (nonatomic, retain) Facebook *facebook;



@end

void AirFBContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void AirFBContextFinalizer(FREContext ctx);

void AirFBInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet );

FREObject initFacebook(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject extendAccessTokenIfNeeded(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject login(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject handleOpenURL(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject requestWithGraphPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject openDialog(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
