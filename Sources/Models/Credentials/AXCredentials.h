//
//  AXCredentials.h
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

@interface AXCredentials : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *ADFSToken;
@property (nonatomic, copy) NSString *ACSToken;

@end
