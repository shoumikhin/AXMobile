//
//  AXACSRequestBuilder.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXACSRequestBuilder.h"

//==============================================================================
#define ACS_REQUEST_URL_PATH_TOKEN "WRAPv0.9"
#define ACS_REQUEST_CONTENT_TYPE "application/x-www-form-urlencoded"
#define ACS_REQUEST_DATA_TEMPLATE "wrap_scope=%@%%2F&wrap_assertion=%@&wrap_assertion_format=SAML"
//==============================================================================
@implementation AXACSRequestBuilder
//------------------------------------------------------------------------------
- (BOOL)canBuildRequest
{
    return  self.ACSURL &&
            self.busURL &&
            self.ADFSToken.length > 0;
}
//------------------------------------------------------------------------------
- (NSURLRequest *)buildRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.ACSURL URLByAppendingPathComponent:@ACS_REQUEST_URL_PATH_TOKEN] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT_INTERVAL];

    [request setValue:@ACS_REQUEST_CONTENT_TYPE forHTTPHeaderField:@HTTP_HEADER_CONTENT_TYPE];

    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString stringWithFormat:@ACS_REQUEST_DATA_TEMPLATE, self.busURL, self.ADFSToken.URLEncoded] dataUsingEncoding:NSUTF8StringEncoding];

    return request;
}
//------------------------------------------------------------------------------
@end
//==============================================================================
