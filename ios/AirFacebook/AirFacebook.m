//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////
//

#import "AirFacebook.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define PRINT_LOG   YES

FREContext AirFBCtx = nil;

@interface AirFacebook ()
{
}
@end

@implementation AirFacebook

@synthesize appID = _appID;
@synthesize urlSchemeSuffix = _urlSchemeSuffix;

static AirFacebook *sharedInstance = nil;
//static FBFrictionlessRecipientCache *frictionlessFriendCache;

//void applicationDidBecomeActive(id self, SEL _cmd, UIApplication* application)
//{
//    NSLog(@"ANEFACEBOOK applicationDidBecomeActive");
//    
//    [FBSDKAppEvents activateApp];
//}
//
//
//void applicationDidFinishLaunchingWithOptions(id self, SEL _cmd, UIApplication* application, NSDictionary* launchOptions)
//{
//    NSLog(@"ANEFACEBOOK didFinishLaunchingWithOptions %@",launchOptions);
//    [[FBSDKApplicationDelegate sharedInstance] application:application
//                                    didFinishLaunchingWithOptions:launchOptions];
//}
//
//
//void applicationOpenURLSourceApplicationAnnotation(id self, SEL _cmd,  UIApplication* application, NSURL* url, NSString* sourceApplication, id annotation)
//{
//    NSLog(@"ANEFACEBOOK openURL %@ %@ %@", url, sourceApplication, annotation);
//    
//    [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                          openURL:url
//                                                sourceApplication:sourceApplication
//                                                       annotation:annotation];
//}


+ (AirFacebook *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
//        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(didFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}

// every time we have to send back information to the air application, invoque this method wich will dispatch an Event in air
+ (void)dispatchEvent:(NSString *)event withMessage:(NSString *)message
{
    NSLog(@"FACEBOOK %@ %@", event, message);
    NSString *eventName = event ? event : @"LOGGING";
    NSString *messageText = message ? message : @"";
    FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[messageText UTF8String]);
    
}

//- (void)setupWithAppID:(NSString *)appID urlSchemeSuffix:(NSString *)urlSchemeSuffix
//{
//    // Save parameters
//    _appID = appID;
//    _urlSchemeSuffix = urlSchemeSuffix;
//    NSMutableString *logMessage = [NSMutableString stringWithFormat:@"Initializing with application ID %@", _appID];
//    if (_urlSchemeSuffix)
//        [logMessage appendFormat:@" and URL scheme suffix %@", _urlSchemeSuffix];
//    [AirFacebook log:logMessage];
//    
//    // Open session if a token is in cache.
//    FBSession *session = nil;
//    @try
//    {
//        session = [[FBSession alloc] initWithAppID:appID permissions:nil urlSchemeSuffix:urlSchemeSuffix tokenCacheStrategy:[FBSessionTokenCachingStrategy defaultInstance]];
//    }
//    @catch (NSException *exception)
//    {
//        [AirFacebook dispatchEvent:@"LOGGING" withMessage:[exception reason]];
//        return;
//    }
//    
//    [FBSession setActiveSession:session];
//    if (session.state == FBSessionStateCreatedTokenLoaded)
//    {
//        [AirFacebook log:@"Opening session from cached token"];
//        
//        @try
//        {
//            // Login behavior was updated in 3.14 to allow individual permission control.
//            // See: https://developers.facebook.com/docs/ios/upgrading-3.x section "Upgrading from 3.13 to 3.14"
//            [session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:[AirFacebook openSessionCompletionHandler]];
//        }
//        @catch (NSException *exception)
//        {
//            [AirFacebook dispatchEvent:@"LOGGING" withMessage:[exception reason]];
//            return;
//        }
//    }
//    
//	[FBSettings setDefaultAppID:appID];
//    [FBSession renewSystemCredentials:NULL];
//}

//+ (FBOpenSessionCompletionHandler)openSessionCompletionHandler
//{
//    return ^(FBSession *session, FBSessionState status, NSError *error) {
//        
//        if (error) {
//            if (error.fberrorShouldNotifyUser) {
//                // if the error is application turned off from ios6 settings
//                if ([[error userInfo][FBErrorLoginFailedReason] isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue]) {
//                    [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:@"APPLICATION_TURNED_OFF"];
//                } else {
//                    [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:error.fberrorUserMessage];
//                }
//            } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
//                [AirFacebook log:@"Login error : User Cancelled (Error details : %@ )", error.description];
//                [AirFacebook dispatchEvent:@"OPEN_SESSION_CANCEL" withMessage:@"OK"];
//            } else {
//                [AirFacebook log:@"Unexpected Error on login (Error details : %@ )", error.description];
//                [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:[error description]];
//            }
//        }
//        
//        if (status == FBSessionStateOpen)
//        {
//            [AirFacebook log:[NSString stringWithFormat:@"Session opened with permissions: %@", [session.permissions componentsJoinedByString:@", "]]];
//            [AirFacebook dispatchEvent:@"OPEN_SESSION_SUCCESS" withMessage:@"OK"];
//            if (frictionlessFriendCache == NULL) {
//                frictionlessFriendCache = [[FBFrictionlessRecipientCache alloc] init];
//            }
//            [frictionlessFriendCache prefetchAndCacheForSession:nil];
//        }
//        else if (status == FBSessionStateClosed)
//        {
//            [AirFacebook log:@"Session closed"];
//        }
//    };
//}

//+ (FBReauthorizeSessionCompletionHandler)reauthorizeSessionCompletionHandler
//{
//    return ^(FBSession *session, NSError *error) {
//        
//        if (error)
//        {
//            if (error.fberrorShouldNotifyUser) {
//                // show sdk message
//                [AirFacebook log:[NSString stringWithFormat:@"Error when reauthorizing session: %@", [error description]]];
//                [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_ERROR" withMessage:[error description]];
//            } else {
//                if (error.fberrorCategory == FBErrorCategoryUserCancelled){
//                    // User Cancelled
//                    [AirFacebook log:@"User cancelled when reauthorizing session"];
//                    [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_CANCEL" withMessage:@"OK"];
//                } else {
//                    [AirFacebook log:@"Error when reauthorizing session: %@", [error description]];
//                    [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_ERROR" withMessage:[error description]];
//                }
//            }
//        }
//        else
//        {
//            [AirFacebook log:@"Session reauthorized with permissions: %@", session.permissions];
//            [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_SUCCESS" withMessage:@"OK"];
//        }
//    };
//}

//+ (FBRequestCompletionHandler)requestCompletionHandlerWithCallback:(NSString *)callback
//{
//    return [^(FBRequestConnection *connection, id result, NSError *error) {
//        if (error)
//        {
//            
//            // If user doesn't have the publish permission, ask them
//            if (error.fberrorCategory == FBErrorCategoryPermissions) {
//                [AirFacebook log:@"Requesting publish permissions"];
//                [AirFacebook dispatchEvent:@"ACTION_REQUIRE_PERMISSION" withMessage:@"publish_actions"];
//                return;
//            } else if (callback)
//			{
//                NSDictionary* parsedResponseKey = [error.userInfo objectForKey:FBErrorParsedJSONResponseKey];
//                if (parsedResponseKey && [parsedResponseKey objectForKey:@"body"])
//                {
//                    NSDictionary* body = [parsedResponseKey objectForKey:@"body"];
//                    NSError *jsonError = nil;
//                    NSData *resultData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
//                    if (jsonError)
//                    {
//                        [AirFacebook log:[NSString stringWithFormat:@"Request error -> JSON error: %@", [jsonError description]]];
//                    } else
//                    {
//                        NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
//                        FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[callback UTF8String], (const uint8_t *)[resultString UTF8String]);
//                    }
//                }
//                return;
//			}
//            
//            [AirFacebook log:[NSString stringWithFormat:@"Request error: %@", [error description]]];
//            
//        }
//        else
//        {
//            NSError *jsonError = nil;
//            NSData *resultData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&jsonError];
//            if (jsonError)
//            {
//                [AirFacebook log:[NSString stringWithFormat:@"Request JSON error: %@", [jsonError description]]];
//            }
//            else
//            {
//                NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
//                [AirFacebook dispatchEvent:callback withMessage:resultString];
//            }
//            
//        }
//    } copy];
//}

//+ (FBDialogAppCallCompletionHandler)shareDialogHandlerWithCallback:(NSString *)callback
//{
//    return [^(FBAppCall* call, NSDictionary *results, NSError *error) {
//        NSError *jsonError = nil;
//        NSData *resultData = [NSJSONSerialization dataWithJSONObject:results options:0 error:&jsonError];
//        if (jsonError)
//        {
//            [AirFacebook log:[NSString stringWithFormat:@"Request error -> JSON error: %@", [jsonError description]]];
//        } else
//        {
//            NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
//            FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[callback UTF8String], (const uint8_t *)[resultString UTF8String]);
//        }
//    } copy];
//}


+ (void)log:(NSString *)format, ...
{
    @try
    {
        va_list args;
        va_start(args, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
        if (PRINT_LOG) NSLog(@"[AirFacebook] %@", string);
        [AirFacebook dispatchEvent:@"LOGGING" withMessage:string];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[AirFacebook] Couldn't log message. Exception: %@", exception);
    }
}

- (void)didFinishLaunching:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"FACEBOOK didFinishLaunching called! %@", userInfo);
//    NSWindow *theWindow = [notification object];
//    MyDocument = (MyDocument *)[[theWindow windowController] document];
    
    // Retrieve information about the document and update the panel.
}

@end




#pragma mark - C interface

DEFINE_ANE_FUNCTION(openSessionWithPermissions)
{
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    
    NSArray *permissions = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
    NSString *type = FPANE_FREObjectToNSString(argv[1]);
    
    [AirFacebook log:[NSString stringWithFormat:@"Trying to open session with %@ permissions: %@", type, [permissions componentsJoinedByString:@", "]]];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            [AirFacebook log:@"Debug: canceled: %@  grantedPermissions: %@ declinedPermissions: %@ error: %@ )", result.isCancelled ? @"Yes" : @"No", result.grantedPermissions, result.declinedPermissions, error.description];
        
        if (error) {
            // Process error
            [AirFacebook log:@"Login error : (Error details : %@ )", error.description];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:@"OK"];
        } else if (result.isCancelled) {
            // Handle cancellations
            [AirFacebook log:@"Login error : User Cancelled (Error details : %@ )", error.description];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_CANCEL" withMessage:@"OK"];
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
//            if ([result.grantedPermissions containsObject:@"email"]) {
                // Do work
//            }
            //NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
            [AirFacebook log:@"Login success : "];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_SUCCESS" withMessage:@"OK"];
        }
    }];
    
    return nil;
}

DEFINE_ANE_FUNCTION(logMessage)
{
    NSString *message = FPANE_FREObjectToNSString(argv[0]);
    
    NSLog(@"[FACEBOOK] %@", message);
    
    return nil;
}

DEFINE_ANE_FUNCTION(init)
{
    
    // Retrieve application ID, urlschemesuffix, and legacyMode switch
    NSString *appID = FPANE_FREObjectToNSString(argv[0]);
    NSString *urlSchemeSuffix = FPANE_FREObjectToNSString(argv[1]);
    
    if (urlSchemeSuffix.length == 0)
        urlSchemeSuffix = nil;
    
    [AirFacebook sharedInstance];
    
    // Initialize Facebook
//    [[AirFacebook sharedInstance] setupWithAppID:appID urlSchemeSuffix:urlSchemeSuffix];
	
    return nil;
}

DEFINE_ANE_FUNCTION(handleOpenURL)
{
    // Retrieve URL
//    NSURL *url = [NSURL URLWithString:FPANE_FREObjectToNSString(argv[0])];
    
    // Give the URL to the Facebook session
//    FBSession *session = [FBSession activeSession];
//    [session handleOpenURL:url];
    
    return nil;
}

DEFINE_ANE_FUNCTION(getAccessToken)
{
    FREObject result;
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    
    if(token != nil){
        
        FRENewObject((const uint8_t*)"com.freshplanet.ane.AirFacebook.FBAccessToken", 0, NULL, &result, NULL);
        FRESetObjectProperty(result, (const uint8_t*)"appID", FPANE_NSStringToFREObject(token.appID), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"declinedPermissions", FPANE_NSArrayToFREObject([token.declinedPermissions allObjects]), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"expirationDate", FPANE_doubleToFREObject([token.expirationDate timeIntervalSince1970]), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"permissions", FPANE_NSArrayToFREObject([token.permissions allObjects]), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"refreshDate", FPANE_doubleToFREObject([token.refreshDate timeIntervalSince1970]), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"tokenString", FPANE_NSStringToFREObject(token.tokenString), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"userID", FPANE_NSStringToFREObject(token.userID), NULL);
    }
        
    return result;
}

DEFINE_ANE_FUNCTION(getProfile)
{
    FREObject result;
    FBSDKProfile *profile = [FBSDKProfile currentProfile];
    
    if(profile != nil){
        
        FRENewObject((const uint8_t*)"com.freshplanet.ane.AirFacebook.FBProfile", 0, NULL, &result, NULL);
        FRESetObjectProperty(result, (const uint8_t*)"firstName", FPANE_NSStringToFREObject(profile.firstName), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"lastName", FPANE_NSStringToFREObject(profile.lastName), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"linkUrl", FPANE_NSStringToFREObject([profile.linkURL absoluteString]), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"middleName", FPANE_NSStringToFREObject(profile.middleName), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"name", FPANE_NSStringToFREObject(profile.name), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"refreshDate", FPANE_doubleToFREObject([profile.refreshDate timeIntervalSince1970]), NULL);
        FRESetObjectProperty(result, (const uint8_t*)"userID", FPANE_NSStringToFREObject(profile.userID), NULL);
    }
        
    return result;
}

DEFINE_ANE_FUNCTION(isSessionOpen)
{
//    FBSession *session = [FBSession activeSession];
//    BOOL isSessionOpen = [session isOpen];
//    
//    FREObject result;
//    if (FRENewObjectFromBool(isSessionOpen, &result) == FRE_OK)
//    {
//        return result;
//    }
//    else return nil;
//    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];

    return nil;
}

//DEFINE_ANE_FUNCTION(openSessionWithPermissions)
//{
//    NSArray *permissions = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
//    NSString *type = FPANE_FREObjectToNSString(argv[1]);
//    BOOL systemFlow = FPANE_FREObjectToBOOL(argv[2]);
//    
//    // Print log
//    [AirFacebook log:[NSString stringWithFormat:@"Trying to open session with %@ permissions: %@", type, [permissions componentsJoinedByString:@", "]]];
//    
//    // Select login behavior
//    // Login behavior was updated in 3.14 to allow individual permission control.
//    // See: https://developers.facebook.com/docs/ios/upgrading-3.x section "Upgrading from 3.13 to 3.14"
//    FBSessionLoginBehavior loginBehavior = FBSessionLoginBehaviorWithFallbackToWebView;
//    
//    // Start authentication flow
//    FBOpenSessionCompletionHandler completionHandler = [AirFacebook openSessionCompletionHandler];
//    NSString *appID = [[AirFacebook sharedInstance] appID];
//    NSString *urlSchemeSuffix = [[AirFacebook sharedInstance] urlSchemeSuffix];
//    FBSession *session = nil;
//    @try
//    {
//        session = [[FBSession alloc] initWithAppID:appID permissions:permissions defaultAudience:FBSessionDefaultAudienceFriends urlSchemeSuffix:urlSchemeSuffix tokenCacheStrategy:nil];
//        [FBSession setActiveSession:session];
//        [session openWithBehavior:loginBehavior completionHandler:completionHandler];
//    }
//    @catch (NSException *exception)
//    {
//        [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:[exception reason]];
//        return nil;
//    }
//    
//    return nil;
//}


DEFINE_ANE_FUNCTION(closeSessionAndClearTokenInformation)
{
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
//    [[FBSession activeSession] closeAndClearTokenInformation];
//    frictionlessFriendCache = nil;
    return nil;
}

DEFINE_ANE_FUNCTION(requestWithGraphPath)
{
    
//    // Retrieve graph path
//    NSString *graphPath = FPANE_FREObjectToNSString(argv[0]);
//    
//    // Retrieve request parameters
//    NSDictionary *parameters = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
//    
//    // Retrieve HTTP method
//    NSString *httpMethod = FPANE_FREObjectToNSString(argv[3]);
//    
//    // Retrieve callback name
//    NSString *callback = FPANE_FREObjectToNSString(argv[4]);
//    
//    // Perform Facebook request
//    FBRequest *request = [FBRequest requestWithGraphPath:graphPath parameters:parameters HTTPMethod:httpMethod];
//    FBRequestCompletionHandler completionHandler = [AirFacebook requestCompletionHandlerWithCallback:callback];
//    [request startWithCompletionHandler:completionHandler];
    
    return nil;
}

DEFINE_ANE_FUNCTION(canPresentShareDialog)
{
    
//    // dummy params, they don't influence the eligibility for native dialog
//    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
//    
//    BOOL canPresentDialog = [FBDialogs canPresentShareDialogWithParams:params];
//    
//    return FPANE_BOOLToFREObject(canPresentDialog);
    return false;
}

DEFINE_ANE_FUNCTION(shareStatusDialog)
{
    
//    NSString *callback = FPANE_FREObjectToNSString(argv[0]);
//    
//    [FBDialogs presentShareDialogWithLink:nil handler:[AirFacebook shareDialogHandlerWithCallback:callback]];
    
    return nil;
    
}

DEFINE_ANE_FUNCTION(shareLinkDialog)
{
    
//    // Retrieve parameters
//    NSString *link = FPANE_FREObjectToNSString(argv[0]);
//    NSString *name = FPANE_FREObjectToNSString(argv[1]);
//    NSString *caption = FPANE_FREObjectToNSString(argv[2]);
//    NSString *description = FPANE_FREObjectToNSString(argv[3]);
//    NSString *pictureUrl = FPANE_FREObjectToNSString(argv[4]);
//    NSDictionary *clientState = FPANE_FREObjectsToNSDictionaryOfNSString(argv[5], argv[6]);
//    NSString *callback = FPANE_FREObjectToNSString(argv[7]);
//    
//    [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:link]
//                                     name:name
//                                  caption:caption
//                              description:description
//                                  picture:[NSURL URLWithString:pictureUrl]
//                              clientState:clientState
//                                  handler:[AirFacebook shareDialogHandlerWithCallback:callback]];
    
    return nil;
    
}

DEFINE_ANE_FUNCTION(canPresentOpenGraphDialog)
{
    
//    NSString *actionType = FPANE_FREObjectToNSString(argv[0]);
//    NSDictionary *params = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
//    NSString *previewProperty = FPANE_FREObjectToNSString(argv[3]);
//    
//    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObjectWrappingDictionary:params];
//    
//    FBOpenGraphActionShareDialogParams* dialogParams = [[FBOpenGraphActionShareDialogParams alloc] init];
//    dialogParams.action = action;
//    dialogParams.actionType = actionType;
//    dialogParams.previewPropertyName = previewProperty;
//    
//    BOOL canPresent = [FBDialogs canPresentShareDialogWithOpenGraphActionParams:dialogParams];
//    
//    return FPANE_BOOLToFREObject(canPresent);
    return false;
}

DEFINE_ANE_FUNCTION(shareOpenGraphDialog)
{
    
//    NSString *actionType = FPANE_FREObjectToNSString(argv[0]);
//    NSDictionary *params = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
//    NSString *previewProperty = FPANE_FREObjectToNSString(argv[3]);
//    NSDictionary *clientState = FPANE_FREObjectsToNSDictionaryOfNSString(argv[4], argv[5]);
//    NSString *callback = FPANE_FREObjectToNSString(argv[6]);
//    
//    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObjectWrappingDictionary:params];
//    
//    [FBDialogs presentShareDialogWithOpenGraphAction:action
//                                          actionType:actionType
//                                 previewPropertyName:previewProperty
//                                         clientState:clientState
//                                             handler:[AirFacebook shareDialogHandlerWithCallback:callback]];
    
    return nil;
    
}

DEFINE_ANE_FUNCTION(canPresentMessageDialog)
{
//	BOOL canPresent = [FBDialogs canPresentMessageDialog];
//    return FPANE_BOOLToFREObject(canPresent);
    return false;
}


DEFINE_ANE_FUNCTION(presentMessageDialogWithLinkAndParams)
{
//	NSDictionary *parameters = FPANE_FREObjectsToNSDictionaryOfNSString(argv[0], argv[1]);
//	// Retrieve callback name
//    NSString *callback = FPANE_FREObjectToNSString(argv[2]);
//	[FBDialogs presentMessageDialogWithLink:[NSURL URLWithString:[parameters valueForKey:@"link"]]
//									   name:[parameters valueForKey:@"name"]
//									caption:[parameters valueForKey:@"caption"]
//								description:[parameters valueForKey:@"description"]
//									picture:[NSURL URLWithString:[parameters valueForKey:@"picture"]]
//								clientState:nil
//									handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//										if(error) {
//											
//											// An error occurred, we need to handle the error
//											// See: https://developers.facebook.com/docs/ios/errors
//											
//											NSString *description = [error localizedDescription];
//											NSInteger errorCode = [error code];
//											NSInteger errorSubcode = 0;
//											
//											// try and get subcode
//											NSDictionary *errorInformation = [[[[error userInfo] objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
//																			   objectForKey:@"body"]
//																			  objectForKey:@"error"];
//											
//											if (errorInformation && [errorInformation objectForKey:@"code"]){
//												errorSubcode = [[errorInformation objectForKey:@"code"] integerValue];
//											}
//											
//											NSDictionary *errorDictionary = @{ @"code": [NSString stringWithFormat:@"%ld", (long)errorCode],
//																			   @"subCode": [NSString stringWithFormat:@"%ld", (long)errorSubcode],
//																			   @"description" : description };
//											
//											NSError *jsonError;
//											NSData *jsonData;
//											
//											if ([NSJSONSerialization isValidJSONObject:errorDictionary]) {
//												jsonData = [NSJSONSerialization dataWithJSONObject:errorDictionary
//																						   options:0
//																							 error:&jsonError];
//											}
//											
//											NSString *jsonString = @"unknown";
//											
//											if (!jsonData) {
//												NSLog(@"Got an error: %@", error);
//											} else {
//												jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//											}
//											
//											NSString *data = [NSString stringWithFormat:@"{ \"error\" : \"%@\"}", jsonString];
//											
//											[AirFacebook dispatchEvent:callback withMessage:data];
//											
//										} else {
//											// Success
//											NSLog(@"result %@", results);
//										}
//									}];
	return nil;
}

/* deprecated */
DEFINE_ANE_FUNCTION(webDialog)
{
    
//    NSString *method = FPANE_FREObjectToNSString(argv[0]);
//    
//    NSDictionary *parameters = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
//    
//    // Retrieve callback name
//    NSString *callback = FPANE_FREObjectToNSString(argv[3]);
//
//    BOOL isFeedDialog = [method isEqualToString:@"feed"];
//    BOOL isRequestDialog = [method isEqualToString:@"apprequests"];
//    
//    if( [parameters objectForKey:@"app_id"] == nil )
//    {
//        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:parameters];
//        [temp setObject:[[AirFacebook sharedInstance] appID] forKey:@"app_id"];
//        parameters = temp;
//    }
//    
//    [AirFacebook log:
//         @"displaying facebook web dialog : isFeedingDialog - %@",
//         isFeedDialog ? @"YES" : @"NO"
//    ];
//    
//    FBWebDialogHandler resultHandler = ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//        if (error) {
//            // TODO handle errors on a low level using FB SDK
//			NSString *description = [error localizedDescription];
//			NSInteger errorCode = [error code];
//			NSInteger errorSubcode = 0;
//			
//			// try and get subcode
//			NSDictionary *errorInformation = [[[[error userInfo] objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
//											   objectForKey:@"body"]
//											  objectForKey:@"error"];
//
//			if (errorInformation && [errorInformation objectForKey:@"code"]){
//				errorSubcode = [[errorInformation objectForKey:@"code"] integerValue];
//			}
//
//			NSDictionary *errorDictionary = @{ @"code": [NSString stringWithFormat:@"%ld", (long)errorCode],
//											   @"subCode": [NSString stringWithFormat:@"%ld", (long)errorSubcode],
//											   @"description" : description };
//			
//			NSError *jsonError;
//			NSData *jsonData;
//			
//			if ([NSJSONSerialization isValidJSONObject:errorDictionary]) {
//				jsonData = [NSJSONSerialization dataWithJSONObject:errorDictionary
//														   options:0
//															 error:&jsonError];
//			}
//			
//			NSString *jsonString = @"unknown";
//			
//			if (!jsonData) {
//				NSLog(@"Got an error: %@", error);
//			} else {
//				jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//			}
//			
//			NSString *data = [NSString stringWithFormat:@"{ \"error\" : \"%@\"}", jsonString];
//			
//            [AirFacebook dispatchEvent:callback withMessage:data];
//			
//        } else {
//            if (result == FBWebDialogResultDialogNotCompleted) {
//                NSLog(@"User canceled story publishing.");
//                [AirFacebook dispatchEvent:callback withMessage:@"{ \"cancel\" : true}"];
//            } else {
//                NSString *queryString = [resultURL query];
//                NSString *data = queryString ? [NSString stringWithFormat:@"{ \"params\" : \"%@\"}", queryString] : @"{ \"cancel\" : true}";
//                [AirFacebook dispatchEvent:callback withMessage:data];
//            }
//        }
//        NSLog(@"end");
//    };
//    
//    if (isFeedDialog)
//    {
//        [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:parameters handler:resultHandler];
//    }
//    else if (isRequestDialog)
//    {
//        
//        if (frictionlessFriendCache == NULL) {
//            frictionlessFriendCache = [[FBFrictionlessRecipientCache alloc] init];
//            [frictionlessFriendCache prefetchAndCacheForSession:nil];
//        }
//        
//        [FBWebDialogs presentRequestsDialogModallyWithSession:nil
//                                                      message:[parameters objectForKey:@"message"]
//                                                        title:nil
//                                                   parameters:parameters
//                                                      handler:resultHandler
//                                                  friendCache:frictionlessFriendCache];
//    }
//    else
//    {
//        [FBWebDialogs presentDialogModallyWithSession:nil dialog:method parameters:parameters handler:resultHandler];
//    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(activateApp)
{
//	[FBAppEvents activateApp];
    return nil;
}

DEFINE_ANE_FUNCTION(openDeferredAppLink)
{
//	[FBAppCall openDeferredAppLink:^(NSError *error) {
//		if (error) {
//			NSLog(@"unexpected error opening deferred link:%@", error);
//			[AirFacebook log:@"fallback with error, check device console"];
//			[AirFacebook dispatchEvent:@"AppLink" withMessage:@"fallback with error, check device console"];
//		}
//		else {
//			[AirFacebook log:@"fallback but no error"];
//			[AirFacebook dispatchEvent:@"AppLink" withMessage:@"fallback but no error"];
//		}
//			
//	}];
	return nil;
}

void AirFacebookContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    
//    [[NSNotificationCenter defaultCenter] addObserver:[AirFacebook sharedInstance] selector:@selector(didFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
    //injects our modified delegate functions into the sharedApplication delegate
    
//    id delegate = [[UIApplication sharedApplication] delegate];
//    Class objectClass = object_getClass(delegate);
//    NSString *newClassName = [NSString stringWithFormat:@"Custom_%@", NSStringFromClass(objectClass)];
//    Class modDelegate = NSClassFromString(newClassName);
//    if (modDelegate == nil) {
//        // this class doesn't exist; create it
//        // allocate a new class
//        modDelegate = objc_allocateClassPair(objectClass, [newClassName UTF8String], 0);
//        
//        SEL selectorToOverride1 = @selector(applicationDidBecomeActive:);
//        SEL selectorToOverride2 = @selector(application:didFinishLaunchingWithOptions:);
//        SEL selectorToOverride3 = @selector(application:openURL:sourceApplication:annotation:);
//        
//        // get the info on the method we're going to override
//        Method m1 = class_getInstanceMethod(objectClass, selectorToOverride1);
//        Method m2 = class_getInstanceMethod(objectClass, selectorToOverride2);
//        Method m3 = class_getInstanceMethod(objectClass, selectorToOverride3);
//        
//        // add the method to the new class
//        class_addMethod(modDelegate, selectorToOverride1, (IMP)applicationDidBecomeActive, method_getTypeEncoding(m1));
//        class_addMethod(modDelegate, selectorToOverride2, (IMP)applicationDidFinishLaunchingWithOptions, method_getTypeEncoding(m2));
//        class_addMethod(modDelegate, selectorToOverride3, (IMP)applicationOpenURLSourceApplicationAnnotation, method_getTypeEncoding(m3));
//        
//        // register the new class with the runtime
//        objc_registerClassPair(modDelegate);
//    }
//    // change the class of the object
//    object_setClass(delegate, modDelegate);
    
    ///////// end of delegate injection / modification code
    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    
    NSDictionary *functions = @{
        @"init":                                    [NSValue valueWithPointer:&init],
        @"handleOpenURL":                           [NSValue valueWithPointer:&handleOpenURL],
        @"getAccessToken":                          [NSValue valueWithPointer:&getAccessToken],
        @"isSessionOpen":                           [NSValue valueWithPointer:&isSessionOpen],
        @"openSessionWithPermissions":              [NSValue valueWithPointer:&openSessionWithPermissions],
        @"closeSessionAndClearTokenInformation":    [NSValue valueWithPointer:&closeSessionAndClearTokenInformation],
        @"requestWithGraphPath":                    [NSValue valueWithPointer:&requestWithGraphPath],
        @"canPresentShareDialog":                   [NSValue valueWithPointer:&canPresentShareDialog],
        @"shareStatusDialog":                       [NSValue valueWithPointer:&shareStatusDialog],
        @"shareLinkDialog":                         [NSValue valueWithPointer:&shareLinkDialog],
        @"canPresentOpenGraphDialog":               [NSValue valueWithPointer:&canPresentOpenGraphDialog],
        @"shareOpenGraphDialog":                    [NSValue valueWithPointer:&shareOpenGraphDialog],
        @"canPresentMessageDialog":                 [NSValue valueWithPointer:&canPresentMessageDialog],
        @"presentMessageDialogWithLinkAndParams":   [NSValue valueWithPointer:&presentMessageDialogWithLinkAndParams],
        @"webDialog":                               [NSValue valueWithPointer:&webDialog],
        @"activateApp":                             [NSValue valueWithPointer:&activateApp],
        @"openDeferredAppLink":                     [NSValue valueWithPointer:&openDeferredAppLink],
        @"log":                                     [NSValue valueWithPointer:&logMessage],
        @"getProfile":                              [NSValue valueWithPointer:&getProfile],
    };
    
    *numFunctionsToTest = (uint32_t)[functions count];
    
    FRENamedFunction *func = (FRENamedFunction *)malloc(sizeof(FRENamedFunction) * [functions count]);
    
    uint32_t i = 0;
    for (NSString* functionName in functions){
        NSValue *value = functions[functionName];
        
        func[i].name = (const uint8_t *)[functionName UTF8String];
        func[i].functionData = NULL;
        func[i].function = [value pointerValue];
        i++;
    }
    
    *functionsToSet = func;
    
    AirFBCtx = ctx;
}

void AirFacebookContextFinalizer(FREContext ctx) { }

void AirFacebookInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirFacebookContextInitializer;
	*ctxFinalizerToSet = &AirFacebookContextFinalizer;
}

void AirFacebookFinalizer(void *extData) { }
