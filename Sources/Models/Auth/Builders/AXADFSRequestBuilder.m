//
//  AXADFSRequestBuilder.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXADFSRequestBuilder.h"

//==============================================================================
#define ADFS_REQUEST_CONTENT_TYPE "application/soap+xml"
#define ADFS_REQUEST_DATA_TEMPLATE \
"<s:Envelope xmlns:a='http://www.w3.org/2005/08/addressing' xmlns:s='http://www.w3.org/2003/05/soap-envelope'>\
    <s:Header>\
        <a:Action s:mustUnderstand='1'>http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</a:Action>\
        <Security s:mustUnderstand='1' xmlns:u='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd' xmlns='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>\
            <UsernameToken u:Id='%@'>\
                <Username>%@</Username>\
                <Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>%@</Password>\
            </UsernameToken>\
        </Security>\
        <a:To s:mustUnderstand='1'>%@</a:To>\
    </s:Header>\
    <s:Body>\
        <trust:RequestSecurityToken xmlns:trust='http://docs.oasis-open.org/ws-sx/ws-trust/200512'>\
            <wsp:AppliesTo xmlns:wsp='http://schemas.xmlsoap.org/ws/2004/09/policy'>\
                <a:EndpointReference>\
                    <a:Address>%@</a:Address>\
                </a:EndpointReference>\
            </wsp:AppliesTo>\
            <trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType>\
            <trust:KeyType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Bearer</trust:KeyType>\
        </trust:RequestSecurityToken>\
    </s:Body>\
</s:Envelope>"
//==============================================================================
@implementation AXADFSRequestBuilder
//------------------------------------------------------------------------------
- (BOOL)canBuildRequest
{
    return  self.ADFSURL &&
            self.ACSURL &&
            self.username.length > 0 &&
            self.password.length;
}
//------------------------------------------------------------------------------
- (NSURLRequest *)buildRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.ADFSURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT_INTERVAL];

    [request setValue:@ADFS_REQUEST_CONTENT_TYPE forHTTPHeaderField:@HTTP_HEADER_CONTENT_TYPE];

    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString stringWithFormat:@ADFS_REQUEST_DATA_TEMPLATE, NSUUID.makeUUID, self.username, self.password, self.ADFSURL, self.ACSURL] dataUsingEncoding:NSUTF8StringEncoding];

    return request;
}
//------------------------------------------------------------------------------
@end
//==============================================================================
