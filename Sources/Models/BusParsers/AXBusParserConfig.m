//
//  AXBusParserConfig.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXBusParserConfig.h"

//==============================================================================
#define BUS_RESPONSE_TAG_ROOT "GetConfigurationDataResult"
//==============================================================================
@implementation AXBusParserConfig
//------------------------------------------------------------------------------
+ (NSString *)parseADFSURL:(NSDictionary *)response
{
    return response[@BUS_RESPONSE_TAG_ROOT][@"AdfsUrl"];
}
//------------------------------------------------------------------------------
+ (NSString *)parseSupportEmail:(NSDictionary *)response
{
    return response[@BUS_RESPONSE_TAG_ROOT][@"SupportEmail"];
}
//------------------------------------------------------------------------------
+ (NSArray *)parseServicesConfigurations:(NSDictionary *)response
{
    return response[@BUS_RESPONSE_TAG_ROOT][@"ServicesInfo"][@"ServiceInfo"];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
