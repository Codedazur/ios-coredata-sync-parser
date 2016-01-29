//
//  CDASyncErrors.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
typedef enum
{
    CDASyncErrorNoError,
    CDASyncErrorRunning,
    CDASyncErrorLogin,
    CDASyncErrorParsingResponse,
    CDASyncErrorDownloadingFile,
    CDASyncErrorHttp,
    CDASyncErrorUnknown,
    CDASyncErrorSuspended
    
}CDASyncError;