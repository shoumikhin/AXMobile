//
//  MainViewController.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MainViewController.h"

#import "AXAuthManager.h"
#import "LoginViewController.h"

//==============================================================================
@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *viewTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *addExpenseButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;

@end
//==============================================================================
@implementation MainViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    RAC(self.addTimeButton, enabled) = [RACObserve(AXAuthManager.shared, state)
                                        deliverOn:RACScheduler.mainThreadScheduler];
    RAC(self.viewTimeButton, enabled) = [RACObserve(AXAuthManager.shared, state)
                                         deliverOn:RACScheduler.mainThreadScheduler];
    RAC(self.addExpenseButton, enabled) = [RACObserve(AXAuthManager.shared, state)
                                           deliverOn:RACScheduler.mainThreadScheduler];
    RAC(self.syncButton, enabled) = [RACObserve(AXAuthManager.shared, state)
                                     deliverOn:RACScheduler.mainThreadScheduler];

    @weakify(self);

    [[[RACObserve(AXAuthManager.shared, state)
       map:
       ^id (NSNumber *state)
       {
           return AXAuthLoggedOut == state.integerValue ?
                NSLocalizedString(@"LOGIN", nil) :
                NSLocalizedString(@"LOGOUT", nil);
       }]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:
     ^(NSString *text)
     {
         @strongify(self);

         [self.loginButton setTitle:text forState:UIControlStateNormal];
     }];

    self.loginButton.rac_command =
    [RACCommand.alloc
     initWithEnabled:[RACObserve(AXAuthManager.shared, state)
                      flattenMap:
                      ^RACStream *(NSNumber *state)
                      {
                          return [RACSignal return:@(AXAuthLoggedOut == state.integerValue ||
                                                      AXAuthLoggedIn == state.integerValue)];
                      }]
      signalBlock:
      ^RACSignal *(id sender)
      {
          return AXAuthLoggedOut == AXAuthManager.shared.state ?
                    [RACSignal createSignal:
                     ^RACDisposable *(id<RACSubscriber> subscriber)
                     {
                         LoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];

                         @strongify(self);

                         [self.navigationController pushViewController:loginViewController animated:YES];

                         [subscriber sendCompleted];

                         return nil;
                     }]
                    : [AXAuthManager.shared logout];
      }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
