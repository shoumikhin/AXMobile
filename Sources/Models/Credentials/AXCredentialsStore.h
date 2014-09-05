//
//  AXCredentialsStore.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXCredentials.h"

@interface AXCredentialsStore : NSObject

+ (BOOL)save:(AXCredentials *)credentials forService:(NSString *)service withUsername:(NSString *)username;
+ (AXCredentials *)loadForService:(NSString *)service withUsername:(NSString *)username;

@end
