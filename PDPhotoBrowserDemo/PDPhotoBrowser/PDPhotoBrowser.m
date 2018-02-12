//
//  PDPhotoBrowser.m
//  Panda
//
//  Created by guiq on 2017/6/2.
//  Copyright © 2017年 com.Xpand. All rights reserved.
//

#import "PDPhotoBrowser.h"
#import "PDPhotoBrowserCell.h"

@interface PDPhotoBrowser ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

/* 获取缩放返回的imageView的回调block */
@property (nonatomic, strong) PDAnimateView animateView;
@property (nonatomic, strong) UIImageView *animateImageView;

/* UICollectionView容器 */
@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) UIPageControl *pageControl;

@end

@implementation PDPhotoBrowser


#pragma mark - public 快速创建图片浏览器
+ (PDPhotoBrowser *)photoWithImages:(NSArray *)images currentIndex:(NSInteger)currentIndex animateView:(PDAnimateView)animateView{
    
    PDPhotoBrowser *browser = [[PDPhotoBrowser alloc] init];
    browser.images = images;
    browser.currentIndex = currentIndex;
    browser.animateView = animateView;
    [browser show];
    return browser;
}

+ (PDPhotoBrowser *)photoWithUrls:(NSArray *)urls currentIndex:(NSInteger)currentIndex animateView:(PDAnimateView)animateView{
    
    PDPhotoBrowser *browser = [[PDPhotoBrowser alloc] init];
    browser.urls = urls;
    browser.currentIndex = currentIndex;
    browser.animateView = animateView;
    [browser show];
    return browser;
}

+ (PDPhotoBrowser *)photoWithImages:(NSArray *)images{
    PDPhotoBrowser *browser = [[PDPhotoBrowser alloc] init];
    browser.images = images;
    [browser show];
    return browser;
}

+ (PDPhotoBrowser *)photoWithUrls:(NSArray *)urls{
    PDPhotoBrowser *browser = [[PDPhotoBrowser alloc] init];
    browser.urls = urls;
    [browser show];
    return browser;
}

//显示图片浏览器
- (void)show
{
    //显示本地图片
    if (self.images) {
        if (self.images.count <= 0) {
            return;
        }
        if (self.currentIndex >= self.images.count) {
            self.currentIndex = self.images.count - 1;
        }
        if (self.currentIndex < 0) {
            self.currentIndex = 0;
        }
    }
    //显示网络图片
    else{
        if (self.urls.count <= 0) {
            NSLog(@"图片浏览器必须传入大图url");
            return;
        }
        if (self.currentIndex >= self.urls.count) {
            self.currentIndex = self.urls.count - 1;
        }
        if (self.currentIndex < 0) {
            self.currentIndex = 0;
        }
    }
    
    //添加到window层
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addSubview:self];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //初始化界面
    [self initUI];
    
    //开始打开相册的过渡动画
    [self beginShowTransfromAnimation];
}

/**
 *  开始打开相册的过渡动画
 */
- (void)beginShowTransfromAnimation
{
    //获取到用户点击的那个UIImageView对象,进行坐标转化
    CGRect startRect;
    if (self.animateView) {
        _animateImageView = self.animateView(_currentIndex);
    }
    startRect = [self.animateImageView.superview convertRect:self.animateImageView.frame toView:self];
    
    //利用零时tempImageView完成过度的形变动画
    UIImageView *tempImageView = [[UIImageView alloc] init];
    
    UIImage *image = self.animateImageView.image;
    if (!image) {
        image = [UIImage imageNamed:@"pb_placeHolder"];
    }
    tempImageView.image = image;
    tempImageView.frame = startRect;
    [self addSubview:tempImageView];
    
    CGRect targetRect; // 目标frame
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.width / imageWidthHeightRatio;
    CGFloat x = 0;
    CGFloat y;
    if (height > self.bounds.size.height) {
        y = 0;
    } else {
        y = (self.bounds.size.height - height ) * 0.5;
    }
    targetRect = CGRectMake(x, y, width, height);
    _collectionView.hidden = YES;
    self.alpha = 1.0;
    
    // 动画修改图片视图的frame,居中同时放大
    [UIView animateWithDuration:0.3 animations:^{
        tempImageView.frame = targetRect;
    } completion:^(BOOL finished) {
        [tempImageView removeFromSuperview];
        _collectionView.hidden = NO;
    }];
}

/**
 *  单击图片,退出浏览
 */
- (void)removePhotoBrowser
{
    //获取当前展示的cell
//    PDPhotoBrowserCell *cell = [_collectionView visibleCells].firstObject;

    //当前显示图片的下标
//    _currentIndex = [_collectionView indexPathForCell:cell].row;
    
    PDPhotoBrowserCell *cell = (PDPhotoBrowserCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    
    [UIView animateWithDuration:0.15 animations:^{
        cell.alpha = 0.0;
    } completion:nil];
    
    //当前暂时图片的下标
    if (self.animateView) {
        _animateImageView = self.animateView(_currentIndex);
    }
    CGRect targetFrame = [_animateImageView.superview convertRect:_animateImageView.frame toView:self];

    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = cell.imageView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = cell.imageView.image;
    tempView.frame = CGRectMake( - cell.scrollView.contentOffset.x + cell.imageView.frame.origin.x,  - cell.scrollView.contentOffset.y + cell.imageView.frame.origin.y, cell.imageView.frame.size.width, cell.imageView.frame.size.height);
    [self addSubview:tempView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.3 animations:^{
        tempView.frame = targetFrame;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dealloc{
    NSLog(@"PDPhotoBrowser  销毁了");
}

#pragma mark - init
- (void)initUI{
    
    //添加collectionView
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    //该方法也可以设置itemSize
    layout.itemSize = CGSizeMake(self.bounds.size.width+PDMarginRight, self.bounds.size.height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    //2.初始化collectionView
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width+PDMarginRight, self.bounds.size.height) collectionViewLayout:layout];
    [self addSubview:_collectionView];
    
    //背景色
    _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    
    //3.设置代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    //4.注册collectionViewCell
    [_collectionView registerClass:[PDPhotoBrowserCell class] forCellWithReuseIdentifier:@"PDPhotoBrowserCell"];
    
    //滑动到选择下标
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    NSInteger count = self.images ? self.images.count : self.urls.count;
    //添加pageControll
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.bounds.size.width-200)*0.5, self.bounds.size.height-20-20, 200, 20)];
    _pageControl.numberOfPages = count;
    _pageControl.currentPage = _currentIndex;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _pageControl.hidden = NO;
    [self addSubview:_pageControl];
    
    if (count <= 1) {
        _pageControl.hidden = YES;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    _currentIndex = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    
    _pageControl.currentPage = _currentIndex;
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //本地图片
    if (self.images) {
        return self.images.count;
    }
    //网络图片
    return self.urls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PDPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PDPhotoBrowserCell" forIndexPath:indexPath];
    
    //本地图片
    if (self.images) {
         [cell setImage:self.images[indexPath.row]];
    }
    //网络图片
    else{
        
        if (!_urls || _urls.count <= 0) {
            NSLog(@"图片浏览器加载网络图片必须设置大图URL");
            return nil;
        }
        [cell setImageWithURL:_urls[indexPath.row]];
    }
    
    //单击cell退出图片浏览器
    __weak typeof(self) weakSelf = self;
    cell.singleTapHandle = ^{
        
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf removePhotoBrowser];
    };
    
    //长按弹出操作框
    cell.longPressHandle = ^{
        NSLog(@"cell长按了,执行删除操作在这里定义");
        
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.longPressHandle) {
            strongSelf.longPressHandle(indexPath.row);
        }
    };
    return cell;
}

@end
