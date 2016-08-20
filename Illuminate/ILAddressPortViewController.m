//
//  ILAddressPortViewController.m
//  Illuminate
//
//  Created by Nolan Astrein on 8/19/16.
//  Copyright © 2016 Nolan Astrein. All rights reserved.
//

#import "ILAddressPortViewController.h"

static NSString *kIPAddressKey = @"_ip_address";
static NSString *kPortKey = @"_port";

@interface ILAddressPortViewController () <NSTextFieldDelegate>

@end

@implementation ILAddressPortViewController

- (instancetype)init
{
    if (self = [super init])
    {
        self.ipAddress = [self readIPAddressFromUserDefaults];
        self.port = [self readPortFromUserDefaults];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ipAddressTextField.placeholderString = @"IP Address";
    self.ipAddressTextField.delegate = self;
    
    self.portTextField.placeholderString = @"Port";
    self.portTextField.delegate = self;
}

- (void)viewDidAppear {
    self.ipAddress = [self readIPAddressFromUserDefaults];
    self.port = [self readPortFromUserDefaults];
    
    self.ipAddressTextField.stringValue = self.ipAddress;
    self.portTextField.stringValue = [NSString stringWithFormat:@"%d", self.port];
}

- (NSString *)readIPAddressFromUserDefaults
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kIPAddressKey] ?: @"";
}

- (void)writeIPAddressToUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setValue:self.ipAddress forKey:kIPAddressKey];
}

- (int)readPortFromUserDefaults
{
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:kPortKey] ?: 80;
}

- (void)writePortToUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.port forKey:kPortKey];
}


- (BOOL)isValidIPAddress
{
    NSString *ipAddressRegex = @"^(?=\\d+\\.\\d+\\.\\d+\\.\\d+$)(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\\.?){4}$";
    NSPredicate *ipAddressTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipAddressRegex];
    BOOL validIP = [ipAddressTest evaluateWithObject:self.ipAddressTextField.stringValue];
    return validIP;
}

- (BOOL)isValidPort
{
    BOOL validPort = YES;
    int portInt = [self.portTextField.stringValue intValue];
    if (portInt <= 0 || portInt > 65535) {
        validPort = NO;
    }

    return validPort;
}

#pragma mark NSTextFieldDelegate Methods

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(insertNewline:)) {
        if ([self isValidIPAddress] && [self isValidPort]) {
            self.ipAddress = self.ipAddressTextField.stringValue;
            self.port = [self.portTextField.stringValue intValue];
            [self writeIPAddressToUserDefaults];
            [self writePortToUserDefaults];
            [self.delegate didEnterIpAddress:self.ipAddress port:self.port];
        }
        return YES;
    }
    
    return NO;
}

@end
