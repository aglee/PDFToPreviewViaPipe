//
//  TaskWrapperDelegate.h
//  PDFToPreviewViaPipe
//
//  Created by Andy Lee on 4/18/19.
//  Copyright © 2019 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TaskWrapper;

NS_ASSUME_NONNULL_BEGIN

@protocol TaskWrapperDelegate <NSObject>

@optional

/*! Called before the task is launched. */
- (void)taskWrapperWillStartTask:(TaskWrapper *)taskWrapper;

/*! Called when output arrives from the task, from either stdout or stderr. */
- (void)taskWrapper:(TaskWrapper *)taskWrapper didProduceOutput:(NSData *)outputData;

/*!
 * Called when any of the following happens:
 *
 *	- The task ends.
 *	- There is no more data coming through the file handle.
 *	- The process object is released.
 */
- (void)taskWrapper:(TaskWrapper *)taskWrapper didFinishTaskWithStatus:(int)terminationStatus;

@end

NS_ASSUME_NONNULL_END
