//
//  CDAReachabilityManagerProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 21/01/16.
//
//

#import <Foundation/Foundation.h>
typedef enum
{
    CDAReachabilityStatusUnknown,
    CDAReachabilityStatusNotReachable,
    CDAReachabilityStatusReachableViaWWAN,
    CDAReachabilityStatusReachableViaWiFi
    
}CDAReachabilityStatus;

@protocol CDAReachabilityManagerDelegate;

@protocol CDAReachabilityManagerProtocol <NSObject>

@property (nonatomic, weak) id<CDAReachabilityManagerDelegate> delegate;

@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

@end

@protocol CDAReachabilityManagerDelegate <NSObject>

- (void)CDAReachabilityManager:(id<CDAReachabilityManagerProtocol>)manager didChangeReachabilityTo:(CDAReachabilityStatus)status;

@end