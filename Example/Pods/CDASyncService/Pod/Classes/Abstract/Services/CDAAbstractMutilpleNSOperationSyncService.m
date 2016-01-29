//
//  CDAAbstractMutilpleNSOperationSyncService.m
//  Pods
//
//  Created by Tamara Bernad on 25/01/16.
//
//

#import "CDAAbstractMutilpleNSOperationSyncService.h"
#import "CDAAbstractNSOperationSyncService.h"

@interface CDAAbstractMutilpleNSOperationSyncService()<CDASyncServiceDelegate>
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic) BOOL concurrent;
@property (nonatomic) NSInteger totalServices;
@end
@implementation CDAAbstractMutilpleNSOperationSyncService
@synthesize uid=_uid, delegate = _delegate, running = _running;

- (instancetype)initWithUid:(NSString *)uid AndSyncServices:(NSArray<CDAAbstractNSOperationSyncService *> *)services ServicesConcurrent:(BOOL)concurrent{
    if(!(self = [self initWithUid:uid]))return self;
    
    self.concurrent = concurrent;
    self.totalServices = services.count;
    
    for (CDAAbstractNSOperationSyncService *service in services) {
        service.delegate = self;
        [self.queue addOperation:service];
        if(self.concurrent && [self.queue operationCount] > 1)
            [service addDependency:[[self.queue operations] objectAtIndex:[self.queue operationCount]-2]];
    }
    return self;
}
#pragma mark - lazy getters
- (NSOperationQueue *)queue{
    if(!_queue){
        _queue = [NSOperationQueue new];
    }
    return _queue;
}
#pragma mark - CDASyncServiceProtocol
- (instancetype)initWithUid:(NSString *)uid{
    if(!(self = [super init]))return self;
    _uid = uid;
    return self;
}
- (void)start{
//TODO check how to start a queue
}
- (double)progress{
    
    double totalProgress = 0;
    for (CDAAbstractNSOperationSyncService *service in [self.queue operations]) {
        totalProgress += [service progress];
    }
    totalProgress += self.totalServices - [self.queue operationCount];
    return totalProgress/(double)[self totalServices];
}
- (void)tearDown{
}
#pragma mark - CDASyncServiceDelegate
- (void)CDASyncServiceDidFinishWithSuccess:(id<CDASyncServiceProtocol>)syncService{
    [self.delegate CDASyncServiceDidFinishWithSuccess:syncService];
}
- (void)CDASyncService:(id<CDASyncServiceProtocol>)syncService DidFinishWithErrorId:(CDASyncError)syncErrorId{
    
    if (self.concurrent) {
        [self.queue cancelAllOperations];
        [self.delegate CDASyncService:self DidFinishWithErrorId:syncErrorId];
    }
}
@end
