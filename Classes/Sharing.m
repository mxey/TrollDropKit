//
//  Sharing.m
//  TrollDropKit
//
//  Created by Alexsander Akers on 5/5/16.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

#import "Sharing.h"

static void __TDKSharingInitialize(void *context) {
    CFURLRef bundleURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR("/System/Library/PrivateFrameworks/Sharing.framework"), kCFURLPOSIXPathStyle, false);
    CFBundleRef bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL);
    CFRelease(bundleURL);
    if (!bundle) return;

#define SYMBOLS \
    WRAPPER(SFBrowserKindAirDrop)  \
    WRAPPER(SFOperationKindSender) \
    WRAPPER(SFOperationItemsKey)   \
    WRAPPER(SFOperationNodeKey)    \

#define WRAPPER(X) CFSTR("k" #X),
    CFStringRef symbolNames[] = { SYMBOLS };
#undef WRAPPER

#define WRAPPER(X) (void *)&kTDK ## X,
    void **symbolDestinations[] = { SYMBOLS };
#undef WRAPPER

    CFArrayRef symbolNamesArray = CFArrayCreate(kCFAllocatorDefault, (const void **)symbolNames, sizeof(symbolNames) / sizeof(*symbolNames), &kCFTypeArrayCallBacks);

    void **symbols[sizeof(symbolNames) / sizeof(*symbolNames)];
    CFBundleGetDataPointersForNames(bundle, symbolNamesArray, (void **)symbols);
    CFRelease(symbolNamesArray);

    for (size_t i = 0; i < sizeof(symbolNames) / sizeof(*symbolNames); i++) {
        NSCAssert(symbols[i] != NULL, @"Could not find pointer for symbol named \"%@\"", (__bridge id)symbolNames[i]);
        *symbolDestinations[i] = *symbols[i];
    }
#undef SYMBOLS

#define FUNCTIONS \
    WRAPPER(SFBrowserCreate)             \
    WRAPPER(SFBrowserSetClient)          \
    WRAPPER(SFBrowserSetDispatchQueue)   \
    WRAPPER(SFBrowserOpenNode)           \
    WRAPPER(SFBrowserCopyChildren)       \
    WRAPPER(SFBrowserInvalidate)         \
    WRAPPER(SFBrowserGetRootNode)        \
    WRAPPER(SFNodeCopyDisplayName)       \
    WRAPPER(SFNodeCopyComputerName)      \
    WRAPPER(SFNodeCopySecondaryName)     \
    WRAPPER(SFOperationCreate)           \
    WRAPPER(SFOperationSetClient)        \
    WRAPPER(SFOperationSetDispatchQueue) \
    WRAPPER(SFOperationCopyProperty)     \
    WRAPPER(SFOperationSetProperty)      \
    WRAPPER(SFOperationResume)           \
    WRAPPER(SFOperationCancel)           \

#define WRAPPER(X) CFSTR(#X),
    CFStringRef functionNames[] = { FUNCTIONS };
#undef WRAPPER

#define WRAPPER(X) (void *)&TDK ## X,
    const void **functionDestinations[] = { FUNCTIONS };
#undef WRAPPER

    CFArrayRef functionNamesArray = CFArrayCreate(kCFAllocatorDefault, (const void **)functionNames, sizeof(functionNames) / sizeof(*functionNames), &kCFTypeArrayCallBacks);

    void *functions[sizeof(functionNames) / sizeof(*functionNames)];
    CFBundleGetFunctionPointersForNames(bundle, functionNamesArray, functions);
    CFRelease(functionNamesArray);

    for (size_t i = 0; i < sizeof(functionNames) / sizeof(*functionNames); i++) {
        NSCAssert(functions[i] != NULL, @"Could not find pointer for function named \"%@\"", (__bridge id)functionNames[i]);
        *functionDestinations[i] = functions[i];
    }
#undef FUNCTIONS

    CFRelease(bundle);
}

void TDKSharingInitialize(void) {
    static dispatch_once_t onceToken;
    dispatch_once_f(&onceToken, NULL, __TDKSharingInitialize);
}
