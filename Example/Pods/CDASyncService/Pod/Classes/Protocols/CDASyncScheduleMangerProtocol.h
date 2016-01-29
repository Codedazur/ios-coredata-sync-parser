//
//  CDASyncScheduleMangerProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDASyncScheduleMangerProtocol <NSObject>
- (NSDate *)expirationDateForSyncId:(NSString *)syncId;
- (void)saveExpirationDate:(NSDate *)expirationDate ForSyncWithId:(NSString *)syncId;
@end
