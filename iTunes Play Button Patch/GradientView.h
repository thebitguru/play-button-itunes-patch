//
//  GradientView.h
//  Play Button iTunes Patch
//
// Based on http://www.katoemba.net/makesnosenseatall/2008/01/09/nsview-with-gradient-background/

#import <Cocoa/Cocoa.h>

@interface GradientView : NSView

// Define the variables as properties
@property (nonatomic, retain) NSColor *startingColor;
@property (nonatomic, retain) NSColor *endingColor;
@property (assign) int angle;

@end
