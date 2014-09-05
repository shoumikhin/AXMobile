//
//  AXTokenParser.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXResponseParser.h"

@protocol AXTokenParser <AXResponseParser>

+ (NSDate *)parseExpirationDate:(NSString *)token;

@end
