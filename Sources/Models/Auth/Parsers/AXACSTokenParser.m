//
//  AXACSTokenParser.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXACSTokenParser.h"

//==============================================================================
@implementation AXACSTokenParser
//------------------------------------------------------------------------------
+ (RACSignal *)parseResponse:(NSString *)response
{
    NSString *ACSToken = [response substringWithRegularExpressionPattern:@"(?<=wrap_access_token=)(.*)(?=&)" options:NSRegularExpressionCaseInsensitive].URLDecoded;

    if (ACSToken.length > 0)
        return [RACSignal return:ACSToken];

    NSRange searchFromRange = [response rangeOfString:@"Detail:"];
    NSRange searchToRange = [response rangeOfString:@":TraceID"];
    NSString *reason = [response substringWithRange:NSMakeRange(searchFromRange.location + searchFromRange.length, searchToRange.location - searchFromRange.location - searchFromRange.length)];

    return [RACSignal error:
            [NSError errorWithDomain:@""
                                code:0
                            userInfo:@{
                                        NSLocalizedDescriptionKey : reason ?
                                            NSLocalizedString(reason, nil) :
                                            NSLocalizedString(@"There was an error issuing an ACS token.", nil)
                                     }]];
}
//------------------------------------------------------------------------------
+ (NSDate *)parseExpirationDate:(NSString *)token
{
    NSString *expirationDate = [token substringWithRegularExpressionPattern:@"ExpiresOn=([0-9]+)" options:NSRegularExpressionCaseInsensitive];

    return expirationDate.length > 0 ? [NSDate dateWithTimeIntervalSince1970:expirationDate.integerValue] : nil;
}
//------------------------------------------------------------------------------
@end
//==============================================================================
