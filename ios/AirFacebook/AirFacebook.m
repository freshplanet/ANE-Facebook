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

FREContext AirFBCtx = nil;

@implementation AirFacebook {
    
    NSMutableDictionary *shareActivities;
}

static AirFacebook *sharedInstance = nil;

+ (AirFacebook *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        shareActivities = [NSMutableDictionary dictionary];
        self.defaultShareDialogMode = FBSDKShareDialogModeAutomatic;
        self.defaultAudience = FBSDKDefaultAudienceFriends;
        self.loginBehavior = FBSDKLoginBehaviorNative;
    }
    return self;
}

// every time we have to send back information to the air application, invoque this method wich will dispatch an Event in air
+ (void)dispatchEvent:(NSString *)event withMessage:(NSString *)message
{
    if(AirFBCtx != nil){
        NSString *eventName = event ? event : @"LOGGING";
        NSString *messageText = message ? message : @"";
        FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[messageText UTF8String]);
    }
}

+ (void)log:(NSString *)format, ...
{
    @try
    {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        [AirFacebook as3Log:message];
        [AirFacebook nativeLog:message withPrefix:@"NATIVE"];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[AirFacebook] Couldn't log message. Exception: %@", exception);
    }
}

+ (void)as3Log:(NSString *)message
{
    [AirFacebook dispatchEvent:@"LOGGING" withMessage:message];
}

+ (void)nativeLog:(NSString *)message withPrefix:(NSString *)prefix
{
    if ([[AirFacebook sharedInstance] isNativeLogEnabled]) {
        NSLog(@"[AirFacebook][%@] %@", prefix, message);
    }
}

// sharing

- (void)share:(FBSDKShareLinkContent *)content usingShareApi:(BOOL)useShareApi delegate:(id<FBSDKSharingDelegate>)delegate
{
    if(useShareApi){
        
        [FBSDKShareAPI shareWithContent:content delegate:delegate];
    } else {
        
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.fromViewController = rootViewController;
        dialog.shareContent = content;
        dialog.mode = self.defaultShareDialogMode;
        dialog.delegate = delegate;
        [dialog show];
    }
}

- (void)share:(FBSDKShareLinkContent *)content usingShareApi:(BOOL)useShareApi andShareCallback:(NSString *)callback
{
    [AirFacebook log:@"share:usingShareApi:andShareCallback: callback: %@", callback];
    
    if (callback != NULL){
        FBShareDelegate *delegate = [[FBShareDelegate alloc] initWithCallback:callback];
        [shareActivities setObject:delegate forKey:callback];
        [delegate share:content usingShareApi:useShareApi];
    }
}

- (void)shareFinishedForCallback:(NSString *)callback
{
    [AirFacebook log:@"shareFinishedForCallback: callback: %@", callback];
    
    if (callback != NULL){
        [shareActivities removeObjectForKey:callback];
    }
}

+ (NSString*) jsonStringFromObject:(id)obj andPrettyPrint:(BOOL) prettyPrint
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"jsonStringFromObject:andPrettyPrint: error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (FBOpenSessionCompletionHandler)openSessionCompletionHandler
{
    return ^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        if (error) {
            // Process error
            [AirFacebook log:@"Login error: (Error details : %@ )", error.description];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:@"OK"];
        }
        else if (result.isCancelled) {
            // Handle cancellations
            [AirFacebook log:@"Login failed! User cancelled! (Error details : %@ )", error.description];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_CANCEL" withMessage:@"OK"];
        }
        else {
            [AirFacebook log:@"Login success! grantedPermissions: %@ declinedPermissions: %@", result.grantedPermissions, result.declinedPermissions];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_SUCCESS" withMessage:@"OK"];
        }
    };
}

@end

#pragma mark - C interface

DEFINE_ANE_FUNCTION(logInWithPermissions)
{
    NSArray *permissions = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
    NSString *type = FPANE_FREObjectToNSString(argv[1]);
    
    [AirFacebook log:[NSString stringWithFormat:@"Trying to open session with %@ permissions: %@", type, [permissions componentsJoinedByString:@", "]]];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.loginBehavior = [[AirFacebook sharedInstance] loginBehavior];
    loginManager.defaultAudience = [[AirFacebook sharedInstance] defaultAudience];
    if([type isEqualToString:@"read"]){
        [loginManager logInWithReadPermissions:permissions handler: [AirFacebook openSessionCompletionHandler]];
    }else{
        [loginManager logInWithPublishPermissions:permissions handler: [AirFacebook openSessionCompletionHandler]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(nativeLog)
{
    NSString *message = FPANE_FREObjectToNSString(argv[0]);
    
    // NOTE: logs from as3 should go only to native log
    [AirFacebook nativeLog:message withPrefix:@"AS3"];
    
    return nil;
}


DEFINE_ANE_FUNCTION(setNativeLogEnabled)
{
    BOOL nativeLogEnabled = FPANE_FREObjectToBOOL(argv[0]);
    
    [[AirFacebook sharedInstance] setNativeLogEnabled:nativeLogEnabled];
    
    return nil;
}

DEFINE_ANE_FUNCTION(initFacebook)
{
    [AirFacebook log:@"initFacebook"];
    
    // maybe we dont need this sharedInstance
    [AirFacebook sharedInstance];
    
    [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:[NSMutableDictionary dictionary]];
    
    return nil;
}

DEFINE_ANE_FUNCTION(handleOpenURL)
{
    [AirFacebook log:@"handleOpenURL"];
    
    NSURL *url = [NSURL URLWithString:FPANE_FREObjectToNSString(argv[0])];
    NSString *sourceApplication = FPANE_FREObjectToNSString(argv[1]);
    NSString *annotation = FPANE_FREObjectToNSString(argv[2]);
    
    BOOL result = [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
                                                                 openURL:url
                                                       sourceApplication:sourceApplication
                                                              annotation:annotation];
    return FPANE_BOOLToFREObject(result);
}

DEFINE_ANE_FUNCTION(getAccessToken)
{
    [AirFacebook log:@"getAccessToken"];
    
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
    [AirFacebook log:@"getProfile"];
    
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

DEFINE_ANE_FUNCTION(logOut)
{
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];

    return nil;
}

DEFINE_ANE_FUNCTION(requestWithGraphPath)
{
    NSString *graphPath = FPANE_FREObjectToNSString(argv[0]);
    NSDictionary *parameters = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
    NSString *httpMethod = FPANE_FREObjectToNSString(argv[3]);
    NSString *callback = FPANE_FREObjectToNSString(argv[4]);
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:parameters HTTPMethod:httpMethod]
        startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error){
                
                if (callback){
                    
                    NSDictionary* parsedResponseKey = [error.userInfo objectForKey:FBSDKGraphRequestErrorParsedJSONResponseKey];
                    if (parsedResponseKey && [parsedResponseKey objectForKey:@"body"])
                    {
                        NSDictionary* body = [parsedResponseKey objectForKey:@"body"];
                        NSError *jsonError = nil;
                        NSData *resultData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
                        if (jsonError)
                        {
                            [AirFacebook log:[NSString stringWithFormat:@"Request error -> JSON error: %@", [jsonError description]]];
                        } else
                        {
                            NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                            [AirFacebook dispatchEvent:callback withMessage:resultString];
                        }
                    }
                    return;
                }
                
                [AirFacebook log:[NSString stringWithFormat:@"Request error: %@", [error description]]];
                
            }
            else{
                
                NSError *jsonError = nil;
                NSData *resultData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&jsonError];
                if (jsonError)
                {
                    [AirFacebook log:[NSString stringWithFormat:@"Request JSON error: %@", [jsonError description]]];
                }
                else
                {
                    NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                    [AirFacebook dispatchEvent:callback withMessage:resultString];
                }
                
            }
        }];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(setDefaultAudience)
{
    NSUInteger defaultAudience = FPANE_FREObjectToNSUInteger(argv[0]);
    
    [[AirFacebook sharedInstance] setDefaultAudience:defaultAudience];
    
    return nil;
}

DEFINE_ANE_FUNCTION(setLoginBehavior)
{
    NSUInteger loginBehavior = FPANE_FREObjectToNSUInteger(argv[0]);
    
    [[AirFacebook sharedInstance] setLoginBehavior:loginBehavior];
    
    return nil;
}

DEFINE_ANE_FUNCTION(setDefaultShareDialogMode)
{
    NSUInteger defaultShareDialogMode = FPANE_FREObjectToNSUInteger(argv[0]);
    
    [[AirFacebook sharedInstance] setDefaultShareDialogMode:defaultShareDialogMode];
    
    return nil;
}

DEFINE_ANE_FUNCTION(canPresentShareDialog)
{
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = rootViewController;
    dialog.mode = [[AirFacebook sharedInstance] defaultShareDialogMode];
    BOOL canShow = [dialog canShow];
    
    return FPANE_BOOLToFREObject(canShow);
}

DEFINE_ANE_FUNCTION(shareLinkDialog)
{
    NSString *contentUrl = FPANE_FREObjectToNSString(argv[0]);
    NSString *contentTitle = FPANE_FREObjectToNSString(argv[1]);
    NSString *contentDescription = FPANE_FREObjectToNSString(argv[2]);
    NSString *imageUrl = FPANE_FREObjectToNSString(argv[3]);
    BOOL useShareApi = FPANE_FREObjectToBOOL(argv[4]);
    NSString *callback = FPANE_FREObjectToNSString(argv[5]);
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    if(contentUrl != NULL) content.contentURL = [NSURL URLWithString:contentUrl];
    if(contentTitle != NULL) content.contentTitle = contentTitle;
    if(contentDescription != NULL) content.contentDescription = contentDescription;
    if(imageUrl != NULL) content.imageURL = [NSURL URLWithString:imageUrl];
    
    if(callback == NULL){
        [[AirFacebook sharedInstance] share:content usingShareApi:useShareApi delegate:nil];
    } else {
        [[AirFacebook sharedInstance] share:content usingShareApi:useShareApi andShareCallback:callback];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(activateApp)
{
    [FBSDKAppEvents activateApp];
    return nil;
}

void AirFacebookContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    
//    [[NSNotificationCenter defaultCenter] addObserver:[AirFacebook sharedInstance] selector:@selector(didFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSDictionary *functions = @{
        @"initFacebook":                    [NSValue valueWithPointer:&initFacebook],
        @"handleOpenURL":                   [NSValue valueWithPointer:&handleOpenURL],
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

        // FB events
        @"activateApp":                     [NSValue valueWithPointer:&activateApp],
        
        // Debug
        @"nativeLog":                       [NSValue valueWithPointer:&nativeLog],
        @"setNativeLogEnabled":             [NSValue valueWithPointer:&setNativeLogEnabled],
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
