//
//  AXCredentials.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXCredentials.h"

//==============================================================================
@implementation AXCredentials
//------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        self.ADFSToken = [decoder decodeObjectForKey:@"ADFSToken"];
        self.ACSToken = [decoder decodeObjectForKey:@"ACSToken"];
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.ADFSToken forKey:@"ADFSToken"];
    [encoder encodeObject:self.ACSToken forKey:@"ACSToken"];
}
//------------------------------------------------------------------------------
- (id)copyWithZone:(NSZone *)zone
{
    AXCredentials *credentials = [self.class allocWithZone:zone];

    credentials->_ADFSToken = [_ADFSToken copyWithZone:zone];
    credentials->_ACSToken = [_ACSToken copyWithZone:zone];

    return credentials;
}
//------------------------------------------------------------------------------
@end
//==============================================================================
