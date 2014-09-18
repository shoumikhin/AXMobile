//
//  AXBusRequestBuilder.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXRequestBuilder.h"
#import "AXCredentials.h"

@interface AXBusRequestBuilder : NSObject <AXRequestBuilder>

@property (nonatomic) NSURL *busURL;
@property (nonatomic) NSURL *schemaURL;
@property (nonatomic, copy) NSString *contractBusPath;
@property (nonatomic, copy) NSString *contract;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *xmlArguments;
@property (nonatomic, copy) AXCredentials *credentials;

@end
