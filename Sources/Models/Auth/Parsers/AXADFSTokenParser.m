//
//  AXADFSTokenParser.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXADFSTokenParser.h"

//==============================================================================
@implementation AXADFSTokenParser
//------------------------------------------------------------------------------
+ (RACSignal *)parseResponse:(NSString *)response
{
    NSString *ADFSToken = [response substringWithRegularExpressionPattern:@REGEX_EVERYTHING_BETWEEN_SOAP_TAG("RequestedSecurityToken") options:NSRegularExpressionCaseInsensitive];

    if (ADFSToken.length > 0)
        return [RACSignal return:ADFSToken];

    NSDictionary *xml = [NSDictionary dictionaryWithXMLString:[response substringWithRegularExpressionPattern:@REGEX_EVERYTHING_BETWEEN_SOAP_TAG("Body") options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators]];
    NSString *reason = xml[@"s:Reason"][@"s:Text"][@"__text"];

    return [RACSignal error:
            [NSError errorWithDomain:@""
                                code:0
                            userInfo:@{
                                        NSLocalizedDescriptionKey : reason ?
                                            NSLocalizedString(reason, nil) :
                                            NSLocalizedString(@"The ADFS security token could not be authenticated or authorized.", nil)
                                     }]];
}
//------------------------------------------------------------------------------
+ (NSDate *)parseExpirationDate:(NSString *)token
{
    NSString *expirationDate = [NSDictionary dictionaryWithXMLString:token][@"saml:Conditions"][@"_NotOnOrAfter"];
    NSDateFormatter *dateFormatter = NSDateFormatter.new;

    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

    return [dateFormatter dateFromString:expirationDate];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
