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
#import "FBSBJSON.h"

#define PRINT_LOG   YES

FREContext AirFBCtx = nil;

@interface AirFacebook ()
{
    NSMutableArray *_dialogDelegates;
}
@end

@implementation AirFacebook

@synthesize appID = _appID;
@synthesize urlSchemeSuffix = _urlSchemeSuffix;
@synthesize facebook = _facebook;

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
    [_facebook release];
    [_dialogDelegates release];
    [super dealloc];
}

- (id)initWithAppID:(NSString *)appID urlSchemeSuffix:(NSString *)urlSchemeSuffix
{
    self = [self init];
    
    if (self)
    {
        // Save parameters
        _appID = [appID retain];
        _urlSchemeSuffix = [urlSchemeSuffix retain];
        
        // Open session if a token is in cache.
        FBSession *session = [[FBSession alloc] initWithAppID:appID permissions:nil urlSchemeSuffix:urlSchemeSuffix tokenCacheStrategy:nil];
        [FBSession setActiveSession:session];
        if (session.state == FBSessionStateCreatedTokenLoaded)
        {
            [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:[AirFacebook openSessionCompletionHandler]];
        }
        [session release];
    }
    
    return self;
}

+ (FBOpenSessionCompletionHandler)openSessionCompletionHandler
{
    return ^(FBSession *session, FBSessionState status, NSError *error) {
        if (status == FBSessionStateOpen)
        {
            // Give token to old Facebook object (used for FBDialog).
            Facebook *facebook = [[AirFacebook sharedInstance] facebook];
            facebook.accessToken = session.accessToken;
            facebook.expirationDate = session.expirationDate;
            
            [AirFacebook log:[NSString stringWithFormat:@"Session opened with permissions: %@", session.permissions]];
            FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)"OPEN_SESSION_SUCCESS", (const uint8_t *)"OK");
        }
        else if (status == FBSessionStateClosedLoginFailed)
        {
            NSError *innerError;
            if (error && error.userInfo) innerError = [error.userInfo objectForKey:@"com.facebook.sdk:ErrorInnerErrorKey"];
            
            if (innerError && [innerError.domain isEqualToString:@"com.apple.accounts"] && innerError.code == 7)
            {
                [AirFacebook log:@"User cancelled when opening session"];
                FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)"OPEN_SESSION_CANCEL", (const uint8_t *)"OK");
            }
            else
            {
                [AirFacebook log:[NSString stringWithFormat:@"Error when opening session: %@", [error description]]];
                FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)"OPEN_SESSION_ERROR", (const uint8_t *)[[error description] UTF8String]);
            }
        }
        else if (status == FBSessionStateClosed)
        {
            // Remove token from old Facebook object (used for FBDialog).
            Facebook *facebook = [[AirFacebook sharedInstance] facebook];
            facebook.accessToken = nil;
            facebook.expirationDate = nil;
            
            [AirFacebook log:@"INFO - Session closed"];
        }
    };
}

+ (FBReauthorizeSessionCompletionHandler)reauthorizeSessionCompletionHandler
{
    return ^(FBSession *session, NSError *error) {
        if (error)
        {
            NSString *reason;
            if (error.userInfo) reason = [error.userInfo objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"];
            
            if (reason && [reason isEqualToString:@"com.facebook.sdk:ErrorReauthorizeFailedReasonUserCancelled"])
            {
                [AirFacebook log:@"User cancelled when reauthorizing session"];
                FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)"REAUTHORIZE_SESSION_CANCEL", (const uint8_t *)"OK");
            }
            else
            {
                [AirFacebook log:[NSString stringWithFormat:@"Error when reauthorizing session: %@", [error description]]];
                FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)"REAUTHORIZE_SESSION_ERROR", (const uint8_t *)[[error description] UTF8String]);
            }
        }
        else
        {
            [AirFacebook log:[NSString stringWithFormat:@"Session reauthorized with permissions: %@", session.permissions]];
            FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)"REAUTHORIZE_SESSION_SUCCESS", (const uint8_t *)"OK");
        }
    };
}

+ (FBRequestCompletionHandler)requestCompletionHandlerWithCallback:(NSString *)callback
{
    return [[^(FBRequestConnection *connection, id result, NSError *error) {
        if (error)
        {
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
                NSString *eventName = callback ? callback : @"LOGGING";
                FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[resultString UTF8String]);
            }
        }
    } copy] autorelease];
}

+ (FBShareDialogHandler)shareDialogHandlerWithCallback:(NSString *)callback
{
    return [[^(FBNativeDialogResult result, NSError *error) {
        NSString *resultString = nil;
        switch (result)
        {
            case FBNativeDialogResultCancelled:
                resultString = @"{ \"cancelled\": true}";
                break;
            
            case FBNativeDialogResultError:
                resultString = [NSString stringWithFormat:@"{ \"error\": \"%@\" }", [error description]];
                
            default:
                resultString = @"{}";
                break;
        }
        FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[callback UTF8String], (const uint8_t *)[resultString UTF8String]);
    } copy] autorelease];
}

- (DialogDelegate *)dialogDelegateWithCallback:(NSString *)callback
{
    if (!_dialogDelegates)
    {
        _dialogDelegates = [[NSMutableArray alloc] initWithCapacity:2];
    }
    
    DialogDelegate *delegate = [[DialogDelegate alloc] init];
    delegate.callback = callback;
    [_dialogDelegates addObject:delegate];
    
    return [delegate autorelease];
}

- (void)dialogDelegate:(DialogDelegate *)delegate finishedWithResult:(NSString *)result
{
    FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[delegate.callback UTF8String], (const uint8_t *)[result UTF8String]);
    
    if ([_dialogDelegates containsObject:delegate])
    {
        [_dialogDelegates removeObject:delegate];
    }
}

- (Facebook *)facebook
{
    if (!_facebook)
    {
        _facebook = [[Facebook alloc] initWithAppId:_appID urlSchemeSuffix:_urlSchemeSuffix andDelegate:nil];
    }
    
    return _facebook;
}

+ (void)log:(NSString *)string
{
    if (PRINT_LOG) NSLog(@"[AirFacebook] %@", string);
    FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)"LOGGING", (const uint8_t *)[string UTF8String]);
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
    uint32_t stringLength;
    
    // Retrieve URL
    const uint8_t *urlString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &urlString) != FRE_OK)
    {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:(char*)urlString]];
    
    // Print a debug log
    [AirFacebook log:[NSString stringWithFormat:@"Handle open URL: %@", url]];
    
    // Give the URL to the Facebook session
    FBSession *session = [FBSession activeSession];
    [session handleOpenURL:url];
    
    return nil;
}

DEFINE_ANE_FUNCTION(getAccessToken)
{
    FBSession *session = [FBSession activeSession];
    NSString *accessToken = [session accessToken];
    
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
    NSTimeInterval expirationTimestamp = [session.expirationDate timeIntervalSince1970];
    
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
    uint32_t stringLength;
    uint32_t arrayLength;
    
    // Retrieve permissions
    NSMutableArray *permissions = [[NSMutableArray alloc] init];
    FREObject permissionsArray = argv[0];
    if (permissionsArray)
    {
        if (FREGetArrayLength(permissionsArray, &arrayLength) != FRE_OK)
        {
            arrayLength = 0;
        }
        
        for (NSInteger i = arrayLength-1; i >= 0; i--)
        {
            // Get permission at index i. Skip this index if there's an error.
            FREObject permissionRaw;
            if (FREGetArrayElementAt(permissionsArray, i, &permissionRaw) != FRE_OK)
            {
                continue;
            }
            
            // Convert it to string. Skip this index if there's an error.
            const uint8_t *permissionString;
            if (FREGetObjectAsUTF8(permissionRaw, &stringLength, &permissionString) != FRE_OK)
            {
                continue;
            }
            NSString *permission = [NSString stringWithUTF8String:(char*)permissionString];
            
            // Add the permission to the array
            [permissions addObject:permission];
        }
    }
    
    // Get the permissions type
    NSString *type;
    const uint8_t *typeString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &typeString) == FRE_OK)
    {
        type = [NSString stringWithUTF8String:(char*)typeString];
    }
    
    // Print log
    [AirFacebook log:[NSString stringWithFormat:@"Trying to open session with %@ permissions: %@", type, permissions]];
    
    // Chose login behavior depending on permissions type
    FBSessionLoginBehavior loginBehavior;
    if ([type isEqualToString:@"readAndPublish"])
    {
        loginBehavior = FBSessionLoginBehaviorWithFallbackToWebView;
    }
    else
    {
        loginBehavior = FBSessionLoginBehaviorUseSystemAccountIfPresent;
    }
    
    // Start authentication flow
    NSString *appID = [[AirFacebook sharedInstance] appID];
    NSString *urlSchemeSuffix = [[AirFacebook sharedInstance] urlSchemeSuffix];
    FBSession *session = [[FBSession alloc] initWithAppID:appID permissions:permissions defaultAudience:FBSessionDefaultAudienceFriends urlSchemeSuffix:urlSchemeSuffix tokenCacheStrategy:nil];
    [FBSession setActiveSession:session];
    FBOpenSessionCompletionHandler completionHandler = [AirFacebook openSessionCompletionHandler];
    [session openWithBehavior:loginBehavior completionHandler:completionHandler];
    
    [permissions release];
    [session release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(reauthorizeSessionWithPermissions)
{
    uint32_t stringLength;
    uint32_t arrayLength;
    
    // Retrieve permissions
    NSMutableArray *permissions = [[NSMutableArray alloc] init];
    FREObject permissionsArray = argv[0];
    if (permissionsArray)
    {
        if (FREGetArrayLength(permissionsArray, &arrayLength) != FRE_OK)
        {
            arrayLength = 0;
        }
        
        for (NSInteger i = arrayLength-1; i >= 0; i--)
        {
            // Get permission at index i. Skip this index if there's an error.
            FREObject permissionRaw;
            if (FREGetArrayElementAt(permissionsArray, i, &permissionRaw) != FRE_OK)
            {
                continue;
            }
            
            // Convert it to string. Skip this index if there's an error.
            const uint8_t *permissionString;
            if (FREGetObjectAsUTF8(permissionRaw, &stringLength, &permissionString) != FRE_OK)
            {
                continue;
            }
            NSString *permission = [NSString stringWithUTF8String:(char*)permissionString];
            
            // Add permission to the array
            [permissions addObject:permission];
        }
    }
    
    // Get the permissions type
    NSString *type;
    const uint8_t *typeString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &typeString) == FRE_OK)
    {
        type = [NSString stringWithUTF8String:(char*)typeString];
    }
    
    // Print log
    [AirFacebook log:[NSString stringWithFormat:@"Trying to reauthorize session with %@ permissions: %@", type, permissions]];
    
    // Start authentication flow
    FBReauthorizeSessionCompletionHandler completionHandler = [AirFacebook reauthorizeSessionCompletionHandler];
    if ([type isEqualToString:@"read"])
    {
        [[FBSession activeSession] reauthorizeWithReadPermissions:permissions completionHandler:completionHandler];
    }
    else if ([type isEqualToString:@"publish"])
    {
        [[FBSession activeSession] reauthorizeWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:completionHandler];
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
    
    [parameters release];
    
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
    BOOL canPresentNativeDialog = [FBNativeDialogs canPresentShareDialogWithSession:session];
    BOOL isFeedDialog = [method isEqualToString:@"feed"];
    BOOL hasNoRecipient = ([parameters objectForKey:@"to"] == nil || [[parameters objectForKey:@"to"] length] == 0);
    if (allowNativeUI && canPresentNativeDialog && isFeedDialog && hasNoRecipient)
    {
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        NSString *initialText = [parameters objectForKey:@"name"];
        UIImage *image = nil;
        NSURL *url = [NSURL URLWithString:[parameters objectForKey:@"link"]];
        FBShareDialogHandler handler = [AirFacebook shareDialogHandlerWithCallback:callback];
        
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
        
        [FBNativeDialogs presentShareDialogModallyFrom:rootViewController initialText:initialText image:image url:url handler:handler];
    }
    else // Else, open old-style Facebook dialog
    {
        DialogDelegate *delegate = [[AirFacebook sharedInstance] dialogDelegateWithCallback:callback];
        [[[AirFacebook sharedInstance] facebook] dialog:method andParams:parameters andDelegate:delegate];
    }
    
    [parameters release];
    
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
