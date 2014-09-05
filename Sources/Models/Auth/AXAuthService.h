//
//  AXAuthService.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXCredentials.h"

@interface AXAuthService : NSObject

+ (instancetype) __unavailable new;
- (instancetype) __unavailable init;
- (instancetype)initWithService:(NSString *)namespace andADFSURL:(NSURL *)ADFSURL;

- (RACSignal *)loginUser:(NSString *)username withPassword:(NSString *)password;

@end
