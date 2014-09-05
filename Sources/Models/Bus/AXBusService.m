//
//  AXBusService.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXBusService.h"

#import "AXURLConnection.h"
#import "AXBusRequestBuilder.h"
#import "AXBusParser.h"

//==============================================================================
#define BUS_HOST_SCHEME "https"
#define BUS_HOST "servicebus.windows.net"
#define BUS_HOST_TEMPLATE "%@."BUS_HOST
#define BUS_URL_TEMPLATE BUS_HOST_SCHEME"://"BUS_HOST_TEMPLATE

#define SCHEMA_HOST_SCHEME "http"
#define SCHEMA_HOST "schemas.microsoft.com"
#define SCHEMA_PATH_DYNAMICS "/dynamics/mobile/2012/05/services"
#define SCHEMA_URL SCHEMA_HOST_SCHEME"://"SCHEMA_HOST""SCHEMA_PATH_DYNAMICS
//==============================================================================
@interface AXBusService ()

@property (nonatomic) AXURLConnection *connection;
@property (nonatomic) AXBusRequestBuilder *requestBuilder;

@end
//==============================================================================
@implementation AXBusService
//------------------------------------------------------------------------------
- (instancetype)initWithService:(NSString *)namespace contract:(NSString *)contract andContractBusPath:(NSString *)contractBusPath
{
    if (self = [super init])
    {
        _connection = AXURLConnection.new;
        _requestBuilder = AXBusRequestBuilder.new;
        _requestBuilder.busURL = [NSURL URLWithString:[NSString stringWithFormat:@BUS_URL_TEMPLATE, namespace]];
        _requestBuilder.schemaURL = [NSURL URLWithString:@SCHEMA_URL];
        _requestBuilder.contract = contract;
        _requestBuilder.contractBusPath = contractBusPath;
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)setCredentials:(AXCredentials *)credentials
{
    self.requestBuilder.credentials = credentials;
}
//------------------------------------------------------------------------------
- (AXCredentials *)credentials
{
    return self.requestBuilder.credentials;
}
//------------------------------------------------------------------------------
- (RACSignal *)callAction:(NSString *)action withXMLArguments:(NSString *)xmlArguments
{
    self.requestBuilder.action = action;
    self.requestBuilder.xmlArguments = xmlArguments;

    return [[RACSignal.empty deliverOn:RACScheduler.scheduler]
            then:
            ^RACSignal *
            {
                return [self.connection runWithRequestBuilder:self.requestBuilder andResponseParser:AXBusParser.class];
            }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
