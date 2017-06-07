//
//  PDPhotoBrowserCell.h
//  Panda
//
//  Created by guiq on 2017/6/5.
//  Copyright © 2017年 com.Xpand. All rights reserved.
//

//每张图片间隔
#define PDMarginRight 20

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) void (^singleTapHandle)();

@property (nonatomic, strong) void (^longPressHandle)();

/**
 *  显示本地图片
 */
- (void)setImage:(UIImage *)image;

/**
 *  显示网络大图
 */
- (void)setImageWithURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
