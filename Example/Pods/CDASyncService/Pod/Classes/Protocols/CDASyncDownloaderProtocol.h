//
//  CDASyncDownloaderProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDASyncDownloaderProtocol <NSObject>
@property (nonatomic, weak)id<CDAMediaDownloaderDelegate> delegate;
- (void)downloadItems:(NSArray *)items;
@end

@protocol CDASyncDownloaderDelegate <NSObject>

- (void) CDASyncDownloaderDidFinishAllDownloads:(id<CDASyncDownloaderProtocol>) downloader;
- (void) CDASyncDownloaderUpdateProgress:(id<CDASyncDownloaderProtocol>)downloader progress:(float)progress;

@end