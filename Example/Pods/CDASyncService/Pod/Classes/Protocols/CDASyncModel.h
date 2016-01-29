//
//  CDASyncModel.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncServiceProtocol.h"
@protocol CDASyncModel <NSObject>

@property (nonatomic, strong, readonly) NSString *uid;
@property (nonatomic, strong, readonly) Class<CDASyncServiceProtocol> syncServiceClass;
@property (nonatomic, readonly) NSTimeInterval timeInterval;
@end
