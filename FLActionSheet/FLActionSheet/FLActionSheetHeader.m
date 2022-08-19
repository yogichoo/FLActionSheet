//
//  FLActionSheetHeader.m
//  FLProgram
//
//  Created by teamotto iOS on 2020/5/7.
//  Copyright © 2020 yogichoo. All rights reserved.
//

#import "FLActionSheetHeader.h"
#import "Masonry.h"

//Custom color
#define FLColorOf(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface FLActionSheetHeader ()

@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UIView *line;

@end

@implementation FLActionSheetHeader

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textColor = [UIColor lightGrayColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.numberOfLines = 0;
        [self addSubview:_titleLab];
    }
    return _titleLab;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = FLColorOf(239, 239, 239, 1.0);
        [self addSubview:_line];
    }
    return _line;
}

- (void)refreshUI:(NSString *)string color:(UIColor *)color font:(UIFont *)font {
    self.titleLab.text = string;
    self.titleLab.textColor = color;
    self.titleLab.font = font;
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
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_offset(14);
        make.right.mas_offset(-14);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.height.mas_equalTo(1);
    }];
}


@end
