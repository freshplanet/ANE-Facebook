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

#define PRINT_LOG   YES

FREContext AirFBCtx = nil;

@interface AirFacebook ()
{
}
@end

@implementation AirFacebook

@synthesize appID = _appID;
@synthesize urlSchemeSuffix = _urlSchemeSuffix;
@synthesize friendCache = _friendCache;

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

// every time we have to send back information to the air application, invoque this method wich will dispatch an Event in air
+ (void)dispatchEvent:(NSString *)event withMessage:(NSString *)message
{
    
    NSString *eventName = event ? event : @"LOGGING";
    NSString *messageText = message ? message : @"";
    FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[messageText UTF8String]);
    
}

- (void)setupWithAppID:(NSString *)appID urlSchemeSuffix:(NSString *)urlSchemeSuffix
{
    // Save parameters
    _appID = appID;
    _urlSchemeSuffix = urlSchemeSuffix;
    _friendCache = [[FBFrictionlessRecipientCache alloc] init];
    NSMutableString *logMessage = [NSMutableString stringWithFormat:@"Initializing with application ID %@", _appID];
    if (_urlSchemeSuffix)
    {
        [logMessage appendFormat:@" and URL scheme suffix %@", _urlSchemeSuffix];
    }
    [AirFacebook log:logMessage];
    
    // Open session if a token is in cache.
    FBSession *session = nil;
    @try
    {
        session = [[FBSession alloc] initWithAppID:appID permissions:nil urlSchemeSuffix:urlSchemeSuffix tokenCacheStrategy:[FBSessionTokenCachingStrategy defaultInstance]];
    }
    @catch (NSException *exception)
    {
        [AirFacebook dispatchEvent:@"LOGGING" withMessage:[exception reason]];
        return;
    }
    
    [FBSession setActiveSession:session];
    if (session.state == FBSessionStateCreatedTokenLoaded)
    {
        [AirFacebook log:@"Opening session from cached token"];
        
        @try
        {
            [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:[AirFacebook openSessionCompletionHandler]];
        }
        @catch (NSException *exception)
        {
            [AirFacebook dispatchEvent:@"LOGGING" withMessage:[exception reason]];
            return;
        }
    }
    
    [FBSession renewSystemCredentials:NULL];
}

+ (FBOpenSessionCompletionHandler)openSessionCompletionHandler
{
    return ^(FBSession *session, FBSessionState status, NSError *error) {
        
        if (error) {
            if (error.fberrorShouldNotifyUser) {
                // if the error is application turned off from ios6 settings
                if ([[error userInfo][FBErrorLoginFailedReason] isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue]) {
                    [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:@"APPLICATION_TURNED_OFF"];
                } else {
                    [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:error.fberrorUserMessage];
                }
            } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
                [AirFacebook log:@"Login error : User Cancelled (Error details : %@ )", error.description];
                [AirFacebook dispatchEvent:@"OPEN_SESSION_CANCEL" withMessage:@"OK"];
            } else {
                [AirFacebook log:@"Unexpected Error on login (Error details : %@ )", error.description];
                [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:[error description]];
            }
        }
        
        if (status == FBSessionStateOpen)
        {
            [AirFacebook log:[NSString stringWithFormat:@"Session opened with permissions: %@", [session.permissions componentsJoinedByString:@", "]]];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_SUCCESS" withMessage:@"OK"];
            [[[AirFacebook sharedInstance] friendCache] prefetchAndCacheForSession:nil];
            
        }
        else if (status == FBSessionStateClosed)
        {
            [AirFacebook log:@"Session closed"];
        }
    };
}

+ (FBReauthorizeSessionCompletionHandler)reauthorizeSessionCompletionHandler
{
    return ^(FBSession *session, NSError *error) {
        
        if (error)
        {
            if (error.fberrorShouldNotifyUser) {
                // show sdk message
                [AirFacebook log:[NSString stringWithFormat:@"Error when reauthorizing session: %@", [error description]]];
                [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_ERROR" withMessage:[error description]];
            } else {
                if (error.fberrorCategory == FBErrorCategoryUserCancelled){
                    // User Cancelled
                    [AirFacebook log:@"User cancelled when reauthorizing session"];
                    [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_CANCEL" withMessage:@"OK"];
                } else {
                    [AirFacebook log:@"Error when reauthorizing session: %@", [error description]];
                    [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_ERROR" withMessage:[error description]];
                }
            }
        }
        else
        {
            [AirFacebook log:@"Session reauthorized with permissions: %@", session.permissions];
            [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_SUCCESS" withMessage:@"OK"];
            [[[AirFacebook sharedInstance] friendCache] prefetchAndCacheForSession:nil];
        }
    };
}

+ (FBRequestCompletionHandler)requestCompletionHandlerWithCallback:(NSString *)callback
{
    return [^(FBRequestConnection *connection, id result, NSError *error) {
        if (error)
        {
            
            // If user doesn't have the publish permission, ask them
            if (error.fberrorCategory == FBErrorCategoryPermissions) {
                [AirFacebook log:@"Requesting publish permissions"];
                [AirFacebook dispatchEvent:@"ACTION_REQUIRE_PERMISSION" withMessage:@"publish_actions"];
                return;
            } else if (callback)
			{
                NSDictionary* parsedResponseKey = [error.userInfo objectForKey:FBErrorParsedJSONResponseKey];
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
                        FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[callback UTF8String], (const uint8_t *)[resultString UTF8String]);
                    }
                }
                return;
			}
            
            [AirFacebook log:[NSString stringWithFormat:@"Request error: %@", [error description]]];
            
        }
        else
        {
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
    } copy];
}

+ (FBOSIntegratedShareDialogHandler)shareDialogHandlerWithCallback:(NSString *)callback
{
    return [^(FBOSIntegratedShareDialogResult result, NSError *error) {
        NSString *resultString = nil;
        switch (result)
        {
            case FBOSIntegratedShareDialogResultCancelled:
                resultString = @"{ \"cancelled\": true}";
                break;
            
            case FBOSIntegratedShareDialogResultError:
                resultString = [NSString stringWithFormat:@"{ \"error\": \"%@\" }", [error description]];
                
            default:
                resultString = @"{}";
                break;
        }
        [AirFacebook dispatchEvent:callback withMessage:resultString];
    } copy];
}

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

@end


#pragma mark - C interface

DEFINE_ANE_FUNCTION(init)
{
    uint32_t stringLength;
    
    // Retrieve application ID
    NSString *appID = nil;
    const uint8_t *appIDString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &appIDString) == FRE_OK)
    {
        appID = [NSString stringWithUTF8String:(char*)appIDString];
    }
    
    NSString *urlSchemeSuffix = nil;
    const uint8_t *urlSchemeSuffixString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &urlSchemeSuffixString) == FRE_OK)
    {
        urlSchemeSuffix = [NSString stringWithUTF8String:(char*)urlSchemeSuffixString];
        
        if (urlSchemeSuffix.length == 0)
        {
            urlSchemeSuffix = nil;
        }
    }
    
    // Initialize Facebook
    [[AirFacebook sharedInstance] setupWithAppID:appID urlSchemeSuffix:urlSchemeSuffix];
    
    return nil;
}

DEFINE_ANE_FUNCTION(handleOpenURL)
{
    uint32_t stringLength;
    
    // Retrieve URL
    const uint8_t *urlString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &urlString) != FRE_OK)
    {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:(char*)urlString]];
    
    // Give the URL to the Facebook session
    FBSession *session = [FBSession activeSession];
    [session handleOpenURL:url];
    
    return nil;
}

DEFINE_ANE_FUNCTION(getAccessToken)
{
    FBSession *session = [FBSession activeSession];
    NSString *accessToken = session.accessTokenData.accessToken;
    
    FREObject result;
    if (FRENewObjectFromUTF8(accessToken.length, (const uint8_t *)[accessToken UTF8String], &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}

DEFINE_ANE_FUNCTION(getExpirationTimestamp)
{
    FBSession *session = [FBSession activeSession];
    NSTimeInterval expirationTimestamp = [session.accessTokenData.expirationDate timeIntervalSince1970];
    
    FREObject result;
    if (FRENewObjectFromUint32(expirationTimestamp, &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}

DEFINE_ANE_FUNCTION(isSessionOpen)
{
    FBSession *session = [FBSession activeSession];
    BOOL isSessionOpen = [session isOpen];
    
    FREObject result;
    if (FRENewObjectFromBool(isSessionOpen, &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}

DEFINE_ANE_FUNCTION(openSessionWithPermissions)
{
    NSArray *permissions = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
    NSString *type = FPANE_FREObjectToNSString(argv[1]);
    BOOL systemFlow = FPANE_FREObjectToBOOL(argv[2]);
    
    // Print log
    [AirFacebook log:[NSString stringWithFormat:@"Trying to open session with %@ permissions: %@", type, [permissions componentsJoinedByString:@", "]]];
    
    // Select login behavior
    FBSessionLoginBehavior loginBehavior = systemFlow ? FBSessionLoginBehaviorUseSystemAccountIfPresent : FBSessionLoginBehaviorWithFallbackToWebView;
    
    // Start authentication flow
    FBOpenSessionCompletionHandler completionHandler = [AirFacebook openSessionCompletionHandler];
    NSString *appID = [[AirFacebook sharedInstance] appID];
    NSString *urlSchemeSuffix = [[AirFacebook sharedInstance] urlSchemeSuffix];
    FBSession *session = nil;
    @try
    {
        session = [[FBSession alloc] initWithAppID:appID permissions:permissions defaultAudience:FBSessionDefaultAudienceFriends urlSchemeSuffix:urlSchemeSuffix tokenCacheStrategy:nil];
        [FBSession setActiveSession:session];
        [session openWithBehavior:loginBehavior completionHandler:completionHandler];
    }
    @catch (NSException *exception)
    {
        [AirFacebook dispatchEvent:@"OPEN_SESSION_ERROR" withMessage:[exception reason]];
        return nil;
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(reauthorizeSessionWithPermissions)
{
    NSArray *permissions = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
    NSString *type = FPANE_FREObjectToNSString(argv[1]);
    
    // Print log
    [AirFacebook log:[NSString stringWithFormat:@"Trying to reauthorize session with %@ permissions: %@", type, [permissions componentsJoinedByString:@", "]]];
    
    // Start authentication flow
    FBReauthorizeSessionCompletionHandler completionHandler = [AirFacebook reauthorizeSessionCompletionHandler];
    
    @try
    {
        if ([type isEqualToString:@"read"])
        {
            [[FBSession activeSession] requestNewReadPermissions:permissions completionHandler:completionHandler];
        }
        else
        {
            [[FBSession activeSession] requestNewPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:completionHandler];
        }
    }
    @catch (NSException *exception) {
        [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_ERROR" withMessage:[exception reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(closeSessionAndClearTokenInformation)
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    return nil;
}

DEFINE_ANE_FUNCTION(requestWithGraphPath)
{
    uint32_t stringLength;
    uint32_t arrayLength;
    
    // Retrieve graph path
    NSString *graphPath = nil;
    const uint8_t *graphPathString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &graphPathString) == FRE_OK)
    {
        graphPath = [NSString stringWithUTF8String:(char*)graphPathString];
    }
    
    // Retrieve request parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    FREObject arrayKeys = argv[1]; // array containing the keys
    FREObject arrayValues = argv[2]; // array containing the values
    if (arrayKeys && arrayValues)
    {
        if (FREGetArrayLength(arrayKeys, &arrayLength) != FRE_OK)
        {
            arrayLength = 0;
        }
        
        for (NSInteger i = arrayLength-1; i >= 0; i--)
        {
            // Get the key and value at index i. Skip this index if there's an error.
            FREObject keyRaw, valueRaw;
            if (FREGetArrayElementAt(arrayKeys, i, &keyRaw) != FRE_OK
                || FREGetArrayElementAt(arrayValues, i, &valueRaw) != FRE_OK)
            {
                continue;
            }
            
            // Convert them to strings. Skip this index if there's an error.
            const uint8_t *keyString, *valueString;
            if (FREGetObjectAsUTF8(keyRaw, &stringLength, &keyString) != FRE_OK
                || FREGetObjectAsUTF8(valueRaw, &stringLength, &valueString) != FRE_OK)
            {
                continue;
            }
            NSString *key = [NSString stringWithUTF8String:(char*)keyString];
            NSString *value = [NSString stringWithUTF8String:(char*)valueString];
            
            // Set the entry in parameters dictionary
            [parameters setValue:value forKey:key];
        }
    }
    
    // Retrieve HTTP method
    NSString *httpMethod = nil;
    const uint8_t *httpMethodString;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &httpMethodString) == FRE_OK)
    {
        httpMethod = [NSString stringWithUTF8String:(char*)httpMethodString];
    }
    
    // Retrieve callback name
    NSString *callback = nil;
    const uint8_t *callbackString;
    if (FREGetObjectAsUTF8(argv[4], &stringLength, &callbackString) == FRE_OK)
    {
        callback = [NSString stringWithUTF8String:(char*)callbackString];
    }
    
    // Perform Facebook request
    FBRequest *request = [FBRequest requestWithGraphPath:graphPath parameters:parameters HTTPMethod:httpMethod];
    FBRequestCompletionHandler completionHandler = [AirFacebook requestCompletionHandlerWithCallback:callback];
    [request startWithCompletionHandler:completionHandler];
    
    return nil;
}

DEFINE_ANE_FUNCTION(dialog)
{
    uint32_t stringLength;
    uint32_t arrayLength;
    
    // Retrieve method
    NSString *method = nil;
    const uint8_t *methodString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &methodString) == FRE_OK)
    {
        method = [NSString stringWithUTF8String:(char*)methodString];
    }
    
    // Retrieve request parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    FREObject arrayKeys = argv[1]; // array containing the keys
    FREObject arrayValues = argv[2]; // array containing the values
    if (arrayKeys && arrayValues)
    {
        if (FREGetArrayLength(arrayKeys, &arrayLength) != FRE_OK)
        {
            arrayLength = 0;
        }
        
        for (NSInteger i = arrayLength-1; i >= 0; i--)
        {
            // Get the key and value at index i. Skip this index if there's an error.
            FREObject keyRaw, valueRaw;
            if (FREGetArrayElementAt(arrayKeys, i, &keyRaw) != FRE_OK
                || FREGetArrayElementAt(arrayValues, i, &valueRaw) != FRE_OK)
            {
                continue;
            }
            
            // Convert them to strings. Skip this index if there's an error.
            const uint8_t *keyString, *valueString;
            if (FREGetObjectAsUTF8(keyRaw, &stringLength, &keyString) != FRE_OK
                || FREGetObjectAsUTF8(valueRaw, &stringLength, &valueString) != FRE_OK)
            {
                continue;
            }
            NSString *key = [NSString stringWithUTF8String:(char*)keyString];
            NSString *value = [NSString stringWithUTF8String:(char*)valueString];
            
            // Set the entry in parameters dictionary
            [parameters setValue:value forKey:key];
        }
    }
    
    // Retrieve callback name
    NSString *callback = nil;
    const uint8_t *callbackString;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &callbackString) == FRE_OK)
    {
        callback = [NSString stringWithUTF8String:(char*)callbackString];
    }
    
    // Retrieve native UI flag
    BOOL allowNativeUI = YES;
    uint32_t allowNativeUINumber;
    if (FREGetObjectAsBool(argv[4], &allowNativeUINumber) == FRE_OK)
    {
        allowNativeUI = (allowNativeUINumber != 0);
    }
    
    // If possible, open new-style Facebook sharing sheet
    FBSession *session = [FBSession activeSession];
    BOOL canPresentNativeDialog = [FBDialogs canPresentOSIntegratedShareDialogWithSession:session];
    BOOL isFeedDialog = [method isEqualToString:@"feed"];
    BOOL isRequestDialog = [method isEqualToString:@"apprequests"];
    BOOL hasNoRecipient = ([parameters objectForKey:@"to"] == nil || [[parameters objectForKey:@"to"] length] == 0);
    
    [AirFacebook log:
         @"displaying facebook feed dialog : allowNativeUI - %@, canPresentNativeDialog - %@, isFeedingDialog - %@, hasNoRecipient - %@",
         allowNativeUI ? @"YES" : @"NO",
         canPresentNativeDialog ? @"YES" : @"NO",
         isFeedDialog ? @"YES" : @"NO",
         hasNoRecipient ? @"YES" : @"NO"
    ];
    
    
    if (allowNativeUI && canPresentNativeDialog && isFeedDialog && hasNoRecipient)
    {
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        NSString *initialText = [parameters objectForKey:@"name"];
        UIImage *image = nil;
        NSURL *url = [NSURL URLWithString:[parameters objectForKey:@"link"]];
        FBOSIntegratedShareDialogHandler handler = [AirFacebook shareDialogHandlerWithCallback:callback];
        
        // If there is an image, try to download it
        NSString *picture = [parameters objectForKey:@"picture"];
        if (picture && picture.length > 0)
        {
            NSURL *pictureURL = [NSURL URLWithString:picture];
            NSURLRequest *request = [NSURLRequest requestWithURL:pictureURL cachePolicy:0 timeoutInterval:2];
            NSURLResponse *response = nil;
            NSData *pictureData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
            image = [UIImage imageWithData:pictureData];
        }
        
        [FBDialogs presentOSIntegratedShareDialogModallyFrom:rootViewController initialText:initialText image:image url:url handler:handler];
    }
    else // Else, open old-style Facebook dialog
    {
        if (isFeedDialog)
        {
            [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                                   parameters:parameters
                                                      handler:
             ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {

                 if (error) {
                     // TODO handle errors on a low level using FB SDK
                     NSString *data = [NSString stringWithFormat:@"{ \"error\" : \"%@\"}", [error description]];
                     [AirFacebook dispatchEvent:callback withMessage:data];
                 } else {
                     if (result == FBWebDialogResultDialogNotCompleted) {
                         NSLog(@"User canceled story publishing.");
                         [AirFacebook dispatchEvent:callback withMessage:@"{ \"cancel\" : true}"];
                     } else {
                         NSString *queryString = [resultURL query];
                         NSString *data = queryString ? [NSString stringWithFormat:@"{ \"params\" : \"%@\"}", queryString] : @"{ \"cancel\" : true}";
                         [AirFacebook dispatchEvent:callback withMessage:data];
                     }
                 }
             }
             ];
        } else if (isRequestDialog)
        {
            [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:[parameters objectForKey:@"message"] title:nil parameters:parameters handler:
             ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {

                 if (error) {
                     // TODO handle errors on a low level using FB SDK
                     NSString *data = [NSString stringWithFormat:@"{ \"error\" : \"%@\"}", [error description]];
                     [AirFacebook dispatchEvent:callback withMessage:data];
                 } else {
                     if (result == FBWebDialogResultDialogNotCompleted) {
                         NSLog(@"User canceled story publishing.");
                         [AirFacebook dispatchEvent:callback withMessage:@"{ \"cancel\" : true}"];
                     } else {
                         NSString *queryString = [resultURL query];
                         NSString *data = queryString ? [NSString stringWithFormat:@"{ \"params\" : \"%@\"}", queryString] : @"{ \"cancel\" : true}";
                         [AirFacebook dispatchEvent:callback withMessage:data];
                     }
                 }
             }
             friendCache:[[AirFacebook sharedInstance] friendCache]];
        } else
        {
            [FBWebDialogs presentDialogModallyWithSession:nil dialog:method parameters:parameters
                                                      handler:
             ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {

                 if (error) {
                     // TODO handle errors on a low level using FB SDK
                     NSString *data = [NSString stringWithFormat:@"{ \"error\" : \"%@\"}", [error description]];
                     [AirFacebook dispatchEvent:callback withMessage:data];
                 } else {
                     if (result == FBWebDialogResultDialogNotCompleted) {
                         NSLog(@"User canceled story publishing.");
                         [AirFacebook dispatchEvent:callback withMessage:@"{ \"cancel\" : true}"];
                     } else {
                         NSString *queryString = [resultURL query];
                         NSString *data = queryString ? [NSString stringWithFormat:@"{ \"params\" : \"%@\"}", queryString] : @"{ \"cancel\" : true}";
                         [AirFacebook dispatchEvent:callback withMessage:data];
                     }
                 }
             }
             ];

        }
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(publishInstall)
{
    uint32_t stringLength;

    NSString *appId = nil;
    const uint8_t *appIdString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &appIdString) == FRE_OK)
    {
        appId = [NSString stringWithUTF8String:(char*)appIdString];
        [FBSettings publishInstall:appId];
    }
    return nil;
}


void AirFacebookContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 11;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "init";
    func[0].functionData = NULL;
    func[0].function = &init;
    
    func[1].name = (const uint8_t*) "handleOpenURL";
    func[1].functionData = NULL;
    func[1].function = &handleOpenURL;
    
    func[2].name = (const uint8_t*) "getAccessToken";
    func[2].functionData = NULL;
    func[2].function = &getAccessToken;

    func[3].name = (const uint8_t*) "getExpirationTimestamp";
    func[3].functionData = NULL;
    func[3].function = &getExpirationTimestamp;

    func[4].name = (const uint8_t*) "isSessionOpen";
    func[4].functionData = NULL;
    func[4].function = &isSessionOpen;

    func[5].name = (const uint8_t*) "openSessionWithPermissions";
    func[5].functionData = NULL;
    func[5].function = &openSessionWithPermissions;
    
    func[6].name = (const uint8_t*) "reauthorizeSessionWithPermissions";
    func[6].functionData = NULL;
    func[6].function = &reauthorizeSessionWithPermissions;
    
    func[7].name = (const uint8_t*) "closeSessionAndClearTokenInformation";
    func[7].functionData = NULL;
    func[7].function = &closeSessionAndClearTokenInformation;

    func[8].name = (const uint8_t*) "requestWithGraphPath";
    func[8].functionData = NULL;
    func[8].function = &requestWithGraphPath;
    
    func[9].name = (const uint8_t*) "dialog";
    func[9].functionData = NULL;
    func[9].function = &dialog;
    
    func[10].name = (const uint8_t*) "publishInstall";
    func[10].functionData = NULL;
    func[10].function = &publishInstall;
    
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
