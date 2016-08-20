//
//  ILAppDelegate.m
//  Illuminate
//
//  Created by Nolan Astrein on 4/22/15.
//  Copyright (c) 2015 Nolan Astrein. All rights reserved.
//

#import "ILAppDelegate.h"
#import "ILAddressPortViewController.h"

static const NSString *on = @"\u25CF";
static const NSString *off = @"\u25CB";
static const NSString *fail = @"X";

@interface ILAppDelegate () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, ILAddressPortViewControllerDelegate>

@property (strong) NSMutableData *responseData;
@property (strong) NSStatusItem *statusItem;
@property (strong) NSPopover *ipAddressPopover;
@property (strong) NSString *ipAddress;
@property (assign) int port;

@end

@implementation ILAppDelegate

#pragma mark - Public

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title = (NSString *)fail;
    [self.statusItem setTarget:self];
    [self.statusItem setAction:@selector(switch:)];
    
    self.ipAddressPopover = [[NSPopover alloc] init];
    
    ILAddressPortViewController *addressPortViewController = [[ILAddressPortViewController alloc] init];
    addressPortViewController.delegate = self;
    self.ipAddressPopover.contentViewController = addressPortViewController;
    
    self.ipAddress = addressPortViewController.ipAddress;
    self.port = addressPortViewController.port;
    
    [[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(_getState:) userInfo:nil repeats:YES] fire];
}

- (void)switch:(id)sender
{
    NSEvent *event = [NSApp currentEvent];
    if ([event modifierFlags] & NSControlKeyMask) {
        if (self.ipAddressPopover.shown) {
            [self.ipAddressPopover close];
        }
        else {
            [self.ipAddressPopover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSMinYEdge];
        }
        return;
    }
    
    NSString *switchRequestString = [NSString stringWithFormat:@"http://%@:%d/switch?direction=", self.ipAddress, self.port];
    
    if ([self.statusItem.title isEqualToString:(NSString *)off])
    {
        NSLog(@"Switching on");
        [self _connectionForRequestString:[NSString stringWithFormat:@"%@on", switchRequestString]];
    }
    else if ([self.statusItem.title isEqualToString:(NSString *)on])
    {
        NSLog(@"Switching off");
        [self _connectionForRequestString:[NSString stringWithFormat:@"%@off", switchRequestString]];
    }
}

#pragma mark - Private

- (void)_getState:(NSTimer *)timer
{
    NSString *stateRequestString = [NSString stringWithFormat:@"http://%@:%d/state", self.ipAddress, self.port];
    [self _connectionForRequestString:stateRequestString];
}

- (NSURLConnection *)_connectionForRequestString:(NSString *)requestString
{
    // TODO: Race Condition
    // responseData could be reset while an
    // old request is receiving data
    self.responseData = [NSMutableData data];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:30.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
    {
        self.responseData = nil;
        self.statusItem.title = (NSString *)fail;
    }
    
    return connection;
}

#pragma mark - NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.responseData length] > 0)
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                 options:kNilOptions
                                                                   error:nil];
        if (response)
        {
            if (response[@"state"])
            {
                if ([response[@"state"] isEqualToString:@"on"])
                {
                    self.statusItem.title = (NSString *)on;
                }
                else if ([response[@"state"] isEqualToString:@"off"])
                {
                    self.statusItem.title = (NSString *)off;
                }
                else
                {
                    self.statusItem.title = (NSString *)fail;
                }
            }
            else if (response[@"switch"])
            {
                if ([response[@"switch"] isEqualToString:@"on"])
                {
                    self.statusItem.title = (NSString *)on;
                }
                else if ([response[@"switch"] isEqualToString:@"off"])
                {
                    self.statusItem.title = (NSString *)off;
                }
                else
                {
                    self.statusItem.title = (NSString *)fail;
                }
            }
        }
        else
        {
            self.statusItem.title = (NSString *)fail;
        }
    }
    else
    {
        self.statusItem.title = (NSString *)fail;
    }
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.statusItem.title = (NSString *)fail;
}

#pragma mark - ILAddressPortViewControllerDelegate Methods

- (void)didEnterIpAddress:(NSString *)newIPAddress port:(int)newPort
{
    [self.ipAddressPopover close];
    
    self.ipAddress = newIPAddress;
    self.port = newPort;
    
    [self _getState:nil];
}

@end
