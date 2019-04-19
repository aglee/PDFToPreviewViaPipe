//
//  TaskWrapper.h
//  PDFToPreviewViaPipe
//
//  Created by Andy Lee on 4/18/19.
//  Copyright © 2019 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskWrapperDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * Wrapper around NSTask, with a delegate that provides hooks to various
 * points in the lifetime of the task. Evolved from the TaskWrapper class
 * in Apple's Moriarity sample code.
 *
 * There is a delegate method to receive output from the task's stdout
 * and stderr, but no way to interactively send input via stdin.
 *
 * TaskWrapper objects are one-shot, like NSTask. If you need to run
 * a task more than once, create new TaskWrapper instances.
 */
@interface TaskWrapper : NSObject

@property (weak, readonly) id<TaskWrapperDelegate> taskDelegate;
@property (copy, readonly) NSString *commandPath;
@property (copy, readonly) NSArray *commandArguments;
@property (copy, readonly) NSDictionary *environment;
@property (readonly) NSTask *task;

/*!
 * commandPath is the path to the executable to launch. env contains environment variables
 * you want the command to run with. env can be nil.
 */
- (id)initWithCommandPath:(NSString *)commandPath
				arguments:(NSArray *)args
			  environment:(NSDictionary *)env
				 delegate:(id <TaskWrapperDelegate>)aDelegate;

/*! The input data is piped to the task.  It can be nil. */
- (void)startTaskWithInput:(NSData *)inputData;

- (void)stopTask;

/*!
 * Returns a string consisting of the command path followed by arguments. Doesn't do
 * any escaping, so you may not be able to paste this into Terminal and run it. But
 * can be useful for debugging/logging.
 */
- (NSString *)unescapedExpandedCommand;

@end

NS_ASSUME_NONNULL_END
