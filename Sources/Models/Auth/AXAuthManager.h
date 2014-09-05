//
//  AXAuthManager.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXCredentials.h"

typedef NS_ENUM(NSInteger, AXAuthState)
{
    AXAuthLoggedOut = NO,
    AXAuthLoggingIn,
    AXAuthLoggedIn,
    AXAuthLoggingOut
};

@interface AXAuthManager : NSObject

@property (nonatomic, readonly) AXAuthState state;
@property (nonatomic, readonly) NSString *service;
@property (nonatomic, readonly) AXCredentials *credentials;
@property (nonatomic, readonly) NSArray *configurations;
@property (nonatomic) BOOL saveLastLoginCredentials;

+ (instancetype)shared;

- (RACSignal *)loginAtService:(NSString *)service withUser:(NSString *)username andPassword:(NSString *)password;
- (RACSignal *)logout;

@end
