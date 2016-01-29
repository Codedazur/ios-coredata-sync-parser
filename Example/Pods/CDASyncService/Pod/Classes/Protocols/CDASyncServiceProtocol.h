//
//  CDASyncServiceProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncErrors.h"

@protocol CDASyncServiceDelegate;
@protocol CDASyncServiceProtocol <NSObject>

@property (nonatomic, weak) id<CDASyncServiceDelegate> delegate;
@property (nonatomic, getter = isRunning, readonly) BOOL running;
@property (nonatomic, strong, readonly) NSString *uid;
- (instancetype) initWithUid:(NSString *)uid;
- (void)start;
- (void)tearDown;
- (double)progress;
@end

@protocol CDASyncServiceDelegate <NSObject>

- (void) CDASyncServiceDidFinishWithSuccess:(id<CDASyncServiceProtocol>)syncService;
- (void) CDASyncService:(id<CDASyncServiceProtocol>)syncService DidFinishWithErrorId:(CDASyncError)syncErrorId;
@end