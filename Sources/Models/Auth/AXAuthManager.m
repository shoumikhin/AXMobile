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
#define USER_DEFAULTS_SHOULD_SAVE_CREDENTIALS "USER_DEFAULTS_SHOULD_SAVE_CREDENTIALS"
#define ADFSURL "https://corp.sts.microsoft.com/adfs/services/trust/13/usernamemixed"
//==============================================================================
@interface AXAuthManager ()

@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic) NSString *service;
@property (nonatomic) NSString *username;
@property (nonatomic) AXCredentials *credentials;
@property (nonatomic) NSArray *configurations;
@property (nonatomic) AXBusService *configService;
@property (nonatomic) AXAuthService *authService;

@end
//==============================================================================
@implementation AXAuthManager SYNTHESIZE_SINGLETON_FOR_CLASS(AXAuthManager)
//------------------------------------------------------------------------------
- (instancetype)init
{
    if (self = [super init])
    {
        [self initIsLoggedIn];
        [self initService];
        [self initUsername];
        [self initShouldSaveCredentials];
        [self initCredentials];
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)initIsLoggedIn
{
    RAC(self, isLoggedIn) =
    [RACSignal combineLatest:
     @[
        RACObserve(self, service),
        RACObserve(self, username),
        RACObserve(self, credentials)
      ]
     reduce:
     ^(NSString *service, NSString *username, AXCredentials *credentials)
     {
         return @(
                    service.length > 0 &&
                    username.length > 0 &&
                    credentials
                );
     }];
}
//------------------------------------------------------------------------------
- (void)initService
{
    RACChannelTerminal *defaultService = [NSUserDefaults.standardUserDefaults rac_channelTerminalForKey:@USER_DEFAULTS_SERVICE];
    RACChannelTerminal *service = RACChannelTo(self, service, @"");

    @weakify(self);

    [defaultService subscribe:service];
    [[[service skip:1]
      map:
      ^ id (NSString *service)
      {
          @strongify(self);

          return self.shouldSaveCredentials ? service : nil;
      }]
     subscribe:defaultService];
}
//------------------------------------------------------------------------------
- (void)initUsername
{
    RACChannelTerminal *defaultUsername = [NSUserDefaults.standardUserDefaults rac_channelTerminalForKey:@USER_DEFAULTS_USERNAME];
    RACChannelTerminal *username = RACChannelTo(self, username, @"");

    @weakify(self);

    [defaultUsername subscribe:username];
    [[[username skip:1]
      map:
      ^ id (NSString *username)
      {
          @strongify(self);

          return self.shouldSaveCredentials ? username : nil;
      }]
     subscribe:defaultUsername];
}
//------------------------------------------------------------------------------
- (void)initShouldSaveCredentials
{
    RACChannelTerminal *saveCredentials = RACChannelTo(self, shouldSaveCredentials, @NO);
    RACChannelTerminal *defaultSaveCredentials = [NSUserDefaults.standardUserDefaults rac_channelTerminalForKey:@USER_DEFAULTS_SHOULD_SAVE_CREDENTIALS];

    [defaultSaveCredentials subscribe:saveCredentials];
    [[saveCredentials skip:1] subscribe:defaultSaveCredentials];
}
//------------------------------------------------------------------------------
- (void)initCredentials
{
    self.credentials = [AXCredentialsStore loadForService:self.service withUsername:self.username];

    @weakify(self);

    [[RACObserve(self, credentials) skip:1]
     subscribeNext:
     ^(AXCredentials *credentials)
     {
         @strongify(self);

         if (credentials && self.shouldSaveCredentials)
             [AXCredentialsStore save:credentials forService:self.service withUsername:self.username];
         else
             [AXCredentialsStore deleteCredentialsForService:self.service withUsername:self.username];
     }];
}
//------------------------------------------------------------------------------
- (RACSignal *)loginAtService:(NSString *)service withUser:(NSString *)username andPassword:(NSString *)password
{@synchronized(self)
{
    if (self.isLoggedIn)
        return [RACSignal error:[NSError errorWithDomain:@"" code:0 userInfo:
                                 @{
                                    NSLocalizedDescriptionKey :
                                        NSLocalizedString(@"Cannot login if not logged out.", nil)
                                 }]];

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
                   self.authService = [AXAuthService.alloc initWithService:service
                                                                andADFSURL:[NSURL URLWithString:
                                                                            [AXBusParserConfig parseADFSURL:response] ?:
                                                                            @ADFSURL]];

                   return [self.authService loginUser:username withPassword:password];
               }]
              doNext:
              ^(AXCredentials *credentials)
              {
                  @strongify(self);

                  self.service = service;
                  self.username = username;
                  self.credentials = credentials;
              }]
             doError:
             ^(NSError *_)
             {
                 @strongify(self);

                 [self cleanup];
             }]
            deliverOn:RACScheduler.mainThreadScheduler];
}}
//------------------------------------------------------------------------------
- (void)cleanup
{
    self.credentials = nil;
    self.configurations = nil;

    if (!self.shouldSaveCredentials)
        self.service = self.username = nil;
}
//------------------------------------------------------------------------------
- (RACSignal *)logout
{@synchronized(self)
{
    if (!self.isLoggedIn)
        return [RACSignal error:[NSError errorWithDomain:@"" code:0 userInfo:
                                 @{
                                    NSLocalizedDescriptionKey :
                                       NSLocalizedString(@"Cannot logout if not logged in.", nil)
                                 }]];

    [self cleanup];

    return RACSignal.empty;
}}
//------------------------------------------------------------------------------
@end
//==============================================================================
