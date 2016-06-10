//
//  ConnectionManager.h
//  FontShow
//
//  Created by 丁诚 on 16/6/10.
//  Copyright © 2016年 philipding. All rights reserved.
//

#import "HTTPServer.h"
#import "HTTPConnection.h"

@interface ConnectionManager : NSObject

+ (ConnectionManager *)sharedManager;
- (void)startWithDocURL:(NSString *)docURL port:(UInt16)port;
- (void)stop;
- (void)start;

@end