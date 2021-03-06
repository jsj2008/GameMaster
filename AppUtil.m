//
//  AppUtil.m
//  imem
//
//  Created by LuoBin on 14-8-19.
//
//

#import "AppUtil.h"
#import <sys/sysctl.h>
#import <dlfcn.h>
#include <mach-o/dyld.h>
#import <UIKit/UIKit.h>

@interface UIImage (___Private)

@end

@implementation UIImage (___Private)

- (UIImage *)__imageByResizingToSize__:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, .0);
    [self drawInRect:CGRectMake(.0, .0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end

@implementation AppUtil

+ (void *)lookupSymbol:(NSString *)symbol {
    unsigned pathSize = MAXPATHLEN + 1;
    char path[pathSize];
    _NSGetExecutablePath(path, &pathSize);
    path[pathSize] = '\0';
    
    void *sbserv = dlopen(path, RTLD_LAZY);
    void *ptr = dlsym(sbserv, [symbol UTF8String]);
    dlclose(sbserv);
    
    return ptr;
}

+ (NSDictionary *)appInfoForProcessID:(pid_t)pid {
    CFStringRef (*SBSCopyDisplayIdentifierForProcessID)(pid_t PID) = [self lookupSymbol:@"SBSCopyDisplayIdentifierForProcessID"];
    
    NSString * appId = (NSString *)SBSCopyDisplayIdentifierForProcessID(pid);
    if (appId == nil) {
        return nil;
    }
    return [self appInfoForDisplayIdentifier:appId];
}

+ (NSDictionary *)appInfoForDisplayIdentifier:(NSString *)displayIdentifier {
    unsigned pathSize = MAXPATHLEN + 1;
    char path[pathSize];
    _NSGetExecutablePath(path, &pathSize);
    path[pathSize] = '\0';
    
    void *sbserv = dlopen(path, RTLD_LAZY);
    
    CFStringRef (*SBSCopyLocalizedApplicationNameForDisplayIdentifier)(CFStringRef displayIdentifier) = dlsym(sbserv, "SBSCopyLocalizedApplicationNameForDisplayIdentifier");
    
    CFDataRef (*SBSCopyIconImagePNGDataForDisplayIdentifier)(CFStringRef displayIdentifier) = dlsym(sbserv, "SBSCopyIconImagePNGDataForDisplayIdentifier");
    
    BOOL (*SBSProcessIDForDisplayIdentifier)(CFStringRef identifier, pid_t *pid) = dlsym(sbserv, "SBSProcessIDForDisplayIdentifier");
    
    CFStringRef (*SBSCopyBundlePathForDisplayIdentifier)(CFStringRef displayIdentifier) = dlsym(sbserv, "SBSCopyBundlePathForDisplayIdentifier");

    
    CFStringRef (*SBSCopyFrontmostApplicationDisplayIdentifier)() =
    dlsym(sbserv, "SBSCopyFrontmostApplicationDisplayIdentifier");
    
    dlclose(sbserv);
    
    pid_t pid = 0;
    if (!SBSProcessIDForDisplayIdentifier((CFStringRef)displayIdentifier, &pid)) {
        pid = 0;
    }
    
    NSString *appName = (NSString *)SBSCopyLocalizedApplicationNameForDisplayIdentifier((CFStringRef)displayIdentifier);
    if (!appName) {
        return nil;
    }
    CFDataRef appIconData = SBSCopyIconImagePNGDataForDisplayIdentifier((CFStringRef)displayIdentifier);
    UIImage *appIcon = [UIImage imageWithData:(NSData *)appIconData scale:[UIScreen mainScreen].scale];
    appIcon = [appIcon __imageByResizingToSize__:CGSizeMake(29, 29)];
    
    NSString *bundlePath = (NSString *)SBSCopyBundlePathForDisplayIdentifier((CFStringRef)displayIdentifier);
    
    bundlePath = [bundlePath stringByDeletingLastPathComponent];
    BOOL isSystem = [bundlePath hasSuffix:@"/Applications"];
    
    NSString *frontmostApp = (NSString *)SBSCopyFrontmostApplicationDisplayIdentifier();
    BOOL isFrontmost = [frontmostApp isEqualToString:displayIdentifier];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(pid) forKey:@"processID"];
    [dic setObject:displayIdentifier forKey:@"appID"];
    [dic setObject:appName forKey:@"appName"];
    [dic setObject:appIcon forKey:@"appIcon"];
    [dic setObject:@(isFrontmost) forKey:@"isFrontmost"];
    [dic setObject:@(isSystem) forKey:@"isSystem"];

    return dic;
}

+ (NSArray*) getAppIdentifiers:(BOOL)onlyActive {
    CFArrayRef (*SBSCopyApplicationDisplayIdentifiers)(Boolean onlyActive, Boolean unknown) = [self lookupSymbol:@"SBSCopyApplicationDisplayIdentifiers"];
    
    NSArray *activeDisplayIdentifiers = (NSArray *)SBSCopyApplicationDisplayIdentifiers(onlyActive, NO);
    
    NSMutableArray *appInfos = [NSMutableArray array];
    for (NSString *displayIdentifiers in activeDisplayIdentifiers) {
        if (![displayIdentifiers hasPrefix:@"com.apple."]) {
            [appInfos addObject:displayIdentifiers];
        }
    }
    return appInfos;
}

+ (NSArray*) getApps:(BOOL)onlyActive {
    CFArrayRef (*SBSCopyApplicationDisplayIdentifiers)(Boolean onlyActive, Boolean unknown) = [self lookupSymbol:@"SBSCopyApplicationDisplayIdentifiers"];
        
    NSArray *activeDisplayIdentifiers = (NSArray *)SBSCopyApplicationDisplayIdentifiers(onlyActive, NO);
    
    NSMutableArray *appInfos = [NSMutableArray array];
    for (NSString *displayIdentifiers in activeDisplayIdentifiers) {
        if (![displayIdentifiers hasPrefix:@"com.apple."]) {
            NSDictionary *appInfo = [self appInfoForDisplayIdentifier:displayIdentifiers];
            if (appInfo && ![[appInfo objectForKey:@"isSystem"] boolValue]) {
                [appInfos addObject:appInfo];
            }
        }
    }
    return appInfos;
}

+ (BOOL)launchAppWithIdentifier:(NSString *)identifier {
    return [self launchAppWithIdentifier:identifier launchOptions:nil suspended:NO error:nil];
}

+ (BOOL)launchAppWithIdentifier:(NSString *)identifier launchOptions:(NSDictionary *)launchOptions suspended:(BOOL)suspended error:(NSError **)error {
    unsigned pathSize = MAXPATHLEN + 1;
    char path[pathSize];
    _NSGetExecutablePath(path, &pathSize);
    path[pathSize] = '\0';
    
    void *sbserv = dlopen(path, RTLD_LAZY);
    
    int (*SBSLaunchApplicationWithIdentifierAndLaunchOptions)(CFStringRef identifier, CFDictionaryRef launchOptions, BOOL suspended) = dlsym(sbserv, "SBSLaunchApplicationWithIdentifierAndLaunchOptions");
    
    CFStringRef (*SBSApplicationLaunchingErrorString)(int error) = dlsym(sbserv, "SBSApplicationLaunchingErrorString");
    
    dlclose(sbserv);
    
    int result = SBSLaunchApplicationWithIdentifierAndLaunchOptions((CFStringRef)identifier, (CFDictionaryRef)launchOptions, suspended);
    if (result) {
        if (error) {
            NSString *errString = (NSString *)SBSApplicationLaunchingErrorString(result);
            NSDictionary *userinfo = nil;
            if (errString) {
                userinfo = @{NSLocalizedDescriptionKey:errString};
            }
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:result userInfo:userinfo];
        }
        return NO;
    }
    return YES;
}

@end
