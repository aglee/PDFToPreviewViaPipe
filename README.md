#  PDFToPreviewViaPipe

[**UPDATE:** My [second attempt](https://github.com/aglee/PDFToPreviewViaPrintOperation) is much simpler and works better.]

A quick throw-away experiment to see if I could answer this question:

<https://twitter.com/MarioGuzman/status/1119014393956556800>

> Does anyone know how to (or if possible) to open a PDF document in Preview without saving to disk first with AppKit? Almost like an export... I generate a PDF and just shoot it directly to Preview without having to mess with saving to disk and passing a file path to NSWorkspace.

<https://twitter.com/colincornaby/status/1119014724404834304>

> Mario wants Preview to treat it as an unsaved document, so he doesn't have to worry about handling the save flow himself. I feel like I've seen other apps do this (like print to PDF does.)

<https://twitter.com/ashur/status/1119019224838492161>

> It’s tangential to what you’re asking, but you can pipe contents into Preview (via TextEdit I think? 😂) like so:
> 
> cat my.pdf | open -f -a Preview
> 
> Maybe you can stream it in somehow (or just shell out and do it like this 🔥🗑 example)?
> 
> cc @MarioGuzman

Building on @ashur's suggestion, my idea was to pipe the PDF data to `open -f -a Preview` using `NSTask` and `NSPipe`.

Good news -- it worked.  Bad news -- it creates a temporary file in `/private/tmp` (and so I turned off sandboxing to get it to work).  The objective was to avoid creating a temporary file if possible.  I think it's `open` that creates the temp file.

Uses `TaskWrapper` code that I copied and modified from my ancient [MoreArty](https://github.com/aglee/MoreArty) sample project.  BTW there's at least one glitch in the `TaskWrapper` stuff -- the task-did-end delegate method gets called twice.


