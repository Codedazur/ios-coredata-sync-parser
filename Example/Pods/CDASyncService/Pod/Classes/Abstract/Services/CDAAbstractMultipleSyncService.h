//
//  CDAAbstractMultipleSyncService.h
//  Pods
//
//  Created by Tamara Bernad on 25/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncServiceProtocol.h"
#import "CDASyncConnectorProtocol.h"
#import "CDASyncParserProtocol.h"

@interface CDAAbstractMultipleSyncService : NSObject<CDASyncServiceProtocol>
- (instancetype)initWithUid:(NSString *)uid
                 Connectors:(NSArray<CDASyncConnectorProtocol> *)connectors
                 AndParsers:(NSArray<CDASyncParserProtocol> *)parsers;
@end
