/**
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AirFacebook.h"
#import "FREConversionUtil.h"
#import "FBShareDelegate.h"
#import "FBAppInviteDialogDelegate.h"
#import "FBGameRequestDelegate.h"

FREContext AirFBCtx = nil;

@implementation AirFacebook {
    NSMutableDictionary* shareActivities;
}

static AirFacebook* sharedInstance = nil;

+ (AirFacebook*)sharedInstance {
    
    if (sharedInstance == nil)
        sharedInstance = [[super allocWithZone:NULL] init];
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

- (id)copy {
    return self;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
    
        shareActivities = [NSMutableDictionary dictionary];
        self.defaultShareDialogMode = FBSDKShareDialogModeAutomatic;
        self.defaultAudience = FBSDKDefaultAudienceFriends;
        self.loginBehavior = FBSDKLoginBehaviorNative;
        self.loginInProgress = false;
    }
    
    return self;
}

+ (void)dispatchEvent:(NSString*)event withMessage:(NSString*)message {
    
    if (AirFBCtx != nil) {
        
        NSString* eventName = event ? event : @"LOGGING";
        NSString* messageText = message ? message : @"";
        FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t*)[eventName UTF8String], (const uint8_t*)[messageText UTF8String]);
    }
}

+ (void)log:(NSString*)format, ... {
    
    @try {
        
        va_list args;
        va_start(args, format);
        NSString* message = [[NSString alloc] initWithFormat:format arguments:args];
        [AirFacebook as3Log:message];
        [AirFacebook nativeLog:message withPrefix:@"NATIVE"];
    }
    @catch (NSException* exception) {
        NSLog(@"[AirFacebook] Couldn't log message. Exception: %@", exception);
    }
}

+ (void)as3Log:(NSString*)message {
    [AirFacebook dispatchEvent:@"LOGGING" withMessage:message];
}

+ (void)nativeLog:(NSString*)message withPrefix:(NSString*)prefix {
    
    if ([[AirFacebook sharedInstance] isNativeLogEnabled]) {
        NSLog(@"[AirFacebook][%@] %@", prefix, message);
    }
}

- (void)shareContent:(FBSDKShareLinkContent*)content andCallback:(NSString*)callback
{
    [AirFacebook log:@"share:usingShareApi:andShareCallback: callback: %@", callback];
    
    if (callback != nil) {
        FBShareDelegate* delegate = [[FBShareDelegate alloc] initWithCallback:callback];
        [shareActivities setObject:delegate forKey:callback];
        [delegate shareContent:content];
    }
}

- (void)shareFinishedForCallback:(NSString*)callback
{
    [AirFacebook log:@"shareFinishedForCallback: callback: %@", callback];
    
    if (callback != nil) {
        [shareActivities removeObjectForKey:callback];
    }
}

- (void)showAppInviteDialogWithContent:(FBSDKAppInviteContent*)content andCallback:(NSString*)callback
{
    [AirFacebook log:@"showAppInviteDialog:withCallback: callback: %@", callback];
    
    if (callback != nil) {
        FBAppInviteDialogDelegate* delegate = [[FBAppInviteDialogDelegate alloc] initWithCallback:callback];
        [shareActivities setObject:delegate forKey:callback];
        [delegate showAppInviteDialogWithContent:content];
    }
}

- (void)gameRequestWithContent:(FBSDKGameRequestContent*)content enableFrictionless:(BOOL)frictionless andCallback:(NSString*)callback
{
    [AirFacebook log:@"showGameRequestDialogWithContent: andCallback: %@", callback];
    
    if (callback != nil) {
        FBGameRequestDelegate* delegate = [[FBGameRequestDelegate alloc] initWithCallback:callback];
        [shareActivities setObject:delegate forKey:callback];
        [delegate gameRequestWithContent:content enableFrictionless:frictionless];
    }
}

+ (NSString*) jsonStringFromObject:(id)obj andPrettyPrint:(BOOL) prettyPrint
{
    if (obj == nil) {
        NSLog(@"jsonStringFromObject:andPrettyPrint: first argument was nil!");
        return @"[]";
    }
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"jsonStringFromObject:andPrettyPrint: error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (FBOpenSessionCompletionHandler)openSessionCompletionHandler {
    
    
    
    return ^(FBSDKLoginManagerLoginResult* result, NSError* error) {
        
        if (error) {
    
            // Process error
            [AirFacebook log:@"Login error: (Error details : %@)", error.description];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:@"OK"];
        }
        else if (result.isCancelled) {
            
            // Handle cancellations
            [AirFacebook log:@"Login failed! User cancelled! (Error details : %@)", error.description];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_CANCEL" withMessage:@"OK"];
        }
        else {
            
            [AirFacebook log:@"Login success! grantedPermissions: %@ declinedPermissions: %@", result.grantedPermissions, result.declinedPermissions];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_SUCCESS" withMessage:@"OK"];
        }
        
        [AirFacebook.sharedInstance setLoginInProgress:false];
    };
}

@end

#pragma mark - C interface

DEFINE_ANE_FUNCTION(logInWithPermissions) {
    
    if([[AirFacebook sharedInstance] loginInProgress]) {
        return nil;
    }
    
    [AirFacebook.sharedInstance setLoginInProgress:true];
    
    UIApplication* application = [UIApplication sharedApplication];
    UIWindow* keyWindow = application.keyWindow;
    UIViewController* rootViewController = keyWindow.rootViewController;
    
    NSArray* permissions = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
    NSString* type = FPANE_FREObjectToNSString(argv[1]);
    
    [AirFacebook log:[NSString stringWithFormat:@"Trying to open session with %@ permissions: %@", type, [permissions componentsJoinedByString:@", "]]];
    
    FBSDKLoginManager* loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.loginBehavior = [[AirFacebook sharedInstance] loginBehavior];
    loginManager.defaultAudience = [[AirFacebook sharedInstance] defaultAudience];
    [loginManager logOut];
    if ([type isEqualToString:@"read"]) {
        
        [loginManager logInWithReadPermissions:permissions
                            fromViewController:rootViewController
                                       handler:[AirFacebook openSessionCompletionHandler]];
    }
    else {
        
        [loginManager logInWithPublishPermissions:permissions
                               fromViewController:rootViewController
                                          handler:[AirFacebook openSessionCompletionHandler]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(nativeLog) {
    
    NSString* message = FPANE_FREObjectToNSString(argv[0]);
    
    // NOTE: logs from as3 should go only to native log
    [AirFacebook nativeLog:message withPrefix:@"AS3"];
    
    return nil;
}

DEFINE_ANE_FUNCTION(setNativeLogEnabled) {
    
    BOOL nativeLogEnabled = FPANE_FREObjectToBOOL(argv[0]);
    [[AirFacebook sharedInstance] setNativeLogEnabled:nativeLogEnabled];
    
    return nil;
}

DEFINE_ANE_FUNCTION(initFacebook) {
    
    [AirFacebook log:@"initFacebook"];
    
    NSString* callback = FPANE_FREObjectToNSString(argv[1]);
    
    // maybe we dont need this sharedInstance
    [AirFacebook sharedInstance];
    
    [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:[NSMutableDictionary dictionary]];
    
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"SDKINIT_%@", callback] withMessage:nil];
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirFacebookHandleOpenURL) {
    
    [AirFacebook log:@"handleOpenURL"];
    
    NSURL* url = [NSURL URLWithString:FPANE_FREObjectToNSString(argv[0])];
    NSString* sourceApplication = FPANE_FREObjectToNSString(argv[1]);
    NSString* annotation = FPANE_FREObjectToNSString(argv[2]);
    
    BOOL result = [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
                                                                 openURL:url
                                                       sourceApplication:sourceApplication
                                                              annotation:annotation];
    return FPANE_BOOLToFREObject(result);
}

DEFINE_ANE_FUNCTION(getAccessToken) {
    
    [AirFacebook log:@"getAccessToken"];
    
    FREObject result = NULL;
    FBSDKAccessToken* token = [FBSDKAccessToken currentAccessToken];
    
    if (token != NULL) {
        
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

DEFINE_ANE_FUNCTION(getProfile) {
    
    [AirFacebook log:@"getProfile"];
    
    FREObject result = NULL;
    FBSDKProfile* profile = [FBSDKProfile currentProfile];
    
    if (profile != NULL) {
        
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

DEFINE_ANE_FUNCTION(logOut) {
    
    FBSDKLoginManager* loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];

    return nil;
}

DEFINE_ANE_FUNCTION(requestWithGraphPath) {
    
    NSString* graphPath = FPANE_FREObjectToNSString(argv[0]);
    NSDictionary* parameters = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
    NSString* httpMethod = FPANE_FREObjectToNSString(argv[3]);
    NSString* callback = FPANE_FREObjectToNSString(argv[4]);
    
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:parameters HTTPMethod:httpMethod];
        [request setGraphErrorRecoveryDisabled:true];
        [request
        startWithCompletionHandler:^(FBSDKGraphRequestConnection* connection, id result, NSError* error) {
            if (error) {
                
                if (callback) {
                    
                    NSDictionary* parsedResponseKey = [error.userInfo objectForKey:FBSDKGraphRequestErrorParsedJSONResponseKey];
                    if (parsedResponseKey && [parsedResponseKey objectForKey:@"body"])
                    {
                        NSDictionary* body = [parsedResponseKey objectForKey:@"body"];
                        NSError* jsonError = nil;
                        NSData* resultData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
                        if (jsonError)
                        {
                            [AirFacebook log:[NSString stringWithFormat:@"Request error -> JSON error: %@", [jsonError description]]];
                        } else
                        {
                            NSString* resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                            [AirFacebook dispatchEvent:callback withMessage:resultString];
                        }
                    }
                    return;
                }
                
                [AirFacebook log:[NSString stringWithFormat:@"Request error: %@", [error description]]];
                
            }
            else{
                
                NSError* jsonError = nil;
                NSData* resultData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&jsonError];
                if (jsonError)
                {
                    [AirFacebook log:[NSString stringWithFormat:@"Request JSON error: %@", [jsonError description]]];
                }
                else
                {
                    NSString* resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                    [AirFacebook dispatchEvent:callback withMessage:resultString];
                }
                
            }
        }];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(setDefaultAudience) {
    
    NSUInteger defaultAudience = FPANE_FREObjectToNSUInteger(argv[0]);
    
    [AirFacebook log:@"defaultAudience value:%d", defaultAudience];
    [[AirFacebook sharedInstance] setDefaultAudience:defaultAudience];
    
    return nil;
}

DEFINE_ANE_FUNCTION(setLoginBehavior) {
    
    NSUInteger loginBehavior = FPANE_FREObjectToNSUInteger(argv[0]);
    
    [AirFacebook log:@"setLoginBehavior value:%d", loginBehavior];
    [[AirFacebook sharedInstance] setLoginBehavior:loginBehavior];
    
    return nil;
}

DEFINE_ANE_FUNCTION(setDefaultShareDialogMode) {
    
    NSUInteger defaultShareDialogMode = FPANE_FREObjectToNSUInteger(argv[0]);
    
    [AirFacebook log:@"defaultShareDialogMode value:%d", defaultShareDialogMode];
    [[AirFacebook sharedInstance] setDefaultShareDialogMode:defaultShareDialogMode];
    
    return nil;
}

DEFINE_ANE_FUNCTION(canPresentShareDialog) {
    
    UIViewController* rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    FBSDKShareDialog* dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = rootViewController;
    dialog.mode = [[AirFacebook sharedInstance] defaultShareDialogMode];
    BOOL canShow = [dialog canShow];
    
    return FPANE_BOOLToFREObject(canShow);
}

DEFINE_ANE_FUNCTION(shareLinkDialog) {
    
    NSString* contentUrl = [FREConversionUtil toString:[FREConversionUtil getProperty:@"contentUrl" fromObject:argv[0]]];
    NSArray* peopleIds = [FREConversionUtil toStringArray:[FREConversionUtil getProperty:@"peopleIds" fromObject:argv[0]]];
    NSString* placeId = [FREConversionUtil toString:[FREConversionUtil getProperty:@"placeId" fromObject:argv[0]]];
    NSString* ref = [FREConversionUtil toString:[FREConversionUtil getProperty:@"ref" fromObject:argv[0]]];
    NSString* contentTitle = [FREConversionUtil toString:[FREConversionUtil getProperty:@"contentTitle" fromObject:argv[0]]];
    NSString* contentDescription = [FREConversionUtil toString:[FREConversionUtil getProperty:@"contentDescription" fromObject:argv[0]]];
    NSString* imageUrl = [FREConversionUtil toString:[FREConversionUtil getProperty:@"imageUrl" fromObject:argv[0]]];

    NSString* callback = FPANE_FREObjectToNSString(argv[1]);
    
    FBSDKShareLinkContent* content = [[FBSDKShareLinkContent alloc] init];
    if (contentUrl != nil) content.contentURL = [NSURL URLWithString:contentUrl];
    if (peopleIds != nil) content.peopleIDs = peopleIds;
    if (placeId != nil) content.placeID = placeId;
    if (ref != nil) content.ref = ref;
//    if (contentTitle != nil) content.contentTitle = contentTitle;
//    if (contentDescription != nil) content.contentDescription = contentDescription;
//    if (imageUrl != nil) content.imageURL = [NSURL URLWithString:imageUrl];
    
    [[AirFacebook sharedInstance] shareContent:content andCallback:callback];
    
    return nil;
}

DEFINE_ANE_FUNCTION(appInviteDialog) {
    
    NSString* appLinkUrl = [FREConversionUtil toString:[FREConversionUtil getProperty:@"appLinkUrl" fromObject:argv[0]]];
    NSString* previewImageUrl = [FREConversionUtil toString:[FREConversionUtil getProperty:@"previewImageUrl" fromObject:argv[0]]];
    
    NSString* callback = FPANE_FREObjectToNSString(argv[1]);
    
    FBSDKAppInviteContent* content = [[FBSDKAppInviteContent alloc] init];
    if (appLinkUrl != nil) content.appLinkURL = [NSURL URLWithString:appLinkUrl];
    if (previewImageUrl != nil) content.appInvitePreviewImageURL = [NSURL URLWithString:previewImageUrl];
    
    [[AirFacebook sharedInstance] showAppInviteDialogWithContent:content andCallback:callback];
    
    return nil;
}

DEFINE_ANE_FUNCTION(gameRequestDialog) {
    
    FBSDKGameRequestActionType actionType = [FREConversionUtil toUInt:[FREConversionUtil getProperty:@"actionType" fromObject:argv[0]]];
    NSString* data = [FREConversionUtil toString:[FREConversionUtil getProperty:@"data" fromObject:argv[0]]];
    FBSDKGameRequestFilter filters = [FREConversionUtil toUInt:[FREConversionUtil getProperty:@"filters" fromObject:argv[0]]];
    NSString* message = [FREConversionUtil toString:[FREConversionUtil getProperty:@"message" fromObject:argv[0]]];
    NSString* objectID = [FREConversionUtil toString:[FREConversionUtil getProperty:@"objectID" fromObject:argv[0]]];
    NSArray* recipients = [FREConversionUtil toStringArray:[FREConversionUtil getProperty:@"recipients" fromObject:argv[0]]];
    NSArray* recipientSuggestions = [FREConversionUtil toStringArray:[FREConversionUtil getProperty:@"recipientSuggestions" fromObject:argv[0]]];
    NSString* title = [FREConversionUtil toString:[FREConversionUtil getProperty:@"title" fromObject:argv[0]]];
    
    BOOL frictionless = FPANE_FREObjectToBOOL(argv[1]);
    NSString* callback = FPANE_FREObjectToNSString(argv[2]);
    
    FBSDKGameRequestContent* gameRequestContent = [[FBSDKGameRequestContent alloc] init];
    gameRequestContent.actionType = actionType;
    if (data != nil) gameRequestContent.data = data;
    gameRequestContent.filters = filters;
    if (message != nil) gameRequestContent.message = message;
    if (objectID != nil) gameRequestContent.objectID = objectID;
    if (recipients != nil) gameRequestContent.recipients = recipients;
    if (recipientSuggestions != nil) gameRequestContent.recipientSuggestions = recipientSuggestions;
    if (title != nil) gameRequestContent.title = title;
    
    [[AirFacebook sharedInstance] gameRequestWithContent:gameRequestContent enableFrictionless:frictionless andCallback:callback];
    
    return nil;
}

DEFINE_ANE_FUNCTION(activateApp) {
    
    [FBSDKAppEvents activateApp];
    return nil;
}

DEFINE_ANE_FUNCTION(AirFacebookLogEvent) {
    
    NSString* eventName = [FREConversionUtil toString:[FREConversionUtil getProperty:@"eventName" fromObject:argv[0]]];
    NSNumber* valueToSum = [FREConversionUtil toNumber:[FREConversionUtil getProperty:@"valueToSum" fromObject:argv[0]]];
    NSDictionary* parameters = FPANE_FREObjectsToNSDictionary([FREConversionUtil getProperty:@"paramsKeys" fromObject:argv[0]],
                                                              [FREConversionUtil getProperty:@"paramsTypes" fromObject:argv[0]],
                                                              [FREConversionUtil getProperty:@"paramsValues" fromObject:argv[0]]);
    
    [FBSDKAppEvents logEvent:eventName valueToSum:[valueToSum doubleValue] parameters:parameters];
    return nil;
}

void AirFacebookContextInitializer(void* extData,
                                   const uint8_t* ctxType,
                                   FREContext ctx,
                                   uint32_t* numFunctionsToTest,
                                   const FRENamedFunction** functionsToSet) {
    
//    [[NSNotificationCenter defaultCenter] addObserver:[AirFacebook sharedInstance] selector:@selector(didFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSDictionary* functions = @{
        @"initFacebook":                    [NSValue valueWithPointer:&initFacebook],
        @"handleOpenURL":                   [NSValue valueWithPointer:&AirFacebookHandleOpenURL],
        @"getAccessToken":                  [NSValue valueWithPointer:&getAccessToken],
        @"getProfile":                      [NSValue valueWithPointer:&getProfile],
        @"logInWithPermissions":            [NSValue valueWithPointer:&logInWithPermissions],
        @"logOut":                          [NSValue valueWithPointer:&logOut],
        @"requestWithGraphPath":            [NSValue valueWithPointer:&requestWithGraphPath],
        
        // Settings
        @"setDefaultShareDialogMode":       [NSValue valueWithPointer:&setDefaultShareDialogMode],
        @"setLoginBehavior":                [NSValue valueWithPointer:&setLoginBehavior],
        @"setDefaultAudience":              [NSValue valueWithPointer:&setDefaultAudience],
        
        // Sharing dialogs
        @"canPresentShareDialog":           [NSValue valueWithPointer:&canPresentShareDialog],
        @"shareLinkDialog":                 [NSValue valueWithPointer:&shareLinkDialog],
        @"appInviteDialog":                 [NSValue valueWithPointer:&appInviteDialog],
        @"gameRequestDialog":               [NSValue valueWithPointer:&gameRequestDialog],
        
        // FB events
        @"activateApp":                     [NSValue valueWithPointer:&activateApp],
        @"logEvent":                        [NSValue valueWithPointer:&AirFacebookLogEvent],
        
        // Debug
        @"nativeLog":                       [NSValue valueWithPointer:&nativeLog],
        @"setNativeLogEnabled":             [NSValue valueWithPointer:&setNativeLogEnabled],
    };
    
   * numFunctionsToTest = (uint32_t)[functions count];
    
    FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction)*  [functions count]);
    
    uint32_t i = 0;
    for (NSString* functionName in functions) {
        NSValue* value = functions[functionName];
        
        func[i].name = (const uint8_t*)[functionName UTF8String];
        func[i].functionData = NULL;
        func[i].function = [value pointerValue];
        i++;
    }
    
   * functionsToSet = func;
    
    AirFBCtx = ctx;
}

void AirFacebookContextFinalizer(FREContext ctx) {

}

void AirFacebookInitializer(void** extDataToSet,
                            FREContextInitializer* ctxInitializerToSet,
                            FREContextFinalizer* ctxFinalizerToSet) {
    
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirFacebookContextInitializer;
	*ctxFinalizerToSet = &AirFacebookContextFinalizer;
}

void AirFacebookFinalizer(void* extData) {

}


