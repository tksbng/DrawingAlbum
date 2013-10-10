//
//  DrawingView.h
//  DrawingAlbum
//
//  Created by Takeshi Bingo on 2013/08/28.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kLineDepth 10

@interface DrawingView : UIView
// ストロークのアクセサ。assign となっている点に注意。
@property (nonatomic,assign) NSMutableArray *aryData;
@end
