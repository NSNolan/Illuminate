//
//  AppDelegate.m
//  Illuminate
//
//  Created by Nolan Astrein on 4/22/15.
//  Copyright (c) 2015 Nolan Astrein. All rights reserved.
//

#import "AppDelegate.h"

static const NSString *on = @"\u25CF";
static const NSString *off = @"\u25CB";
static const NSString *fail = @"\u2297";

@interface AppDelegate () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSStatusItem *statusItem;
    NSMutableData *responseData;
}

@end

@implementation AppDelegate

#pragma mark - Public

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setTarget:self];
    [statusItem setAction:@selector(switch:)];
    
    [[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(_getState:) userInfo:nil repeats:YES] fire];
}

- (void)switch:(id)sender
{
    if ([statusItem.title isEqualToString:(NSString *)off])
    {
        NSLog(@"Switching on");
        [self _connectionForRequestString:@"http://192.168.1.42:4242/switch?direction=on"];
    }
    else if ([statusItem.title isEqualToString:(NSString *)on])
    {
        NSLog(@"Switching off");
        [self _connectionForRequestString:@"http://192.168.1.42:4242/switch?direction=off"];
    }
}

#pragma mark - Private

- (void)_getState:(NSTimer *)timer
{
    [self _connectionForRequestString:@"http://192.168.1.42:4242/state"];
}

- (NSURLConnection *)_connectionForRequestString:(NSString *)requestString
{
    // TODO: Race Condition
    // responseData could be reset while an
    // old request is receiving data
    responseData = [NSMutableData data];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:30.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection)
    {
        responseData = nil;
        statusItem.title = (NSString *)fail;
    }
    
    return connection;
}

#pragma mark - NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([responseData length] > 0)
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:kNilOptions
                                                                   error:nil];
        if (responseData)
        {
            if (response[@"state"])
            {
                if ([response[@"state"] isEqualToString:@"on"])
                {
                    statusItem.title = (NSString *)on;
                }
                else if ([response[@"state"] isEqualToString:@"off"])
                {
                    statusItem.title = (NSString *)off;
                }
                else
                {
                    statusItem.title = (NSString *)fail;
                }
            }
            else if (response[@"switch"])
            {
                if ([response[@"switch"] isEqualToString:@"on"])
                {
                    statusItem.title = (NSString *)on;
                }
                else if ([response[@"switch"] isEqualToString:@"off"])
                {
                    statusItem.title = (NSString *)off;
                }
                else
                {
                    statusItem.title = (NSString *)fail;
                }
            }
        }
        else
        {
            statusItem.title = (NSString *)fail;
        }
    }
    else
    {
        statusItem.title = (NSString *)fail;
    }
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    statusItem.title = (NSString *)fail;    
}

@end
