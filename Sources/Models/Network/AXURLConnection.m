//
//  AXURLConnection.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXURLConnection.h"

//==============================================================================
@interface AXURLConnection ()

@property (nonatomic) NSURLSession *session;

@end
//==============================================================================
@implementation AXURLConnection
//------------------------------------------------------------------------------
- (id)init
{
    if (self = [super init])
        _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
    
    return self;
}
//------------------------------------------------------------------------------
- (RACSignal *)runWithRequestBuilder:(id <AXRequestBuilder>)builder andResponseParser:(Class)parser
{
    if (builder.canBuildRequest)
        return [[self fetchResponseForRequest:builder.buildRequest]
                flattenMap:
                ^RACStream *(NSString *response)
                {
                    return [parser parseResponse:response];
                }];

    return [RACSignal error:
            [NSError errorWithDomain:@""
                                code:0
                            userInfo:@{
                                        NSLocalizedDescriptionKey :
                                            NSLocalizedString(@"Invalid service request.", nil)
                                     }]];
}
//------------------------------------------------------------------------------
- (RACSignal *)fetchResponseForRequest:(NSURLRequest *)request
{
    @weakify(self);
    
    return [[RACSignal createSignal:
             ^RACDisposable *(id<RACSubscriber> subscriber)
             {
                 @strongify(self);
                 
                 NSURLSessionDataTask *task;

                 [task = [self.session
                          dataTaskWithRequest:request
                          completionHandler:
                          ^(NSData *data, NSURLResponse *response, NSError *error)
                          {
                              if (error)
                                  [subscriber sendError:error];
                              else
                              {
                                  [subscriber sendNext:[NSString.alloc initWithData:data encoding:NSUTF8StringEncoding]];
                                  [subscriber sendCompleted];
                              }
                          }]
                  resume];
                 
                 return [RACDisposable disposableWithBlock:^{ [task cancel]; }];
             }]
            doError:^(NSError *error)
            {
                NSLog(@"%@", error);
            }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
