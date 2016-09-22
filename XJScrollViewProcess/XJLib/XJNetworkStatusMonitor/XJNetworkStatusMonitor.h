//
//  XJNetworkStatusMonitor.h
//  Vidol
//
//  Created by XJIMI on 2015/10/14.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface XJNetworkStatusMonitor : NSObject

+ (instancetype)monitorWithNetworkStatusChange:(void (^)(NetworkStatus netStatus))block;

@end
