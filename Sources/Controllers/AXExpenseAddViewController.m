//
//  AXExpenseAddViewController.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AXExpenseAddViewController.h"

#import "AXAuthManager.h"
#import "AXBusService.h"

//==============================================================================
@interface AXExpenseAddViewController ()

@property (nonatomic) AXBusService *expenseService;

@end
//==============================================================================
@implementation AXExpenseAddViewController
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.expenseService = [AXBusService.alloc initWithService:AXAuthManager.shared.service
                                                     contract:@"ExpenseServiceContract"
                                           andContractBusPath:@"Expense"];
    self.expenseService.credentials = AXAuthManager.shared.credentials;

    [[[self.expenseService callAction:@"GetCategories"
                    withXMLArguments:nil]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:
     ^(NSDictionary *response)
     {
         //parse and display the response
     }
     error:^(NSError *error)
     {
         [TSMessage showNotificationWithTitle:NSLocalizedString(@"Error", nil)
                                     subtitle:error.friendlyLocalizedDescription
                                         type:TSMessageNotificationTypeError];
     }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================
