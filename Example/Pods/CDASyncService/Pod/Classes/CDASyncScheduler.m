//
//  CDASyncScheduler.m
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import "CDASyncScheduler.h"
#import "CDASyncScheduleMangerProtocol.h"

@interface CDASyncScheduler()
@property (nonatomic, copy) NSArray<CDASyncModel> *syncModels;
@property (nonatomic, copy) id<CDASyncScheduleMangerProtocol>manager;
@end
@implementation CDASyncScheduler
@synthesize delegate = _delegate;

#pragma mark - initializers
- (instancetype)initWithSyncModels:(NSArray<CDASyncModel> *)syncs AndSyncScheduleManager:(id<CDASyncScheduleMangerProtocol>)manager{
    if(!(self = [super init]))return nil;
    self.syncModels = syncs;
    self.manager = manager;
    return self;
}

#pragma mark - CDASyncSchedulerProtocol
- (void)schedule{
    NSDate *today = [NSDate new];
    NSDate *expirationDate;
    NSArray *syncIds = [self syncIds];
    NSMutableArray *servicesToSchedule = [NSMutableArray new];
    for (NSString *syncId in syncIds) {
        expirationDate = [self.manager expirationDateForSyncId:syncId];
        
        if (expirationDate == nil || [expirationDate compare:today] == NSOrderedAscending){
            [servicesToSchedule addObject:syncId];
        }
    }
    [self.delegate CDASyncScheduler:self wantsToExecuteServicesWithIds:[NSArray arrayWithArray:servicesToSchedule]];
}
- (void)finishedSyncServiceWithId:(NSString *)syncServiceUid{
    NSDate *expiration = [[NSDate new]dateByAddingTimeInterval:[self timeintervalForSyncWithId:syncServiceUid]];
    [self.manager saveExpirationDate:expiration ForSyncWithId:syncServiceUid];
}
- (void)forceAllSyncs{
    [self.delegate CDASyncScheduler:self wantsToExecuteServicesWithIds:[self syncIds]];
}
- (void)forceSyncWithId:(NSString *)syncId{
    [self.delegate CDASyncScheduler:self wantsToExecuteServicesWithIds:@[syncId]];
}

#pragma mark - helpers
- (NSArray *)syncIds{
    return [self.syncModels valueForKey:@"uid"];
}
- (NSTimeInterval)timeintervalForSyncWithId:(NSString *)syncId{
    id<CDASyncModel> model = [[self.syncModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@",syncId]] firstObject];
    return model.timeInterval;
}
@end
