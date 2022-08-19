//
//  FLActionSheet.m
//  FLProgram
//
//  Created by teamotto iOS Team on 2018/7/2.
//  Copyright © 2018 teamotto iOS Team. All rights reserved.
//

#import "FLActionSheet.h"
#import "FLActionSheetHeader.h"
#import "SceneDelegate.h"

#import "Masonry.h"

//Screen width
#define FLMainScreenWidth [UIScreen mainScreen].bounds.size.width
//Screen height
#define FLMainScreenHeight [UIScreen mainScreen].bounds.size.height
//Custom color
#define FLColorOf(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define ITEM_HEIGHT 50                                                      //默认行高
#define ITEM_FONT_SIZE 14                                                   //默认选项标题字体大小
#define ITEM_COLOR FLColorOf(80, 80, 80, 1)                                 //默认选项字体颜色
#define TIPSMODE_ITEM_COLOR FLColorOf(80, 80, 80, 1)                        //提示框模式下选项字体颜色

#define TITLE_HEIGHT 40                                                     //标题栏默认高度
#define TITLE_FONT_SIZE ITEM_FONT_SIZE-2                                    //标题字体大小
#define TITLE_COLOR [UIColor lightGrayColor]                                //标题字体颜色

#define CONTENT_HEIGHT FLMainScreenHeight/2+ITEM_HEIGHT+10//ITEM_HEIGHT*2+10                                     //默认视图高度
#define BACKGROUND_COLOR [UIColor whiteColor]                               //视图主题颜色

@interface FLActionSheet () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) UIView *bgVw;
@property (strong, nonatomic) UIView *contentVw;                            //actionsheet整体视图
@property (assign, nonatomic) CGFloat contentVwHeight;
@property (assign, nonatomic) BOOL isTipsMode;                              //提示框模式：当title != nil时 isTipsMode = YES;
@property (copy, nonatomic) NSString *title;                                //标题
@property (strong, nonatomic) UITableView *tableVw;                         //选项tableview
@property (strong, nonatomic) UIButton *cancelBtn;                          //取消按钮

@property (copy, nonatomic) FLActionSheetBlock actionBlock;                 //列表选择回调block

@end

@implementation FLActionSheet

//半透明黑色背景
- (UIView *)bgVw {
    if (!_bgVw) {
        _bgVw = [[UIView alloc] init];
        [_bgVw setBackgroundColor:FLColorOf(0, 0, 0, 0.45)];
        [self addSubview:_bgVw];
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenAction)];
        [_bgVw addGestureRecognizer:bgTap];
    }
    return _bgVw;
}

//actionsheet整体视图
- (UIView *)contentVw {
    if (!_contentVw) {
        _contentVw = [[UIView alloc] init];
        _contentVw.frame = CGRectMake(10, FLMainScreenHeight, FLMainScreenWidth-20, CONTENT_HEIGHT);
        _contentVw.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentVw];
    }
    return _contentVw;
}

//选项tableview
- (UITableView *)tableVw {
    if (!_tableVw) {
        _tableVw = [[UITableView alloc] init];
        _tableVw.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableVw.scrollEnabled = NO;
        _tableVw.bounces = NO;
        _tableVw.backgroundColor = BACKGROUND_COLOR;
        _tableVw.layer.cornerRadius = 10;
        _tableVw.clipsToBounds = YES;
        //iOS15.0以上tableview header头部默认会有一段间距
        if (@available(iOS 15.0, *))
            _tableVw.sectionHeaderTopPadding = 0;
        _tableVw.delegate = self;
        _tableVw.dataSource = self;
        [self.contentVw addSubview:_tableVw];
        [_tableVw registerClass:[FLActionSheetCell class] forCellReuseIdentifier:@"actionSheet"];
    }
    return _tableVw;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        //取消按钮
        _cancelBtn = [[UIButton alloc] init];
        _cancelBtn.backgroundColor = BACKGROUND_COLOR;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:ITEM_FONT_SIZE];
        [_cancelBtn setTitleColor:ITEM_COLOR forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:[self imageWithColor:FLColorOf(190, 190, 195, 1.0)] forState:UIControlStateHighlighted];
        [_cancelBtn setTitleColor:FLColorOf(80, 80, 80, 1) forState:UIControlStateHighlighted];
        _cancelBtn.layer.cornerRadius = 10;
        _cancelBtn.clipsToBounds = YES;
        [self.contentVw addSubview:_cancelBtn];
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

+ (void)initItems:(NSArray *)array title:(NSString * _Nullable )title cancel:(BOOL)isCancel action:(FLActionSheetBlock)block {
    FLActionSheet *actionSheet = [[FLActionSheet alloc] init];;
    actionSheet.frame = [[UIApplication sharedApplication] keyWindow].bounds;
    [[[UIApplication sharedApplication] keyWindow] addSubview:actionSheet];
    //刷新视图数据
    if (title) {
        actionSheet.isTipsMode = YES;
        actionSheet.title = title;
    }else {
        actionSheet.isTipsMode = NO;
    }
    [actionSheet refreshUI:array cancel:isCancel];
    //点击事件
    actionSheet.actionBlock = block;
}

#pragma mark - initUI
//初始化视图
- (instancetype)init {
    self = [super init];
    if (self) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    [self.bgVw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_offset(0);
    }];
    
    [self.tableVw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_offset(0);
        make.bottom.mas_offset(-(ITEM_HEIGHT+10));
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.height.offset(ITEM_HEIGHT);
    }];
}

- (void)refreshUI:(NSArray *)array cancel:(BOOL)isCancel {
    if (self.dataArray.count != 0)
        [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:array];
    
    //设置视图高度
    //标题高度
    CGFloat headerHeight = 0;
    if (self.isTipsMode) {
        //标题栏高度
        headerHeight = (TITLE_HEIGHT-[self getTitleLineHeight])+[self getTextHeightWithString:self.title width:FLMainScreenWidth-20-28 lineSpacing:0 font:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
    };
    //选项部分高度
    CGFloat itemPartHeight = 0;
    for (NSInteger i=0; i<array.count; i++) {
        NSString *item = array[i];
        itemPartHeight += ITEM_HEIGHT-[self getItemLineHeight]+[self getTextHeightWithString:item width:FLMainScreenWidth-20-28 lineSpacing:0 font:[UIFont systemFontOfSize:ITEM_FONT_SIZE]];
    }
    self.contentVwHeight = headerHeight+itemPartHeight;
    
    if (isCancel) {
        self.contentVwHeight += 10+ITEM_HEIGHT;
        self.cancelBtn.hidden = NO;
        [self.tableVw mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_offset(0);
            make.bottom.mas_offset(-(ITEM_HEIGHT+10));
        }];
    }else {
        self.cancelBtn.hidden = YES;
        [self.tableVw mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_offset(0);
        }];
    }
    
    //控制视图最高高度
    self.tableVw.scrollEnabled = NO;
    if (self.contentVwHeight > CONTENT_HEIGHT) {
        self.contentVwHeight = CONTENT_HEIGHT;
        //超过指定高度时，设置可滚动
        self.tableVw.scrollEnabled = YES;
    }
    
    [self.tableVw reloadData];
    //显示FLActionSheet
    [self animateIsShow:YES];
}


//获取标题项字体单行高度
- (CGFloat)getTitleLineHeight {
    CGFloat titleLineHeight = [self getTextHeightWithString:@"FLProgram" width:FLMainScreenWidth-20-28 lineSpacing:0 font:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
    return titleLineHeight;
}

//获取选项字体单行高度
- (CGFloat)getItemLineHeight {
    CGFloat itemLineHeight = [self getTextHeightWithString:@"FLProgram" width:FLMainScreenWidth-20-28 lineSpacing:0 font:[UIFont systemFontOfSize:ITEM_FONT_SIZE]];
    return itemLineHeight;
}

- (void)hiddenAction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    for (UIView *view in window.subviews) {
        if ([view isKindOfClass:[self class]])
            [self animateIsShow:NO];
    }
}

- (void)cancelAction {
    [self hiddenAction];
}

- (void)animateIsShow:(BOOL)show {
    CGRect rect = CGRectZero;
    if (show) {
        CGFloat y = FLMainScreenHeight-self.contentVwHeight;
        if ([self isFullScreen])         //判断是否是全面屏
            y -= 34;
        else
            y -= 10;
        rect = CGRectMake(10, y, FLMainScreenWidth-20, self.contentVwHeight);
    }else {
        rect = CGRectMake(10, FLMainScreenHeight, FLMainScreenWidth-20, self.contentVwHeight);
    }
    [self delay:0.1 completion:^{
        [UIView animateWithDuration:0.25f animations:^{
            self.contentVw.frame = rect;
        }];
    }];
    if (!show) {
        [self delay:0.35 completion:^{
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLActionSheetCell *actionSheetCell = [tableView dequeueReusableCellWithIdentifier:@"actionSheet"];
    UIColor *itemColor = ITEM_COLOR;
    if (self.isTipsMode)
        itemColor = TIPSMODE_ITEM_COLOR;
    [actionSheetCell refreshUI:self.dataArray[indexPath.row] color:itemColor font:[UIFont systemFontOfSize:ITEM_FONT_SIZE] itemIndex:indexPath.row];
    [actionSheetCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    return actionSheetCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.actionBlock(self.dataArray[indexPath.row], indexPath.row);
    [self hiddenAction];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ITEM_HEIGHT-[self getItemLineHeight]+[self getTextHeightWithString:self.dataArray[indexPath.row] width:FLMainScreenWidth-20-28 lineSpacing:0 font:[UIFont systemFontOfSize:ITEM_FONT_SIZE]];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isTipsMode) {
        FLActionSheetHeader *header = [[FLActionSheetHeader alloc] init];
        header.backgroundColor = BACKGROUND_COLOR;
        [header refreshUI:self.title color:TITLE_COLOR font:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isTipsMode) {
        return TITLE_HEIGHT-[self getTitleLineHeight]+[self getTextHeightWithString:self.title width:FLMainScreenWidth-20-28 lineSpacing:0 font:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
    }
    return 0;
}

#pragma MARK - Other

//判断是否是全面屏iPhone
- (BOOL)isFullScreen {
    //判断设备是否是iPhone
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone)
        return NO;
    
    if (@available(iOS 11.0, *)) {
        //判断是否存在安全区域
        //if ([UIApplication sharedApplication].delegate.window) {
        //    return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom > 0.0;
        //}else {
            UIWindowScene *windowScene= (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] allObjects].firstObject;
            SceneDelegate *delegate = (SceneDelegate *)windowScene.delegate;
            return  delegate.window.safeAreaInsets.bottom > 0.0;
        //}
    }
    return NO;
}

- (void)delay:(CGFloat)time completion:(void (^)(void))completion {
    dispatch_queue_t subQueue = dispatch_queue_create("delay_queue", DISPATCH_QUEUE_CONCURRENT);
    //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), subQueue, ^{
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGFloat)getTextHeightWithString:(NSString *)string width:(CGFloat)width lineSpacing:(CGFloat)lineSpacing font:(UIFont *)font {
    //设置行间距
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = lineSpacing;
    //设置字体和字体大小
    //如果自定义字体最好设置Bold字体，否则可能会出现高度计算不准确的问题
    //[UIFont fontWithName:@"Lato-Bold" size:fontSize]
    NSDictionary *params = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paraStyle};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:params context:nil].size;
    return  ceilf(size.height);
}

- (CGFloat)getTextWidthWithString:(NSString *)string height:(CGFloat)height font:(UIFont *)font {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(FLMainScreenWidth, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil];
    return rect.size.width;
}

@end



#pragma MARK - FLActionSheetCell

@interface FLActionSheetCell ()

@property (strong, nonatomic) UILabel *itemLab;
@property (strong, nonatomic) UIView *line;

@end

@implementation FLActionSheetCell

- (UILabel *)itemLab {
    if (!_itemLab) {
        _itemLab = [[UILabel alloc] init];
        _itemLab.font = [UIFont systemFontOfSize:16];
        _itemLab.textAlignment = NSTextAlignmentCenter;
        _itemLab.numberOfLines = 0;
        [self addSubview:_itemLab];
        [_itemLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.mas_offset(14);
            make.right.mas_offset(-14);
        }];
    }
    return _itemLab;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = FLColorOf(239, 239, 239, 1.0);
        [self addSubview:_line];
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_offset(0);
            make.height.mas_equalTo(1);
        }];
    }
    return _line;
}

- (void)refreshUI:(NSString *)item color:(UIColor *)color font:(UIFont *)font itemIndex:(NSInteger)index {
    self.itemLab.text = item;
    self.itemLab.textColor = color;
    self.itemLab.font = font;
    
    //隐藏底部分割线
    if (index == 0)
        self.line.hidden = YES;
    else
        self.line.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
