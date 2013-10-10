//
//  DetailViewController.m
//  DrawingAlbum
//
//  Created by Takeshi Bingo on 2013/08/28.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "DetailViewController.h"


@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if ([aTextField isEditing]) {
        if ([aTextField canResignFirstResponder]) {
            [aTextField resignFirstResponder];
        }
    }
    [self saveData];
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    NSNumber *num = _detailItem;
    NSInteger fileIdx = [num integerValue];
    NSLog(@"%d",fileIdx);
    //写真画像の読み込み
    NSString *photoFilePath = [self makePhotoPathWithIndex:fileIdx];
    if ([[NSFileManager defaultManager] fileExistsAtPath:photoFilePath]) {
        [_aImageView setImage:[UIImage imageWithContentsOfFile:photoFilePath]];
    } else {
        [_aImageView setImage:[UIImage imageNamed:@"none.png"]];
    
    }
    //ストロークデータの読み込み・表示
    [self loadData:fileIdx];
    [_pastDrawingView setAryData:aryStroke];
    // DrawViewの更新
    [_pastDrawingView setNeedsDisplay];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    aColorButton = [[UIBarButtonItem alloc]
                    initWithTitle:@"color" style:UIBarButtonItemStyleBordered target:self
                    action:@selector(doSelectColor:)];
    aAddButton = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                  action:@selector(doAdd:)];
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self
                                   action:@selector(doUndo:)];
    
    self.navigationController.navigationBar.topItem.rightBarButtonItems =
    [NSArray arrayWithObjects:aColorButton,aAddButton,undoButton,nil];
    // ペンの色
    NSInteger colorIndex= [[NSUserDefaults standardUserDefaults] integerForKey:@"colorIndex"];
    [self setPenColor:colorIndex];
    //フォトライブラリから写真を選択するポップオーバーコントローラを準備
    UIImagePickerController *ipc =
    [[UIImagePickerController alloc] init];
    [ipc setSourceType:
     UIImagePickerControllerSourceTypePhotoLibrary];
    [ipc setDelegate:self];
    aPhotoPopoverController = [[UIPopoverController alloc] initWithContentViewController:ipc];
    aTextField = [[UITextField alloc] init ];
    aTextField.borderStyle = UITextBorderStyleRoundedRect;
    aTextField.delegate = self;
    aTextField.placeholder = @"タイトルを入れてね";
    aTextField.clearButtonMode = UITextFieldViewModeWhileEditing   ;
    aTextField.returnKeyType   = UIReturnKeyDone;
    aTextField.frame = CGRectMake(0,0,320,40);
    self.navigationItem.titleView = aTextField;
    
    
    NSInteger fileIdx = [[NSUserDefaults standardUserDefaults] integerForKey:@"fileIdx"];
    [self setDetailItem:[NSNumber numberWithInteger:fileIdx]];
}

-(void)doSelectColor:(id)sender{
    NSLog(@"Color");
    if (aActionSheet) {
        return;
    }
    [self putawayWindow];
    aActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"ピンク",@"オレンジ",@"アクアマリン",@"青りんご",@"スカイブルー",@"スミレ", nil];
    [aActionSheet showFromBarButtonItem:aColorButton animated:YES];
}

-(void)doUndo:(id)sender {
    NSLog(@"Undo");
    if ([aryStroke count] > 0) {
        [aryStroke removeLastObject];
        [_pastDrawingView setAryData:aryStroke];
        [_pastDrawingView setNeedsDisplay];
    }
}

-(void)doAdd:(id)sender{
    NSLog(@"Add");
    [self putawayWindow];
    [aPhotoPopoverController
     presentPopoverFromBarButtonItem:aAddButton
     permittedArrowDirections:UIPopoverArrowDirectionAny
     animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)stockStroke:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:_curDrawingView];
    NSLog(@"%d:%03.0f,%03.0f",[touch phase],pos.x,pos.y);
    if (! [[touch view] isEqual:_curDrawingView]) {
        return;
    }
    switch ([touch phase]) {
        case UITouchPhaseBegan: // 始まり
            // ストロークの始まり。aStrokeを確保する。
            aStroke = [[NSMutableArray alloc] initWithCapacity:0];
            // 最初の4つは色情報
            [aStroke addObject:[NSNumber numberWithFloat:penRed]];
            [aStroke addObject:[NSNumber numberWithFloat:penGreen]];
            [aStroke addObject:[NSNumber numberWithFloat:penBlue]];
            [aStroke addObject:[NSNumber numberWithFloat:penAlpha]];
            // 一つ目の点を置く
            [aStroke addObject:[NSNumber
                                numberWithInteger:(NSInteger)pos.x]];
            [aStroke addObject:[NSNumber
                                numberWithInteger:(NSInteger)pos.y]];
            break;
        case UITouchPhaseMoved: // 移動
            if (aStroke) {
                // 移動先の点を置く
                [aStroke addObject:[NSNumber
                                    numberWithInteger:(NSInteger)pos.x]];
                [aStroke addObject:[NSNumber
                                    numberWithInteger:(NSInteger)pos.y]];
            }
            break;
        case UITouchPhaseStationary: // 変わっていない
            // 何もしない
            break;
        case UITouchPhaseEnded: // おわり
        case UITouchPhaseCancelled: // キャンセル
        default: // その他（その他はないはず）
            
            if (aStroke) {
                // 一筆書き分はここまで。
                [aStroke addObject:[NSNumber
                                    numberWithInteger:(NSInteger)pos.x]];
                [aStroke addObject:[NSNumber
                                    numberWithInteger:(NSInteger)pos.y]];
                // （aryがまだなければつくる）
                if (! aryStroke) {
                    aryStroke = [[NSMutableArray alloc]
                                 initWithCapacity:0];
                }
                // aStrokeは過去保存用のaryStrokeへ持っていき、nilにする。
                [aryStroke addObject:aStroke];
                aStroke = nil;
                
                [_pastDrawingView setAryData:aryStroke];
                [_pastDrawingView setNeedsDisplay];
            }
            break;
    }
    [_curDrawingView setAryData:aStroke];
    [_curDrawingView setNeedsDisplay];


    
}


-(void)setPenColor:(NSInteger)idx {
    CGFloat components[] = {
        //   r     g     b     a
        1.0f, 0.2f, 0.6f, 0.7f, // 0:ピンク
        1.0f, 0.6f, 0.2f, 0.7f, // 1:オレンジ
        0.2f, 1.0f, 0.6f, 0.7f, // 2:アクアマリン
        0.6f, 1.0f, 0.2f, 0.7f, // 3:青リンゴ
        0.2f, 0.6f, 1.0f, 0.7f, // 4:スカイブルー
        0.6f, 0.2f, 1.0f, 0.7f // 5:すみれ
    };
    
    if ((idx >= 0) && (idx <= 5)) {
        penRed = components[idx*4+0];
        penGreen = components[idx*4+1];
        penBlue = components[idx*4+2];
        penAlpha = components[idx*4+3];
        //最後の色選択を保存します。
        [[NSUserDefaults standardUserDefaults] setInteger:idx forKey:@"colorIndex"];
    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stockStroke:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stockStroke:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stockStroke:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stockStroke:touches];
}


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *aImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize size = [_aImageView frame].size;
    UIGraphicsBeginImageContext(size);
    CGSize photoSize = CGSizeMake([aImage size].width,
                                  [aImage size].height);
    // この後の計算で分母に0がこないようにチェック。
    if (photoSize.width == 0 || photoSize.height == 0) {
        return;
    }
    if (size.width == 0 || size.height == 0) {
        return;
    }
    CGPoint lefttop=CGPointZero;
    // 写真の横幅のサイズの比率が縦幅のサイズの比率より大きい場合
    if ( photoSize.height/size.height < photoSize.width/ size.width) {
        // 幅はsize.widthを採用。
        size.height = size.width * photoSize.height/ photoSize.width;
        lefttop.y = ([_aImageView frame].size.height - size.height)/2.0f;
    }else{
        // 高さはsize.heightを採用。
        size.width = size.height * photoSize.width/ photoSize.height;
        lefttop.x = ([_aImageView frame].size.width - size.width)/2.0f;
    }
    [aImage drawInRect:CGRectMake(lefttop.x, lefttop.y,size.width, size.height)];
    UIImage *imgPhoto = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //[_aImageView setImage:imgPhoto];
    //データ番号の算出
    NSNumber *num = [self detailItem];
    NSInteger fileIdx = [num integerValue];
    //写真の保存をしてから画面に表示
    NSString *photoFilePath = [self makePhotoPathWithIndex:fileIdx];
    [UIImagePNGRepresentation(imgPhoto) writeToFile:photoFilePath atomically:YES];
    [_aImageView setImage:[UIImage imageWithContentsOfFile:photoFilePath]];
    //アイコンの保存
    NSString *iconFilePath = [self makeIconPathWithIndex:fileIdx];
    CGSize iconSize = CGSizeMake(57.0f, 57.0f);
    UIGraphicsBeginImageContext(iconSize);
    [[_aImageView image] drawInRect:CGRectMake(0.0f, 0.0f, iconSize.width, iconSize.height)];
    UIImage *imgIcon =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [UIImagePNGRepresentation(imgIcon) writeToFile:iconFilePath atomically:YES];
    UITableView *tableView = (UITableView *)[[[self.splitViewController.viewControllers objectAtIndex:0] topViewController] view];
    [tableView reloadData];
    [aPhotoPopoverController dismissPopoverAnimated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    //データの保存
    [self saveData];
    //テーブルビューの更新
    UITableView *tableView = (UITableView *)
    [[[self.splitViewController.viewControllers objectAtIndex:0] topViewController] view];
    [tableView reloadData];
}
- (void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker {
    [aPhotoPopoverController dismissPopoverAnimated:YES];
}

-(void)putawayWindow {
    //アクションシートが表示されていたら閉じる
    if (aActionSheet) {
        NSInteger numCancel = [aActionSheet cancelButtonIndex];
        [aActionSheet dismissWithClickedButtonIndex:numCancel animated:YES];
    }
    // テーブルビューのポップオーバーが表示されていたら閉じる
    if ([self masterPopoverController]) {
        if ([[self masterPopoverController] isPopoverVisible]) {
            [[self masterPopoverController]
             dismissPopoverAnimated:YES];
        }
    }
    
    // 写真アルバム選択のポップオーバーが表示されていたら閉じる。
    if (aPhotoPopoverController) {
        if ([aPhotoPopoverController isPopoverVisible]) {
            [aPhotoPopoverController dismissPopoverAnimated:YES];
        }
    }
    //ソフトウェアキーボードが表示されていたら閉じる
    //(実際にはテキストフィールド編集中なら、フォーカスを外す）
    if ([aTextField canResignFirstResponder]) {
        [aTextField resignFirstResponder];
    }
}
- (void)splitViewController:(UISplitViewController *)svc
          popoverController:(UIPopoverController *)pc
  willPresentViewController:
(UIViewController *)aViewController {
    // ポップオーバーしているウィンドウを閉じる
    [self putawayWindow];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


//iPadの縦向き横向きが変化したら呼ばれる
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([self interfaceOrientation] ==
        UIInterfaceOrientationPortrait ||
        [self interfaceOrientation] ==
        UIInterfaceOrientationPortraitUpsideDown) {
        [_aImageView setCenter:[[self view] center]];
        [_pastDrawingView setCenter:[[self view] center]];
        [_curDrawingView setCenter:[[self view] center]];
    }else{
        //ImageViewの位置とサイズを取得
        CGRect r = [_aImageView frame];
        //配置位置をx軸は0、y軸はナビゲーションバーの下にセット
        r.origin = CGPointMake(0.0f,
                               [self.navigationController.navigationBar frame].size.height);
        [_aImageView setFrame:r];
        [_pastDrawingView setFrame:r];
        [_curDrawingView setFrame:r];
    }
}

-(NSString *)makePhotoPathWithIndex:(NSInteger)idx {
    NSString *docFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *photoFilePath = [NSString stringWithFormat:@"%@/photo-%04d.png",docFolder,idx];
    return photoFilePath;
}
-(NSString *)makeIconPathWithIndex:(NSInteger)idx{
    NSString *docFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *iconFilePath = [NSString stringWithFormat:@"%@/icon-%04d.png",docFolder,idx];
    return iconFilePath;
}

//テキストフィールドを編集する直前に呼び出される
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //ポップオーバーしているウィンドウを閉じる
    [self putawayWindow];
    return YES;
}
//Returnボタンがタップされた時に呼ばれる
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([aTextField canResignFirstResponder]){
        [aTextField resignFirstResponder];
    }
    return YES;
}
//タイトル・ストロークデータの保存ファイル名を作成（一覧データからもタイトル表示時に呼ばれる）
-(NSString *)makeDataPathWithIndex:(NSInteger)idx {
    NSString *docFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dataFilePath = [NSString stringWithFormat:@"%@/data-%04d.plist",docFolder,idx];
    return dataFilePath;
}
//ストロークデータの保存
-(void)saveData{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *title = [aTextField text];
    [dic setValue:title forKey:@"title"];
    [dic setValue:aryStroke forKey:@"aryStroke"];
    NSNumber *num = [self detailItem];
    NSInteger fileIdx = [num integerValue];
    NSString *dataFilePath = [self makeDataPathWithIndex:fileIdx];
    [dic writeToFile:dataFilePath atomically:YES];
}

//タイトル・ストロークデータの読み込み
-(void)loadData:(NSInteger)idx {
    NSNumber *num = [self detailItem];
    NSInteger fileIdx = [num integerValue];
    NSString *dataFilePath = [self makeDataPathWithIndex:fileIdx];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:dataFilePath];
    [aTextField setText:[dic valueForKey:@"title"]];
    if(!aryStroke){
        aryStroke = [[NSMutableArray alloc] init];
        
    }
    [aryStroke setArray:[dic valueForKey:@"aryStroke"]];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self setPenColor:buttonIndex];
}

//アクションシートを閉じた直後に呼ばれるデリゲートメソッド
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:

(NSInteger)buttonIndex {
    aActionSheet = nil;
}

@end
