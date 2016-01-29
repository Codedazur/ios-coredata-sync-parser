//
//  CDAAbstractNSOperationSyncService.h
//  Pods
//
//  Created by Tamara Bernad on 25/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncServiceProtocol.h"
#import "CDASyncConnectorProtocol.h"
#import "CDASyncParserProtocol.h"

@interface CDAAbstractNSOperationSyncService : NSOperation<CDASyncServiceProtocol>
- (instancetype)initWithUid:(NSString *)uid
                  Connector:(id<CDASyncConnectorProtocol>)connector
                  AndParser:(id<CDASyncParserProtocol>)parser;

@end
