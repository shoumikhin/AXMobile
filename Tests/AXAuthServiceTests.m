//
//  AXAuthServiceTests.m
//  AXAuthServiceTests
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXAuthService.h"

#import "AXCredentials.h"

SpecBegin(AXAuthService)

describe(NSStringFromClass(AXAuthService.class),
^{
    it(@"should fetch credentials",
    ^AsyncBlock
    {
        AXAuthService __block *authService =
        [AXAuthService.alloc initWithService:@"axmobileex"
                                  andADFSURL:[NSURL URLWithString:@"https://corp.sts.microsoft.com/adfs/services/trust/13/usernamemixed"]];

        [[authService loginUser:@"username" withPassword:@"password"]
         subscribeNext:
         ^(AXCredentials *credentials)
         {
             expect(credentials.ADFSToken.length).beGreaterThan(0);
             expect(credentials.ACSToken.length).beGreaterThan(0);
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
             authService = nil;  //retain it until everything is done
             done();
         }];
    });
});

SpecEnd