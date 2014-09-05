//
//  AXBusServiceTests.m
//  AXBusServiceTests
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXBusService.h"

#import "AXBusParserConfig.h"

SpecBegin(AXBusService)

describe(NSStringFromClass(AXBusService.class),
^{
    it(@"should fetch configuration",
    ^AsyncBlock
    {
        AXBusService __block *configService =
        [AXBusService.alloc initWithService:@"axmobileex"
                                   contract:@"ConfigurationServiceContract"
                         andContractBusPath:@"Config"];

        [[configService callAction:@"GetConfigurationData"
                  withXMLArguments:nil]
         subscribeNext:
         ^(NSDictionary *response)
         {
             expect([AXBusParserConfig parseADFSURL:response])
                .equal(@"https://corp.sts.microsoft.com/adfs/services/trust/13/usernamemixed");

             expect([AXBusParserConfig parseSupportEmail:response])
                .equal(@"axsupp@microsoft.com");

             expect([AXBusParserConfig parseServicesConfigurations:response].count)
                .beGreaterThan(0);
         }
         error:
         ^(NSError *error)
         {
             expect(error).beFalsy();
             done();
         }
         completed:
         ^
         {
            configService = nil;  //retain it until everything is done
            done();
         }];
    });
});

SpecEnd
