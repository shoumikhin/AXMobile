//
//  AXACSRequestBuilder.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/24/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXRequestBuilder.h"

@interface AXACSRequestBuilder : NSObject <AXRequestBuilder>

@property (nonatomic) NSURL *ACSURL;
@property (nonatomic) NSURL *busURL;
@property (nonatomic, copy) NSString *ADFSToken;

@end
