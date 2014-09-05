//
//  AXCredentialsStore.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXCredentialsStore.h"

#import "AXADFSTokenParser.h"
#import "AXACSTokenParser.h"

//==============================================================================
@implementation AXCredentialsStore
//------------------------------------------------------------------------------
+ (BOOL)save:(AXCredentials *)credentials forService:(NSString *)service withUsername:(NSString *)username
{
    if (!credentials || 0 == service.length || 0 == username.length)
        return NO;

    NSString *serializedCredentials = [[NSKeyedArchiver archivedDataWithRootObject:credentials] base64EncodedStringWithOptions:0];

    return [SSKeychain setPassword:serializedCredentials forService:service account:username];
}
//------------------------------------------------------------------------------
+ (AXCredentials *)loadForService:(NSString *)service withUsername:(NSString *)username
{
    if (0 == service.length || 0 == username.length)
        return nil;

    NSString *serializedCredentials = [SSKeychain passwordForService:service account:username];
    AXCredentials *credentials = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData.alloc initWithBase64EncodedString:serializedCredentials options:0]];
    NSDate *date = NSDate.new;

    if (NSOrderedDescending == [date compare:[AXADFSTokenParser parseExpirationDate:credentials.ADFSToken]] ||
        NSOrderedDescending == [date compare:[AXACSTokenParser parseExpirationDate:credentials.ACSToken]])
    {
        [SSKeychain deletePasswordForService:service account:username];
        credentials = nil;
    }

    return credentials;
}
//------------------------------------------------------------------------------
@end
//==============================================================================
