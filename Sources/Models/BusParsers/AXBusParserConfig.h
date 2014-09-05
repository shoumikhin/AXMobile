//
//  AXBusParserConfig.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

@interface AXBusParserConfig : NSObject

+ (NSString *)parseADFSURL:(NSDictionary *)response;
+ (NSString *)parseSupportEmail:(NSDictionary *)response;
+ (NSArray *)parseServicesConfigurations:(NSDictionary *)response;

@end
