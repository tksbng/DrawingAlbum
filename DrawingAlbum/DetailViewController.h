//
//  DetailViewController.h
//  DrawingAlbum
//
//  Created by Takeshi Bingo on 2013/08/28.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingView.h"

@class DrawingView;

@interface DetailViewController : UIViewController
<UISplitViewControllerDelegate
,UIPopoverControllerDelegate
,UINavigationControllerDelegate // フォトアルバム用
,UIImagePickerControllerDelegate // フォトアルバム用
,UITextFieldDelegate //タイトル用
,UIActionSheetDelegate //ペンの色選択用
>
{
    UIActionSheet *aActionSheet;
    UITextField *aTextField;
    NSMutableArray *aryStroke;
    NSMutableArray *aStroke;
    CGFloat penRed,penGreen,penBlue,penAlpha; //現在の色
    UIBarButtonItem *aColorButton;
    UIBarButtonItem *aAddButton;
    UIPopoverController *aPhotoPopoverController;
}
@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UIImageView *aImageView;
@property (nonatomic, retain) IBOutlet DrawingView *pastDrawingView;
@property (nonatomic, retain) IBOutlet DrawingView *curDrawingView;

-(NSString *)makeIconPathWithIndex:(NSInteger)idx;
-(NSString *)makeDataPathWithIndex:(NSInteger)idx;

@end
