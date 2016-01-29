//
//  CDASyncManager.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncManagerProtocol.h"

@interface CDASyncManager : NSObject<CDASyncManagerProtocol>
- (instancetype)initWithSyncModels:(NSArray<CDASyncModel> *)syncs
                    SchedulerClass:(Class<CDASyncScheduleMangerProtocol>)schedulerClass
                 ReachabilityClass:(Class<CDAReachabilityManagerProtocol>)reachabilityClass;
@end
