//
//  AppDelegate.m
//  PDFToPreviewViaPipe
//
//  Created by Andy Lee on 4/18/19.
//  Copyright © 2019 Andy Lee. All rights reserved.
//

#import "AppDelegate.h"
#import "TaskWrapper.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property TaskWrapper *taskWrapper;
@end

@implementation AppDelegate


#pragma mark - Action methods

- (IBAction)sendPDFToPreview:(id)sender
{
//	self.taskWrapper = [[TaskWrapper alloc] initWithCommandPath:@"/bin/cat" arguments:@[] environment:@{} delegate:self];
//	[self.taskWrapper startTaskWithInput:[@"abc" dataUsingEncoding:NSUTF8StringEncoding]];

	NSData *pdfData = [self.textView dataWithPDFInsideRect:self.textView.bounds];
	self.taskWrapper = [[TaskWrapper alloc] initWithCommandPath:@"/usr/bin/open" arguments:@[@"-f", @"-a", @"Preview"] environment:@{} delegate:self];
	[self.taskWrapper startTaskWithInput:pdfData];
}

#pragma mark - <TaskWrapperDelegate> methods

- (void)taskWrapper:(TaskWrapper *)taskWrapper didProduceOutput:(NSData *)outputData
{
	NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
	NSLog(@"+++ OUTPUT: %@", outputString);
}

- (void)taskWrapper:(TaskWrapper *)taskWrapper didFinishTaskWithStatus:(int)terminationStatus
{
	NSLog(@"+++ FINISHED");
	self.taskWrapper = nil;
}

@end
