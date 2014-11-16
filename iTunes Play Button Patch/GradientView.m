//
//  GradientView.m
//  Play Button iTunes Patch
//
// Based on http://www.katoemba.net/makesnosenseatall/2008/01/09/nsview-with-gradient-background/

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setStartingColor:[NSColor colorWithCalibratedWhite:0.70 alpha:1.0]];
        [self setEndingColor:nil];
        [self setAngle:270];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    if (_endingColor == nil || [_startingColor isEqual:_endingColor]) {
        // Fill view with a standard background color
        [_startingColor set];
        NSRectFill(rect);
    }
    else {
        // Fill view with a top-down gradient from startingColor to endingColor
        NSGradient* aGradient = [[NSGradient alloc]
                                 initWithStartingColor:_startingColor
                                 endingColor:_endingColor];
        [aGradient drawInRect:[self bounds] angle:_angle];
    }
}


@end
