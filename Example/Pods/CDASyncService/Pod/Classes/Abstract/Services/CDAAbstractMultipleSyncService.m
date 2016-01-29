//
//  CDAAbstractMultipleSyncService.m
//  Pods
//
//  Created by Tamara Bernad on 25/01/16.
//
//

#import "CDAAbstractMultipleSyncService.h"
@interface CDAAbstractMultipleSyncService()
@property (nonatomic) NSInteger syncStep;
@property (nonatomic, strong) NSArray<CDASyncConnectorProtocol> *connectors;
@property (nonatomic, strong) NSArray<CDASyncParserProtocol> *parsers;
@end
@implementation CDAAbstractMultipleSyncService
@synthesize delegate = _delegate, running = _running, uid = _uid;

- (instancetype)initWithUid:(NSString *)uid Connectors:(NSArray<CDASyncConnectorProtocol> *)connectors AndParsers:(NSArray<CDASyncParserProtocol> *)parsers{
    if(!(self = [self initWithUid:uid]))return self;
    self.connectors = [connectors copy];
    self.parsers = [parsers copy];
    return self;
}
#pragma mark - CDASyncServiceProtocol
- (instancetype)initWithUid:(NSString *)uid{
    if(!(self = [super init]))return self;
    _uid = uid;
    return self;
}
- (void)start{
    _running = YES;
    [self retrieveData];
}
- (void)tearDown{
    self.syncStep = 0;
}
- (double)progress{
    double totalProgress = 0;
    for (int i=0; i<self.syncStep; i++) {
        totalProgress++;
    }
    totalProgress+= ([[self currentConnector] progress] + [[self currentParser] progress])/2.0;

    return totalProgress/(double)[self totalSyncSteps];
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
    [[self currentConnector] getObjectsWithSuccess:^(id responseObject) {
        [[self currentParser] parseData:responseObject AndCompletion:^(id result) {
            [self retrieveNextData];
        }];
    } failure:^(NSError *error) {
        [self finishWithErrorId:(CDASyncError)error.code];
    }];
}
- (void)retrieveNextData{
    self.syncStep++;
    
    if(self.syncStep >= [self totalSyncSteps])[self finishWithSuccess];
    else [self retrieveData];
}
- (NSInteger)totalSyncSteps{
    return self.connectors.count;
}
- (id<CDASyncConnectorProtocol>)currentConnector{
    return [self.connectors objectAtIndex:self.syncStep];
}
- (id<CDASyncParserProtocol>)currentParser{
    return [self.parsers objectAtIndex:self.syncStep];
}
@end
