//
//  GMGridLinesTexturedView.m
//  imem
//
//  Created by luobin on 14-7-20.
//
//

#import "GMGridLinesTexturedView.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation GMGridLinesTexturedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat height = self.bounds.size.height/3;
    for (int i = 0; i < 3; i++) {
        CGRect rectangle = CGRectMake(0, height*(i + 1) - 0.5, self.bounds.size.width, 0.5);
        CGContextAddRect(ctx, rectangle);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:211/255.0 green:213/255.0 blue:216/255.0 alpha:1].CGColor);
        CGContextFillPath(ctx);
        
        rectangle = CGRectMake(0, height*(i + 1), self.bounds.size.width, 0.5);
        CGContextAddRect(ctx, rectangle);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:228/255.0 green:229/255.0 blue:230/255.0 alpha:1].CGColor);
        CGContextFillPath(ctx);
    }
    
    CGFloat width = self.bounds.size.width/5;
    for (int i = 0; i < 5; i++) {
        CGRect rectangle = CGRectMake(width*(i + 1) - 0.5, 0, 0.5, self.bounds.size.height);
        CGContextAddRect(ctx, rectangle);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:211/255.0 green:213/255.0 blue:216/255.0 alpha:1].CGColor);
        CGContextFillPath(ctx);
        
        rectangle = CGRectMake(width*(i + 1), 0, 0.5, self.bounds.size.height);
        CGContextAddRect(ctx, rectangle);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:228/255.0 green:229/255.0 blue:230/255.0 alpha:1].CGColor);
        CGContextFillPath(ctx);
    }
}


@end