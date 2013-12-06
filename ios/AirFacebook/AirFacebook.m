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

- (void)dealloc
{
    [_appID release];
    [_urlSchemeSuffix release];
    [super dealloc];
}

// every time we have to send back information to the air application, invoque this method wich will dispatch an Event in air
+ (void)dispatchEvent:(NSString *)event withMessage:(NSString *)message
{
    
    NSString *eventName = event ? event : @"LOGGING";
    NSString *messageText = message ? message : @"";
    FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[messageText UTF8String]);
    
}

- (id)initWithAppID:(NSString *)appID urlSchemeSuffix:(NSString *)urlSchemeSuffix
{
    self = [self init];
    
    if (self)
    {
        // Save parameters
        _appID = [appID retain];
        _urlSchemeSuffix = [urlSchemeSuffix retain];
        [AirFacebook log:@"Initializing with application ID %@ and URL scheme suffix %@", _appID, _urlSchemeSuffix];
        
        // Open session if a token is in cache.
        FBSession *session = nil;
        @try
        {
            session = [[FBSession alloc] initWithAppID:appID permissions:nil urlSchemeSuffix:urlSchemeSuffix tokenCacheStrategy:[FBSessionTokenCachingStrategy defaultInstance]];
        }
        @catch (NSException *exception)
        {
            [AirFacebook dispatchEvent:@"LOGGING" withMessage:[exception reason]];
            [session release];
            return nil;
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
                [session release];
                return nil;
            }
        }
        
        [FBSession renewSystemCredentials:NULL];
    
        [session release];
    }

    return self;
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
            [AirFacebook log:[NSString stringWithFormat:@"Session opened with permissions: %@", session.permissions]];
            [AirFacebook dispatchEvent:@"OPEN_SESSION_SUCCESS" withMessage:@"OK"];
            
        }
        else if (status == FBSessionStateClosed)
        {
            [AirFacebook log:@"INFO - Session closed"];
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
        }
    };
}

+ (FBRequestCompletionHandler)requestCompletionHandlerWithCallback:(NSString *)callback
{
    return [[^(FBRequestConnection *connection, id result, NSError *error) {
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
                    NSString *resultString = [[[FBSBJSON alloc] init] stringWithObject:body error:&jsonError];
                    if (jsonError)
                    {
                        [AirFacebook log:[NSString stringWithFormat:@"Request error -> JSON error: %@", [jsonError description]]];
                    } else
                    {
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
            NSString *resultString = [[[FBSBJSON alloc] init] stringWithObject:result error:&jsonError];
            if (jsonError)
            {
                [AirFacebook log:[NSString stringWithFormat:@"Request JSON error: %@", [jsonError description]]];
            }
            else
            {
                [AirFacebook dispatchEvent:callback withMessage:resultString];
            }
            
        }
    } copy] autorelease];
}

+ (FBDialogAppCallCompletionHandler)shareDialogHandlerWithCallback:(NSString *)callback
{
    return [[^(FBAppCall* call, NSDictionary *results, NSError *error) {
        NSString *resultString = [[[FBSBJSON alloc] init] stringWithObject:results];
        [AirFacebook dispatchEvent:callback withMessage:resultString];
    } copy] autorelease];
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
    [[AirFacebook sharedInstance] initWithAppID:appID urlSchemeSuffix:urlSchemeSuffix];
    
    return nil;
}

DEFINE_ANE_FUNCTION(handleOpenURL)
{
    // Retrieve URL
    NSURL *url = [NSURL URLWithString:FPANE_FREObjectToNSString(argv[0])];
    
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
    
    // Retrieve permissions
    NSArray *permissions = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
    
    // Get the permissions type
    NSString *type = FPANE_FREObjectToNSString(argv[1]);
    
    // Print log
    [AirFacebook log:[NSString stringWithFormat:@"Trying to open session with %@ permissions: %@", type, permissions]];
    
    // select the right authentication flow
    FBSessionLoginBehavior loginBehavior;
    if ([type isEqualToString:@"read"])
    {
        // system account if no publish permissions
        loginBehavior = FBSessionLoginBehaviorUseSystemAccountIfPresent;
    } else
    {
        // web if publish permissions
        loginBehavior = FBSessionLoginBehaviorWithFallbackToWebView;
    }
    
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
    
    [session release];
    [permissions release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(reauthorizeSessionWithPermissions)
{
    
    // Retrieve permissions
    NSArray *permissions = FPANE_FREObjectToNSArrayOfNSString(argv[0]);
        
    // Get the permissions type
    NSString *type = FPANE_FREObjectToNSString(argv[1]);
    
    // Print log
    [AirFacebook log:[NSString stringWithFormat:@"Trying to reauthorize session with %@ permissions: %@", type, permissions]];
    
    // Start authentication flow
    FBReauthorizeSessionCompletionHandler completionHandler = [AirFacebook reauthorizeSessionCompletionHandler];
    
    @try {
        if ([type isEqualToString:@"read"])
        {
            [[FBSession activeSession] requestNewReadPermissions:permissions completionHandler:completionHandler];
        }
        else if ([type isEqualToString:@"publish"])
        {
            [[FBSession activeSession] requestNewPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:completionHandler];
        }
    }
    @catch (NSException *exception) {
        [AirFacebook dispatchEvent:@"REAUTHORIZE_SESSION_ERROR" withMessage:[exception reason]];
    }
    
    [permissions release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(closeSessionAndClearTokenInformation)
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    return nil;
}

DEFINE_ANE_FUNCTION(requestWithGraphPath)
{
    
    // Retrieve graph path
    NSString *graphPath = FPANE_FREObjectToNSString(argv[0]);
    
    // Retrieve request parameters
    NSDictionary *parameters = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
    
    // Retrieve HTTP method
    NSString *httpMethod = FPANE_FREObjectToNSString(argv[3]);
    
    // Retrieve callback name
    NSString *callback = FPANE_FREObjectToNSString(argv[4]);
    
    // Perform Facebook request
    FBRequest *request = [FBRequest requestWithGraphPath:graphPath parameters:parameters HTTPMethod:httpMethod];
    FBRequestCompletionHandler completionHandler = [AirFacebook requestCompletionHandlerWithCallback:callback];
    [request startWithCompletionHandler:completionHandler];
    
    [parameters release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(canPresentShareDialog)
{
    
    // dummy params, they don't influence the eligibility for native dialog
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    
    BOOL canPresentDialog = [FBDialogs canPresentShareDialogWithParams:params];
    
    return FPANE_BOOLToFREObject(canPresentDialog);
    
}

DEFINE_ANE_FUNCTION(shareStatusDialog)
{
    
    NSString *callback = FPANE_FREObjectToNSString(argv[0]);
    
    [FBDialogs presentShareDialogWithLink:nil handler:[AirFacebook shareDialogHandlerWithCallback:callback]];
    
    return nil;
    
}

DEFINE_ANE_FUNCTION(shareLinkDialog)
{
    
    // Retrieve parameters
    NSString *link = FPANE_FREObjectToNSString(argv[0]);
    NSString *name = FPANE_FREObjectToNSString(argv[1]);
    NSString *caption = FPANE_FREObjectToNSString(argv[2]);
    NSString *description = FPANE_FREObjectToNSString(argv[3]);
    NSString *pictureUrl = FPANE_FREObjectToNSString(argv[4]);
    NSDictionary *clientState = FPANE_FREObjectsToNSDictionaryOfNSString(argv[5], argv[6]);
    NSString *callback = FPANE_FREObjectToNSString(argv[7]);
    
    [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:link]
                                     name:name
                                  caption:caption
                              description:description
                                  picture:[NSURL URLWithString:pictureUrl]
                              clientState:clientState
                                  handler:[AirFacebook shareDialogHandlerWithCallback:callback]];
    
    return nil;
    
}

DEFINE_ANE_FUNCTION(canPresentOpenGraphDialog)
{
    
    NSString *actionType = FPANE_FREObjectToNSString(argv[0]);
    NSDictionary *params = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
    NSString *previewProperty = FPANE_FREObjectToNSString(argv[3]);
    
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObjectWrappingDictionary:params];
    
    FBOpenGraphActionShareDialogParams* dialogParams = [[FBOpenGraphActionShareDialogParams alloc] init];
    dialogParams.action = action;
    dialogParams.actionType = actionType;
    dialogParams.previewPropertyName = previewProperty;
    
    BOOL canPresent = [FBDialogs canPresentShareDialogWithOpenGraphActionParams:dialogParams];
    
    return FPANE_BOOLToFREObject(canPresent);
    
}

DEFINE_ANE_FUNCTION(shareOpenGraphDialog)
{
    
    NSString *actionType = FPANE_FREObjectToNSString(argv[0]);
    NSDictionary *params = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
    NSString *previewProperty = FPANE_FREObjectToNSString(argv[3]);
    NSDictionary *clientState = FPANE_FREObjectsToNSDictionaryOfNSString(argv[4], argv[5]);
    NSString *callback = FPANE_FREObjectToNSString(argv[6]);
    
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObjectWrappingDictionary:params];
    
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:actionType
                                 previewPropertyName:previewProperty
                                         clientState:clientState
                                             handler:[AirFacebook shareDialogHandlerWithCallback:callback]];
    
    return nil;
    
}

/* deprecated */
DEFINE_ANE_FUNCTION(webDialog)
{
    
    NSString *method = FPANE_FREObjectToNSString(argv[0]);
    
    NSDictionary *parameters = FPANE_FREObjectsToNSDictionaryOfNSString(argv[1], argv[2]);
    
    // Retrieve callback name
    NSString *callback = FPANE_FREObjectToNSString(argv[3]);
    
    // If possible, open new-style Facebook sharing sheet
    BOOL isFeedDialog = [method isEqualToString:@"feed"];
    BOOL isRequestDialog = [method isEqualToString:@"apprequests"];
    
    if( [parameters objectForKey:@"app_id"] == nil )
    {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        [temp setObject:[[AirFacebook sharedInstance] appID] forKey:@"app_id"];
        parameters = temp;
    }
    
    [AirFacebook log:
         @"displaying facebook web dialog : isFeedingDialog - %@",
         isFeedDialog ? @"YES" : @"NO"
    ];
    
    FBWebDialogHandler resultHandler = ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
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
        NSLog(@"end");
    };
    
    if (isFeedDialog)
    {
        [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:parameters handler:resultHandler];
    }
    else if (isRequestDialog)
    {
        [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                      message:[parameters objectForKey:@"message"]
                                                        title:nil
                                                   parameters:parameters
                                                      handler:resultHandler ];
    }
    else
    {
        [FBWebDialogs presentDialogModallyWithSession:nil dialog:method parameters:parameters handler:resultHandler];
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
    NSInteger nbFuntionsToLink = 16;
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
    
    func[9].name = (const uint8_t*) "canPresentShareDialog";
    func[9].functionData = NULL;
    func[9].function = &canPresentShareDialog;
    
    func[10].name = (const uint8_t*) "shareStatusDialog";
    func[10].functionData = NULL;
    func[10].function = &shareStatusDialog;
    
    func[11].name = (const uint8_t*) "shareLinkDialog";
    func[11].functionData = NULL;
    func[11].function = &shareLinkDialog;
    
    func[12].name = (const uint8_t*) "canPresentOpenGraphDialog";
    func[12].functionData = NULL;
    func[12].function = &canPresentOpenGraphDialog;
    
    func[13].name = (const uint8_t*) "shareOpenGraphDialog";
    func[13].functionData = NULL;
    func[13].function = &shareOpenGraphDialog;
    
    func[14].name = (const uint8_t*) "webDialog";
    func[14].functionData = NULL;
    func[14].function = &webDialog;
    
    func[15].name = (const uint8_t*) "publishInstall";
    func[15].functionData = NULL;
    func[15].function = &publishInstall;
    
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
