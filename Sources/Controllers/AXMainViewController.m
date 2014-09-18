//
//  AXMainViewController.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXMainViewController.h"

#import "AXAuthManager.h"
#import "AXLoginViewController.h"

//==============================================================================
@interface AXMainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *viewTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *addExpenseButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;

@end
//==============================================================================
@implementation AXMainViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    RAC(self.addTimeButton, enabled) = [RACObserve(AXAuthManager.shared, isLoggedIn)
                                        deliverOn:RACScheduler.mainThreadScheduler];
    RAC(self.viewTimeButton, enabled) = [RACObserve(AXAuthManager.shared, isLoggedIn)
                                         deliverOn:RACScheduler.mainThreadScheduler];
    RAC(self.addExpenseButton, enabled) = [RACObserve(AXAuthManager.shared, isLoggedIn)
                                           deliverOn:RACScheduler.mainThreadScheduler];
    RAC(self.syncButton, enabled) = [RACObserve(AXAuthManager.shared, isLoggedIn)
                                     deliverOn:RACScheduler.mainThreadScheduler];

    @weakify(self);

    [[[RACObserve(AXAuthManager.shared, isLoggedIn)
       map:
       ^id (NSNumber *isLoggedIn)
       {
           return isLoggedIn.boolValue ?
                NSLocalizedString(@"LOGOUT", nil) :
                NSLocalizedString(@"LOGIN", nil);
       }]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:
     ^(NSString *text)
     {
         @strongify(self);

         [self.loginButton setTitle:text forState:UIControlStateNormal];
     }];

    self.loginButton.rac_command =
    [RACCommand.alloc initWithSignalBlock:
     ^RACSignal *(id sender)
     {
         if (AXAuthManager.shared.isLoggedIn)
             return [AXAuthManager.shared logout];

         return [RACSignal createSignal:
                 ^RACDisposable *(id<RACSubscriber> subscriber)
                 {
                     AXLoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];

                     @strongify(self);

                     [self.navigationController pushViewController:loginViewController animated:YES];

                     [subscriber sendCompleted];

                     return nil;
                 }];
     }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
