//
//  AXAuthManager.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXAuthManager.h"

#import "AXBusService.h"
#import "AXAuthService.h"
#import "AXBusParserConfig.h"
#import "AXCredentialsStore.h"

//==============================================================================
#define USER_DEFAULTS_SERVICE "USER_DEFAULTS_SERVICE"
#define USER_DEFAULTS_USERNAME "USER_DEFAULTS_USERNAME"
#define ADFSURL "https://corp.sts.microsoft.com/adfs/services/trust/13/usernamemixed"
//==============================================================================
@interface AXAuthManager ()

@property (nonatomic) AXAuthState state;
@property (nonatomic) NSString *service;
@property (nonatomic) AXCredentials *credentials;
@property (nonatomic) NSArray *configurations;
@property (nonatomic) AXBusService *configService;
@property (nonatomic) AXAuthService *authService;

@end
//==============================================================================
@implementation AXAuthManager
//------------------------------------------------------------------------------
SYNTHESIZE_SINGLETON_FOR_CLASS(AXAuthManager)
//------------------------------------------------------------------------------
- (instancetype)init
{
    if (self = [super init])
    {
        NSString *service = [NSUserDefaults.standardUserDefaults objectForKey:@USER_DEFAULTS_SERVICE];
        NSString *username = [NSUserDefaults.standardUserDefaults objectForKey:@USER_DEFAULTS_USERNAME];

        self.service = service;
        self.credentials = [AXCredentialsStore loadForService:service withUsername:username];
    }

    return self;
}
//------------------------------------------------------------------------------
- (RACSignal *)loginAtService:(NSString *)service withUser:(NSString *)username andPassword:(NSString *)password
{@synchronized(self)
{
    if (AXAuthLoggedOut != self.state)
        return [RACSignal error:[NSError errorWithDomain:@"" code:0 userInfo:
                                 @{
                                    NSLocalizedDescriptionKey :
                                        NSLocalizedString(@"Cannot login if not logged out.", nil)
                                 }]];

    self.state = AXAuthLoggingIn;
    self.configService = [AXBusService.alloc initWithService:service
                                                    contract:@"ConfigurationServiceContract"
                                          andContractBusPath:@"Config"];

    @weakify(self);

    return [[[[[[self.configService callAction:@"GetConfigurationData"
                              withXMLArguments:nil]
                catch:
                ^RACSignal *(NSError *_)
                {
                    return [RACSignal return:nil];
                }]
               flattenMap:
               ^RACStream *(NSDictionary *response)
               {
                   @strongify(self);

                   self.configurations = [AXBusParserConfig parseServicesConfigurations:response];

                   NSString *ADFS = [AXBusParserConfig parseADFSURL:response];

                   self.authService = [AXAuthService.alloc initWithService:service andADFSURL:[NSURL URLWithString:ADFS ?: @ADFSURL]];

                   return [self.authService loginUser:username withPassword:password];
               }]
              doNext:
              ^(AXCredentials *credentials)
              {
                  @strongify(self);

                  self.service = service;
                  self.credentials = credentials;

                  if (self.saveLastLoginCredentials)
                  {
                      [AXCredentialsStore save:self.credentials forService:service withUsername:username];
                      [NSUserDefaults.standardUserDefaults setObject:service forKey:@USER_DEFAULTS_SERVICE];
                      [NSUserDefaults.standardUserDefaults setObject:username forKey:@USER_DEFAULTS_USERNAME];
                  }
                  else
                  {
                      [NSUserDefaults.standardUserDefaults removeObjectForKey:@USER_DEFAULTS_SERVICE];
                      [NSUserDefaults.standardUserDefaults removeObjectForKey:@USER_DEFAULTS_USERNAME];
                  }

                  [NSUserDefaults.standardUserDefaults synchronize];
              }]
             doError:
             ^(NSError *_)
             {
                 @strongify(self);

                 self.credentials = nil;
             }]
            deliverOn:RACScheduler.mainThreadScheduler];
}}
//------------------------------------------------------------------------------
- (void)setCredentials:(AXCredentials *)credentials
{
    _credentials = credentials;

    if (credentials)
        self.state = AXAuthLoggedIn;
    else
    {
        self.state = AXAuthLoggedOut;

        self.service = nil;
        self.configurations = nil;

        [NSUserDefaults.standardUserDefaults removeObjectForKey:@USER_DEFAULTS_SERVICE];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:@USER_DEFAULTS_USERNAME];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}
//------------------------------------------------------------------------------
- (RACSignal *)logout
{@synchronized(self)
{
    if (AXAuthLoggedIn != self.state)
        return [RACSignal error:[NSError errorWithDomain:@"" code:0 userInfo:
                                 @{
                                    NSLocalizedDescriptionKey :
                                       NSLocalizedString(@"Cannot logout if not logged in.", nil)
                                 }]];

    self.state = AXAuthLoggingOut;

    @weakify(self);

    return [RACSignal.empty doCompleted:
            ^
            {
                @strongify(self);

                self.credentials = nil;
            }];
}}
//------------------------------------------------------------------------------
@end
//==============================================================================
