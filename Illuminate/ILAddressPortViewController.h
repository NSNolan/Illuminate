//
//  ILAddressPortViewController.h
//  Illuminate
//
//  Created by Nolan Astrein on 8/19/16.
//  Copyright © 2016 Nolan Astrein. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ILAddressPortViewControllerDelegate <NSObject>

- (void)didEnterIpAddress:(NSString *)newIPAddress port:(int)newPort;

@end

@interface ILAddressPortViewController : NSViewController

@property (weak) id<ILAddressPortViewControllerDelegate> delegate;
@property (weak) IBOutlet NSTextField *ipAddressTextField;
@property (weak) IBOutlet NSTextField *portTextField;
@property (copy) NSString *ipAddress;
@property (assign) int port;


@end
