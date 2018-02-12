//
//  PDPhotoBrowser.h
//  Panda
//
//  Created by guiq on 2017/6/2.
//  Copyright © 2017年 com.Xpand. All rights reserved.
//

#import <UIKit/UIKit.h>

//获取缩放返回的imageView的回调block
typedef UIImageView* (^PDAnimateView)(NSInteger index);

@interface PDPhotoBrowser : UIView

/* 查看本地图片的图片数组 */
@property (nonatomic, strong) NSArray *images;

/* 查看网络大图的url数组 */
@property (nonatomic, strong) NSArray *urls;

/* 当前操作的下标 */
@property (nonatomic, assign) NSInteger currentIndex;

/* 长按操作 */
@property (nonatomic, strong) void (^longPressHandle)(NSInteger index);

/*
 * 查看本地图片(带过渡动画)
 * 用image数组快速创建图片浏览器
 * currentIndex 当前操作的下标
 * animateView 获取缩放返回的imageView的回调block
 */
+ (PDPhotoBrowser *)photoWithImages:(NSArray *)images currentIndex:(NSInteger)currentIndex animateView:(PDAnimateView)animateView;

/*
 * 查看网络图片(带过渡动画)
 * urls 大图的url数组
 * currentIndex 当前操作的下标
 * animateView 获取缩放返回的imageView的回调block
 */
+ (PDPhotoBrowser *)photoWithUrls:(NSArray *)urls currentIndex:(NSInteger)currentIndex animateView:(PDAnimateView)animateView;

/**
 * 查看本地图片(不带过渡动画,直接加到window上)
 * urls 大图的url数组
 */
+ (PDPhotoBrowser *)photoWithImages:(NSArray *)images;

/**
 * 查看网络图片(不带过渡动画,直接加到window上)
 * urls 大图的url数组
 */
+ (PDPhotoBrowser *)photoWithUrls:(NSArray *)urls;

@end
