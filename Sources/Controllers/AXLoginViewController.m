//
//  AXLoginViewController.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXLoginViewController.h"

#import "AXAuthManager.h"

//==============================================================================
#define USER_DEFAULTS_SERVICE "USER_DEFAULTS_SERVICE"
#define USER_DEFAULTS_USERNAME "USER_DEFAULTS_USERNAME"
//==============================================================================
@interface AXLoginViewController ()

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *serviceTextField;
@property (weak, nonatomic) IBOutlet UISwitch *saveCredentials;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end
//==============================================================================
@implementation AXLoginViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    RACChannelTerminal *shouldSaveCredentials = RACChannelTo(AXAuthManager.shared, shouldSaveCredentials);

    [shouldSaveCredentials subscribe:self.saveCredentials.rac_newOnChannel];
    [self.saveCredentials.rac_newOnChannel subscribe:shouldSaveCredentials];

    @weakify(self);

    self.loginButton.rac_command =
    [RACCommand.alloc
     initWithEnabled:
                     [RACSignal combineLatest:
                      @[
                        [RACSignal merge:@[self.usernameTextField.rac_textSignal, RACObserve(self.usernameTextField, text)]],
                        [RACSignal merge:@[self.passwordTextField.rac_textSignal, RACObserve(self.passwordTextField, text)]],
                        [RACSignal merge:@[self.serviceTextField.rac_textSignal, RACObserve(self.serviceTextField, text)]],
                        RACObserve(AXAuthManager.shared, isLoggedIn)
                      ]
                      reduce:
                      ^(NSString *username, NSString *password, NSString *service, NSNumber *isLoggedIn)
                      {
                          return @(
                                    username.length > 0 &&
                                    password.length > 0 &&
                                    service.length > 0 &&
                                    !isLoggedIn.boolValue
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

              if (AXAuthManager.shared.isLoggedIn)
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.usernameTextField.text = AXAuthManager.shared.username;
    self.serviceTextField.text = AXAuthManager.shared.service;

    if (self.usernameTextField.text.length > 0)
        [self.passwordTextField becomeFirstResponder];
    else
        [self.usernameTextField becomeFirstResponder];
}
//------------------------------------------------------------------------------
@end
//==============================================================================