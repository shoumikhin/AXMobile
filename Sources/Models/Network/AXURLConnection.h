//
//  AXURLConnection.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXRequestBuilder.h"
#import "AXResponseParser.h"

@interface AXURLConnection : NSObject

- (RACSignal *)runWithRequestBuilder:(id <AXRequestBuilder>)builder andResponseParser:(Class)parser;

@end
