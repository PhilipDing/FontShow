//
//  UIDevice+IPAddress.m
//  FontShow
//
//  Created by 丁诚 on 16/6/10.
//  Copyright © 2016年 philipding. All rights reserved.
//

#include <ifaddrs.h>
#include <arpa/inet.h>
#import <UIKit/UIKit.h>

@interface DeviceInfo : NSObject

+ (NSString *)ipAdress;

@end