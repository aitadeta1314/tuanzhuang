//
//  NetStatus.m
//  tuanzhuang
//
//  Created by Fenly on 2018/3/13.
//  Copyright © 2018年 red. All rights reserved.
//

#import "NetStatus.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation NetStatus

+ (NSString *)internetStatus {
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    NetworkStatus networkStatus = [reach currentReachabilityStatus];
    NSString *net = @"WIFI";
    switch (networkStatus) {
        case ReachableViaWiFi:
            net = @"WIFI";
            break;
        case ReachableViaWWAN:
            net = [NetStatus getNetType];
            break;
        case NotReachable:
            net = @"NONetwork";
            break;
        default:
            break;
    }
    return net;
}

+ (NSString *)getNetType {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = info.currentRadioAccessTechnology;
    NSString *netconnType = @"";
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
        netconnType = @"GPRS";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
        netconnType = @"2.75G EDGE";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
        netconnType = @"3.5G HSDPA";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
        netconnType = @"3.5G HSUPA";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
        netconnType = @"2G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
        netconnType = @"HRPD";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
        netconnType = @"4G";
    }
    return netconnType;
}

@end
