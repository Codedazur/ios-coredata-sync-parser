//
//  CDANSUserDefaultsSyncScheduleManager.m
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import "CDANSUserDefaultsSyncScheduleManager.h"


@implementation CDANSUserDefaultsSyncScheduleManager
- (NSDate *)expirationDateForSyncId:(NSString *)syncId{
    NSDate *expirationDate = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *schedules = [defaults objectForKey:@"SynchSchedule"];
    NSArray *syncIds = [schedules valueForKey:@"uid"];
    NSInteger indexOfSync = [syncIds indexOfObject:syncId];
    if (indexOfSync != NSNotFound) {
        NSDictionary *entry = [schedules objectAtIndex:indexOfSync];
        expirationDate = [entry objectForKey:@"expiration"];
    }
    return expirationDate;
}
- (void)saveExpirationDate:(NSDate *)expirationDate ForSyncWithId:(NSString *)syncId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *scheduleDefaults = [defaults objectForKey:@"SynchSchedule"];
    NSMutableArray *schedules = [NSMutableArray new];
    if (scheduleDefaults) {
        schedules =[NSMutableArray arrayWithArray:scheduleDefaults];
    }
    
    NSArray *scheduleIds = [schedules valueForKey:@"uid"];
    NSUInteger index = [scheduleIds indexOfObject:syncId];
    NSDictionary *syncServiceSchedule = @{@"uid":syncId, @"expiration":expirationDate};
    if(index != NSNotFound){
        [schedules replaceObjectAtIndex:index withObject:syncServiceSchedule];
    }else{
        [schedules addObject:syncServiceSchedule];
    }
    
    [defaults setObject:schedules forKey:@"SynchSchedule"];
    [defaults synchronize];
}
@end
