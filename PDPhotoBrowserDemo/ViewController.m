//
//  ViewController.m
//  PDPhotoBrowserDemo
//
//  Created by guiq on 2017/6/7.
//  Copyright © 2017年 com.Xpand. All rights reserved.
//

#import "ViewController.h"
#import "PDPhotoBrowser.h"

@interface ViewController ()

/**
 * scrollView
 */
@property (nonatomic , strong) UIScrollView  *scrollView;
/**
 * 图片数组
 */
@property (nonatomic , strong) NSMutableArray  *images;
/**
 *  url strings
 */
@property (nonatomic , strong) NSArray  *urlStrings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urlStrings = @[
                        @"http://upload-images.jianshu.io/upload_images/1455933-e20b26b157626a5d.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-cb2abcce977a09ac.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-92be2b34e7e9af61.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-edd183910e826e8c.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-198c3a62a30834d6.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-e9e2967f4988eb7f.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-ce55e894fff721ed.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-ce55e894fff721ed.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-ce55e894fff721ed.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        @"http://upload-images.jianshu.io/upload_images/1455933-ce55e894fff721ed.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                        ];
    
    self.images = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 100, self.view.bounds.size.width - 30, 100)];
    [self.view addSubview:self.scrollView];

    self.scrollView.backgroundColor = [UIColor grayColor];
    
    for (int i = 0 ; i < self.urlStrings.count; i ++) {
        NSString *string = [NSString stringWithFormat:@"photo%d.jpg",i];
        UIImage *image = [UIImage imageNamed:string];
        [self.images addObject:image];
    }
    
    [self resetScrollView];
}

- (void)resetScrollView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat imageWidth = 100;
    CGFloat margin = 10;
    for (int i = 0 ; i < self.images.count; i ++) {
        UIImageView *headerImageView = [[UIImageView alloc] init];
        headerImageView.tag = i;
        headerImageView.userInteractionEnabled = YES;
        [headerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)]];
        
        headerImageView.frame = CGRectMake((imageWidth + margin) * i, 0, imageWidth, imageWidth);
        headerImageView.image = self.images[i];
        headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        headerImageView.layer.masksToBounds = YES;
        [self.scrollView addSubview:headerImageView];
    }
    self.scrollView.contentSize = CGSizeMake((imageWidth + margin) * self.images.count,0 );
}

- (void)clickImage:(UITapGestureRecognizer *)tap
{
    //展示本地图片
    [PDPhotoBrowser photoWithImages:self.images currentIndex:tap.view.tag animateView:^UIImageView *(NSInteger index) {
        return self.scrollView.subviews[index];
    }];
    
    //展示网络图片
//    [PDPhotoBrowser photoWithUrls:_urlStrings currentIndex:tap.view.tag animateView:^UIImageView *(NSInteger index) {
//        return self.scrollView.subviews[index];
//    }];
}


@end
