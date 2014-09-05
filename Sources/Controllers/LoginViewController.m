//
//  LoginViewController.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "LoginViewController.h"

#import "AXAuthManager.h"

//==============================================================================
#define USER_DEFAULTS_SERVICE "USER_DEFAULTS_SERVICE"
#define USER_DEFAULTS_USERNAME "USER_DEFAULTS_USERNAME"
//==============================================================================
@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *serviceTextField;
@property (weak, nonatomic) IBOutlet UISwitch *saveCredentials;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end
//==============================================================================
@implementation LoginViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;

    AXAuthManager.shared.saveLastLoginCredentials = self.saveCredentials.isOn;
    RAC(AXAuthManager.shared, saveLastLoginCredentials) = self.saveCredentials.rac_newOnChannel;

    @weakify(self);

    self.loginButton.rac_command =
    [RACCommand.alloc
     initWithEnabled:
                     [RACSignal combineLatest:
                      @[
                        self.usernameTextField.rac_textSignal,
                        self.passwordTextField.rac_textSignal,
                        self.serviceTextField.rac_textSignal,
                        RACObserve(AXAuthManager.shared, state)
                      ]
                      reduce:
                      ^(NSString *username, NSString *password, NSString *service, NSNumber *state)
                      {
                          return @(
                                    username.length > 0 &&
                                    password.length > 0 &&
                                    service.length > 0 &&
                                    AXAuthLoggedIn != state.integerValue
                                 );
                      }]
     signalBlock:
     ^RACSignal *(id sender)
     {
         @strongify(self);

         return [AXAuthManager.shared loginAtService:self.serviceTextField.text
                                            withUser:self.usernameTextField.text
                                         andPassword:self.passwordTextField.text];
     }];

    [self.loginButton.rac_command.executionSignals subscribeNext:
     ^(RACSignal *loginSignal)
     {
         [[loginSignal deliverOn:RACScheduler.mainThreadScheduler]
          subscribeCompleted:
          ^{
              @strongify(self);

              if (AXAuthLoggedIn == AXAuthManager.shared.state)
                  [self.navigationController popViewControllerAnimated:YES];
          }];
     }];

    [self.loginButton.rac_command.errors subscribeNext:
     ^(NSError *error)
     {
         [TSMessage showNotificationWithTitle:NSLocalizedString(@"Error", nil)
                                     subtitle:error.friendlyLocalizedDescription
                                         type:TSMessageNotificationTypeError];
     }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================