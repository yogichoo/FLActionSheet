//
//  FLActionSheet.h
//  FLProgram
//
//  Created by teamotto iOS Team on 2018/7/2.
//  Copyright © 2018 teamotto iOS Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FLActionSheetBlock) (NSString *item, NSInteger index);

@interface FLActionSheet : UIView

/**
 *  初始化并显示ActionSheet
 *  @param array        项数组
 *  @param title        传nil不带标题栏
 *  @param isCancel     是否显示底部取消按钮
 *  @param block        点击事件
 */
+ (void)initItems:(NSArray *)array title:(NSString * _Nullable)title cancel:(BOOL)isCancel action:(FLActionSheetBlock)block;

@end



#pragma MARK - FLActionSheetCell

@interface FLActionSheetCell : UITableViewCell

- (void)refreshUI:(NSString *)item color:(UIColor *)color font:(UIFont *)font itemIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
