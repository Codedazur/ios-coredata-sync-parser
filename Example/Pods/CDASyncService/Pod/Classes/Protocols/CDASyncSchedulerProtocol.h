//
//  CDASyncSchedulerProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncModel.h"
#import "CDASyncScheduleMangerProtocol.h"

@protocol CDASyncSchedulerDelegate;

@protocol CDASyncSchedulerProtocol <NSObject>
@property (nonatomic, weak) id<CDASyncSchedulerDelegate> delegate;
- (instancetype)initWithSyncModels:(NSArray<CDASyncModel> *)syncs AndSyncScheduleManager:(id<CDASyncScheduleMangerProtocol>)manager;
- (void)schedule;
- (void)forceAllSyncs;
- (void)finishedSyncServiceWithId:(NSString *)syncServiceUid;
- (void)forceSyncWithId:(NSString *)syncId;
@end

@protocol CDASyncSchedulerDelegate <NSObject>

- (void) CDASyncScheduler:(id<CDASyncSchedulerProtocol>)scheduler wantsToExecuteServicesWithIds:(NSArray *)serviceIds;

@end