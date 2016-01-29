//
//  CDASyncExecutorProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncErrors.h"
#import "CDASyncModel.h"

@protocol CDASyncExecutorDelegate;

@protocol CDASyncExecutorProtocol <NSObject>
@property(nonatomic, weak) id<CDASyncExecutorDelegate> delegate;
- (instancetype)initWithSyncModels:(NSArray<CDASyncModel> *)syncs;
- (void)runSyncWithIds:(NSArray *)ids;
- (double)progress;
@end

@protocol CDASyncExecutorDelegate <NSObject>

- (void) CDASyncExecutor:(id<CDASyncExecutorProtocol>)executor failedSyncWithId:(NSString *)serviceId AndErrorId:(CDASyncError)errorId;
- (void) CDASyncExecutor:(id<CDASyncExecutorProtocol>)executor succeededSyncWithId:(NSString *)serviceId;
- (void) CDASyncExecutorDidFinishAllSyncServices:(id<CDASyncExecutorProtocol>)executor;
@end