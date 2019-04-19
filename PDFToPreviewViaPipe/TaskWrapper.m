//
//  TaskWrapper.m
//  PDFToPreviewViaPipe
//
//  Created by Andy Lee on 4/18/19.
//  Copyright © 2019 Andy Lee. All rights reserved.
//

#import "TaskWrapper.h"

@implementation TaskWrapper

- (id)initWithCommandPath:(NSString *)pathToCommand
				arguments:(NSArray *)commandArguments
			  environment:(NSDictionary *)env
				 delegate:(id <TaskWrapperDelegate>)aDelegate
{
	self = [super init];
	if (self) {
		_taskDelegate = aDelegate;
		_commandPath = pathToCommand;
		_commandArguments = commandArguments;
		_environment = env;
	}
	return self;
}

- (void)dealloc
{
	[self stopTask];
}

- (void)startTaskWithInput:(NSData *)inputData
{
	// Notify the delegate that we are starting.
	if ([(id)self.taskDelegate respondsToSelector:@selector(taskWrapperWillStartTask:)]) {
		[self.taskDelegate taskWrapperWillStartTask:self];
	}
	
	// Instantiate the NSTask that will run the specified command.
	_task = [[NSTask alloc] init];
	
	// The output of stdout and stderr is sent to a pipe so that we can catch it later
	// and send it to the delegate.
	if (inputData) {
		[self.task setStandardInput:[NSPipe pipe]];
	}
	[self.task setStandardOutput:[NSPipe pipe]];
	[self.task setStandardError:self.task.standardOutput];
	[self.task setLaunchPath:self.commandPath];
	[self.task setArguments:self.commandArguments];
	if (self.environment) {
		[self.task setEnvironment:self.environment];
	}
	
	// Register to be notified when there is data waiting in the task's file handle (the pipe
	// to which we connected stdout and stderr above). We do this because if the file handle gets
	// filled up, the task will block waiting to send data and we'll never get anywhere.
	// So we have to keep reading data from the file handle as we go.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_taskDidProduceOutput:)
												 name:NSFileHandleReadCompletionNotification
											   object:((NSPipe *)self.task.standardOutput).fileHandleForReading];
	
	// Tell the file handle to read in the background asynchronously. The file handle will
	// send a NSFileHandleReadCompletionNotification (which we just registered to observe)
	// when it has data available.
	[((NSPipe *)self.task.standardOutput).fileHandleForReading readInBackgroundAndNotify];
	
	// Launch the task asynchronously.
	[self.task launch];
	
	// Pipe input to the task.
	if (inputData) {
		[((NSPipe *)self.task.standardInput).fileHandleForWriting writeData:inputData];
		[((NSPipe *)self.task.standardInput).fileHandleForWriting closeFile];
	}
}

- (void)stopTask
{
	// Disconnect the notification center's weak reference to us.
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSFileHandleReadCompletionNotification
												  object:((NSPipe *)self.task.standardOutput).fileHandleForReading];
	
	// Make sure the task has actually stopped.
	[self.task terminate];
	
	// Drain any remaining output data the task generates.
	NSData *data;
	while ((data = ((NSPipe *)self.task.standardOutput).fileHandleForReading.availableData) && data.length) {
		// Notify the delegate that there is data.
		[self _sendDataToDelegate:data];
	}
	
	// Notify the delegate that the task finished.
	if ([(id)self.taskDelegate respondsToSelector:@selector(taskWrapper:didFinishTaskWithStatus:)]) {
		int taskStatus = (self.task.isRunning ? -9999 : self.task.terminationStatus);
		[self.taskDelegate taskWrapper:self didFinishTaskWithStatus:taskStatus];
	}
}

- (NSString *)unescapedExpandedCommand
{
	return [NSString stringWithFormat:@"%@ %@",
			self.commandPath,
			[self.commandArguments componentsJoinedByString:@" "]];
}

#pragma mark - Private methods

// Notifies the delegate that there is data.
- (void)_sendDataToDelegate:(NSData *)data
{
	if (data.length && [(id)self.taskDelegate respondsToSelector:@selector(taskWrapper:didProduceOutput:)]) {
		[self.taskDelegate taskWrapper:self didProduceOutput:data];
	}
}

#pragma mark - Notification handlers

// Called asynchronously when data is available from the task's file handle.
// [aNotification object] is the file handle.
- (void)_taskDidProduceOutput:(NSNotification *)aNotification
{
	NSData *data = aNotification.userInfo[NSFileHandleNotificationDataItem];
	
	if (data.length) {
		// Notify the delegate that there is data.
		[self _sendDataToDelegate:data];
		
		// [agl] Moved this readInBackgroundAndNotify up here from a few lines down.
		// Schedule the file handle to read more data.
		[aNotification.object readInBackgroundAndNotify];
	} else {
		// There is no more data to get from the file handle, so shut down.
		// This will in turn notify the delegate.
		[self stopTask];
	}
	
// [agl] Seems to me this should be in the if-block above -- am I wrong?
//	// Schedule the file handle to read more data.
//	[aNotification.object readInBackgroundAndNotify];
}

@end
