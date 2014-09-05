//
//  AXRequestBuilder.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

@protocol AXRequestBuilder <NSObject>

- (BOOL)canBuildRequest;
- (NSURLRequest *)buildRequest;

@end
