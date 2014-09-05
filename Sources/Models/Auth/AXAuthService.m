//
//  AXAuthService.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXAuthService.h"

#import "AXURLConnection.h"
#import "AXADFSRequestBuilder.h"
#import "AXADFSTokenParser.h"
#import "AXACSRequestBuilder.h"
#import "AXACSTokenParser.h"

//==============================================================================
#define BUS_HOST_SCHEME_HTTP "http"
#define BUS_HOST "servicebus.windows.net"
#define BUS_HOST_TEMPLATE "%@."BUS_HOST
#define BUS_URL_TEMPLATE_HTTP BUS_HOST_SCHEME_HTTP"://"BUS_HOST_TEMPLATE

#define ACS_HOST_SCHEME "https"
#define ACS_HOST "accesscontrol.windows.net"
#define ACS_HOST_SUBDOMAIN_TEMPLATE "%@-sb"
#define ACS_HOST_TEMPLATE ACS_HOST_SUBDOMAIN_TEMPLATE"."ACS_HOST
#define ACS_URL_TEMPLATE ACS_HOST_SCHEME"://"ACS_HOST_TEMPLATE
//==============================================================================
@interface AXAuthService ()

@property (nonatomic) AXCredentials *credentials;
@property (nonatomic) AXURLConnection *connection;
@property (nonatomic) NSURL *ADFSURL;
@property (nonatomic) NSURL *busURL;
@property (nonatomic) NSURL *ACSURL;

@end
//==============================================================================
@implementation AXAuthService
//------------------------------------------------------------------------------
- (instancetype)initWithService:(NSString *)namespace andADFSURL:(NSURL *)ADFSURL
{
    if (self = [super init])
    {
        _connection = AXURLConnection.new;
        _ADFSURL = ADFSURL;
        _busURL = [NSURL URLWithString:[NSString stringWithFormat:@BUS_URL_TEMPLATE_HTTP, namespace]];
        _ACSURL = [NSURL URLWithString:[NSString stringWithFormat:@ACS_URL_TEMPLATE, namespace]];
    }

    return self;
}
//------------------------------------------------------------------------------
- (RACSignal *)loginUser:(NSString *)username withPassword:(NSString *)password
{
    self.credentials = AXCredentials.new;

    @weakify(self);

    return [[[[[RACSignal.empty deliverOn:RACScheduler.scheduler]
                then:
                ^RACSignal *
                {
                    @strongify(self);

                    return [self fetchADFSTokenWithUser:username
                                            andPassword:password];
                }]
               then:
               ^RACSignal *
               {
                   @strongify(self);

                   return self.fetchACSToken;
               }]
              mapReplace:self.credentials]
             doError:
             ^(NSError *error)
             {
                 @strongify(self);

                 self.credentials = nil;
             }];
}
//------------------------------------------------------------------------------
- (RACSignal *)fetchADFSTokenWithUser:(NSString *)username andPassword:(NSString *)password
{
    AXADFSRequestBuilder *requestBuilder = AXADFSRequestBuilder.new;

    requestBuilder.ADFSURL = self.ADFSURL;
    requestBuilder.ACSURL = self.ACSURL;
    requestBuilder.username = username;
    requestBuilder.password = password;

    @weakify(self);

    return [[self.connection runWithRequestBuilder:requestBuilder andResponseParser:AXADFSTokenParser.class]
            doNext:
            ^(NSString *ADFSToken)
            {
                @strongify(self);

                self.credentials.ADFSToken = ADFSToken;
            }];
}
//------------------------------------------------------------------------------
- (RACSignal *)fetchACSToken
{
    AXACSRequestBuilder *requestBuilder = AXACSRequestBuilder.new;

    requestBuilder.ACSURL = self.ACSURL;
    requestBuilder.busURL = self.busURL;
    requestBuilder.ADFSToken = self.credentials.ADFSToken;

    @weakify(self);

    return [[self.connection runWithRequestBuilder:requestBuilder andResponseParser:AXACSTokenParser.class]
            doNext:
            ^(NSString *ACSToken)
            {
                @strongify(self);

                self.credentials.ACSToken = ACSToken;
            }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
