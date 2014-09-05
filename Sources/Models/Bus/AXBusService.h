//
//  AXBusService.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXResponseParser.h"
#import "AXCredentials.h"

@interface AXBusService : NSObject

@property (nonatomic) AXCredentials *credentials;

+ (instancetype) __unavailable new;
- (instancetype) __unavailable init;
- (instancetype)initWithService:(NSString *)namespace contract:(NSString *)contract andContractBusPath:(NSString *)contractBusPath;

- (RACSignal *)callAction:(NSString *)action withXMLArguments:(NSString *)xmlArguments;

@end
