//
//  CDASyncManagerProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncModel.h"
#import "CDASyncScheduleMangerProtocol.h"
#import "CDAReachabilityManagerProtocol.h"

@protocol CDASyncManagerProtocol <NSObject>
- (instancetype)initWithSyncModels:(NSArray<CDASyncModel> *)syncs
                    SchedulerClass:(Class<CDASyncScheduleMangerProtocol>)schedulerClass
                 ReachabilityClass:(Class<CDAReachabilityManagerProtocol>)reachabilityClass;
- (void)sync;
- (void)syncForce;
@end
