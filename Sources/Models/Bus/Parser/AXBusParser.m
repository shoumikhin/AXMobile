//
//  AXBusParser.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXBusParser.h"

//==============================================================================
@implementation AXBusParser
//------------------------------------------------------------------------------
+ (RACSignal *)parseResponse:(NSString *)response
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithXMLString:[response substringWithRegularExpressionPattern:@REGEX_EVERYTHING_BETWEEN_SOAP_TAG("Body") options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators]];

    if (!dictionary[@"faultstring"])
        return [RACSignal return:dictionary];

    NSString *reason = dictionary[@"faultstring"][@"__text"];

    return [RACSignal error:
            [NSError errorWithDomain:@""
                                code:0
                            userInfo:@{
                                        NSLocalizedDescriptionKey : reason ?
                                        NSLocalizedString(reason, nil) :
                                            NSLocalizedString(@"Invalid service response.", nil)
                                     }]];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
