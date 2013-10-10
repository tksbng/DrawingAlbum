//
//  DrawingView.m
//  DrawingAlbum
//
//  Created by Takeshi Bingo on 2013/08/28.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "DrawingView.h"

@implementation DrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)drawStroke:(NSMutableArray *)ary :(CGContextRef)ctx {
    // 最初の４つは色情報
    if ([ary count] >= 4) {
        CGFloat penRed =
        [(NSNumber *)[ary objectAtIndex:0] floatValue];
        CGFloat penGreen =
        [(NSNumber *)[ary objectAtIndex:1] floatValue];
        CGFloat penBlue =
        [(NSNumber *)[ary objectAtIndex:2] floatValue];
        CGFloat penAlpha =
        [(NSNumber *)[ary objectAtIndex:3] floatValue];
        CGContextSetLineWidth( ctx, kLineDepth );
        CGContextSetRGBStrokeColor(ctx,penRed,penGreen,penBlue,penAlpha);
    }
    if ([ary count] >= 6) {
        CGPoint pos;
        pos.x = [(NSNumber *)[ary objectAtIndex:4] integerValue];
        pos.y = [(NSNumber *)[ary objectAtIndex:5] integerValue];
        CGContextMoveToPoint(ctx, pos.x, pos.y);
        for (int i = 6; i < ([ary count]-1); i+=2) {
            // -1は、objectAtIndxでオーバーしないため
            pos.x = [(NSNumber *)[ary objectAtIndex:i] integerValue];
            pos.y = [(NSNumber *)[ary objectAtIndex:i+1]
                     integerValue];
            CGContextAddLineToPoint(ctx, pos.x, pos.y);
        }
    }
    CGContextStrokePath(ctx);
}
- (void)drawRect:(CGRect)rect
{
    
    if (_aryData) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineCap(ctx, kCGLineCapRound);
        
        if ([_aryData count] > 0) {
            if ([[_aryData objectAtIndex:0]
                 isKindOfClass:[NSMutableArray class]]) {
                for (NSMutableArray *stroke in _aryData) {
                    [self drawStroke:stroke :ctx];
                }
            } else {
                [self drawStroke:_aryData :ctx];
            }
        }
    }
}


@end
