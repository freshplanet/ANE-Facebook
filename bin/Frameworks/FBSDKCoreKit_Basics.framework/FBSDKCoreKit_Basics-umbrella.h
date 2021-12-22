#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FBSDKBase64.h"
#import "FBSDKBasicUtility.h"
#import "FBSDKCoreKit_Basics.h"
#import "FBSDKCrashHandler+CrashHandlerProtocol.h"
#import "FBSDKCrashHandler.h"
#import "FBSDKCrashHandlerProtocol.h"
#import "FBSDKCrashObserving.h"
#import "FBSDKFileDataExtracting.h"
#import "FBSDKFileManaging.h"
#import "FBSDKInfoDictionaryProviding.h"
#import "FBSDKJSONValue.h"
#import "FBSDKLibAnalyzer.h"
#import "FBSDKSafeCast.h"
#import "FBSDKSessionProviding.h"
#import "FBSDKTypeUtility.h"
#import "FBSDKURLSession.h"
#import "FBSDKURLSessionTask.h"
#import "FBSDKUserDataStore.h"
#import "NSBundle+InfoDictionaryProviding.h"

FOUNDATION_EXPORT double FBSDKCoreKit_BasicsVersionNumber;
FOUNDATION_EXPORT const unsigned char FBSDKCoreKit_BasicsVersionString[];

