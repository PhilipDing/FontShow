//
//  ConnectionManager.m
//  FontShow
//
//  Created by 丁诚 on 16/6/10.
//  Copyright © 2016年 philipding. All rights reserved.
//


#import "MyHTTPConnection.h"
#import "ConnectionManager.h"

@interface ConnectionManager ()

@property (nonatomic, strong) HTTPServer *httpServer;

@end

@implementation ConnectionManager

+ (ConnectionManager *)sharedManager {
  static ConnectionManager *manager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[ConnectionManager alloc] init];
    manager.httpServer = [[HTTPServer alloc] init];
  });
  
  return manager;
}

- (void)startWithDocURL:(NSString *)docURL port:(UInt16)port {
  [self.httpServer setDocumentRoot:docURL];
  [self.httpServer setPort:port];
  [self.httpServer setConnectionClass:[MyHTTPConnection class]];
  [self start];
}

- (void)stop {
  [self.httpServer stop];
}

- (void)start {
  NSError *error = nil;
  if(![self.httpServer start:&error]) {
    NSLog(@"Error starting HTTP Server: %@", error);
  }
}

@end
