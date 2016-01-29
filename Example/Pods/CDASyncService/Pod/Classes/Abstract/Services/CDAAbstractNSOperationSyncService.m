//
//  CDAAbstractNSOperationSyncService.m
//  Pods
//
//  Created by Tamara Bernad on 25/01/16.
//
//

#import "CDAAbstractNSOperationSyncService.h"
@interface CDAAbstractNSOperationSyncService()
@property (nonatomic, strong)id<CDASyncConnectorProtocol> connector;
@property (nonatomic, strong)id<CDASyncParserProtocol> parser;
@end
@implementation CDAAbstractNSOperationSyncService
@synthesize running = _running, uid = _uid, delegate = _delegate;

- (instancetype)initWithUid:(NSString *)uid
                  Connector:(id<CDASyncConnectorProtocol>)connector
                  AndParser:(id<CDASyncParserProtocol>)parser{
    
    if(!(self = [self initWithUid:uid]))return self;
    self.connector = connector;
    self.parser = parser;
    return self;
}
#pragma mark - CDASyncServiceProtocol
- (instancetype)initWithUid:(NSString *)uid{
    if(!(self = [super init]))return self;
    _uid = uid;
    return self;
}
- (double)progress{
    return ([self.connector progress] + [self.parser progress])/2.0;
}
- (void)tearDown{
    
}

#pragma mark - NSOperation
- (void)main{
    if([self checkCancelled])return;
    [self retrieveData];
}

#pragma mark - helpers
- (void)finish{
    _running = NO;
}
- (void) finishWithErrorId:(CDASyncError)errorId{
    [self finish];
    [self.delegate CDASyncService:self DidFinishWithErrorId:errorId];
}
- (void) finishWithSuccess{
    [self finish];
    [self.delegate CDASyncServiceDidFinishWithSuccess:self];
}
- (void)retrieveData{
    [self.connector getObjectsWithSuccess:^(id responseObject) {
        
        if([self checkCancelled])return;
        
        [self.parser parseData:responseObject AndCompletion:^(id result) {
            [self finishWithSuccess];
        }];
    } failure:^(NSError *error) {
        [self finishWithErrorId:(CDASyncError)error.code];
    }];
}
- (BOOL)checkCancelled{
    if(self.isCancelled){
        [self finishWithErrorId:CDASyncErrorSuspended];
    }
    return self.isCancelled;
}
@end
