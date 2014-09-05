//
//  AXBusRequestBuilder.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXBusRequestBuilder.h"

//==============================================================================
#define HTTP_HEADER_SOAP_ACTION "SOAPAction"
//==============================================================================
#define SERVICE_BUS_REQUEST_CONTENT_TYPE "text/xml; charset=utf-8"
#define SERVICE_BUS_REQUEST_DATA_TEMPLATE \
"<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'>\
    <s:Header>\
        <PassthroughBinarySecurityToken>%@</PassthroughBinarySecurityToken>\
        <RelayAccessToken xmlns='http://schemas.microsoft.com/netservices/2009/05/servicebus/connect'>\
            <BinarySecurityToken p4:Id='uuid:%@' ValueType='http://schemas.xmlsoap.org/ws/2009/11/swt-token-profile-1.0' EncodingType='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary' xmlns:p4='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd' xmlns='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>%@</BinarySecurityToken>\
        </RelayAccessToken>\
    </s:Header>\
    <s:Body>\
        <%@ xmlns='%@'>\
            %@\
        </%@>\
    </s:Body>\
</s:Envelope>"
//==============================================================================
@implementation AXBusRequestBuilder
//------------------------------------------------------------------------------
- (BOOL)canBuildRequest
{
    return  self.busURL &&
            self.schemaURL &&
            self.contractBusPath.length > 0 &&
            self.contract.length > 0 &&
            self.action.length > 0;
}
//------------------------------------------------------------------------------
- (void)setCredentials:(AXCredentials *)credentials
{
    _credentials = credentials.copy;
    _credentials.ADFSToken = [[_credentials.ADFSToken dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    _credentials.ACSToken = [[_credentials.ACSToken dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}
//------------------------------------------------------------------------------
- (NSURLRequest *)buildRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.busURL URLByAppendingPathComponent:self.contractBusPath] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT_INTERVAL];

    [request setValue:@SERVICE_BUS_REQUEST_CONTENT_TYPE forHTTPHeaderField:@HTTP_HEADER_CONTENT_TYPE];
    [request setValue:[[self.schemaURL URLByAppendingPathComponent:self.contract] URLByAppendingPathComponent:self.action].absoluteString forHTTPHeaderField:@HTTP_HEADER_SOAP_ACTION];

    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString stringWithFormat:@SERVICE_BUS_REQUEST_DATA_TEMPLATE, self.credentials.ADFSToken ?: @"", NSUUID.makeUUID, self.credentials.ACSToken ?: @"", self.action, self.schemaURL, self.xmlArguments ?: @"", self.action] dataUsingEncoding:NSUTF8StringEncoding];

    return request;
}
//------------------------------------------------------------------------------
@end
//==============================================================================
