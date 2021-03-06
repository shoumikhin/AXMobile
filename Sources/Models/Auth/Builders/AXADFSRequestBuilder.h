//
//  AXADFSRequestBuilder.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXRequestBuilder.h"

@interface AXADFSRequestBuilder : NSObject <AXRequestBuilder>

@property (nonatomic) NSURL *ADFSURL;
@property (nonatomic) NSURL *ACSURL;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end
