//
//  PDPhotoBrowserCell.m
//  Panda
//
//  Created by guiq on 2017/6/5.
//  Copyright © 2017年 com.Xpand. All rights reserved.
//

#import "PDPhotoBrowserCell.h"
#import "UIImageView+WebCache.h"
#import "PDProgressView.h"

@interface PDPhotoBrowserCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) PDProgressView *progressView;

@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation PDPhotoBrowserCell

#pragma mark - public
/**
 *  设置本地图片
 */
- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self setMaxAndMinZoomScales];
    [self setNeedsLayout];
}

/**
 *  设置网络图片
 */
- (void)setImageWithURL:(NSString *)url{
    
    _progressView.hidden = NO;
    
    //默认的placeholder
    UIImage *placeholder = [UIImage imageNamed:@"photoBrowser_placeHolder@2x.png"];
    if (!self.imageView.image) {
         [self setImage:placeholder];
    }
   
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:SDWebImageRetryFailed| SDWebImageLowPriority| SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (expectedSize > 0) {
                // 修改进度
                self.progressView.progress = (CGFloat)receivedSize / expectedSize ;
            }
            [self resetZoomScale];
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        self.progressView.hidden = YES;
        if (error) {
            [self setMaxAndMinZoomScales];
            _stateLabel.hidden = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _stateLabel.hidden = YES;
            });
        } else {
            self.imageView.image = image;
            [self.imageView setNeedsDisplay];
            [UIView animateWithDuration:0.25 animations:^{
                [self setMaxAndMinZoomScales];
            }];
        }
    }];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //添加scrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-PDMarginRight, frame.size.height)];
        [self addSubview:_scrollView];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        //背景色
        _scrollView.backgroundColor= [UIColor colorWithWhite:0 alpha:1];
        
        //单击手势，退出图片浏览器
        UITapGestureRecognizer *singleTapScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapScrollView:)];
        [_scrollView addGestureRecognizer:singleTapScrollView];
        
//        //上滑和下滑手势，退出图片浏览器
//        UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapScrollView:)];
//        [swipeGes setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown)];
//        [_scrollView addGestureRecognizer:swipeGes];
        
        //双击手势，放大缩放图片
        UITapGestureRecognizer *doubleTapScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapScrollView:)];
        doubleTapScrollView.numberOfTapsRequired = 2;
        [singleTapScrollView requireGestureRecognizerToFail:doubleTapScrollView];
        [_scrollView addGestureRecognizer:doubleTapScrollView];
        
        //长按手势，弹出操作框
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressScrollView:)];
        [_scrollView addGestureRecognizer:longGes];
        
        //添加imageView
        _imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        [_scrollView addSubview:_imageView];
        
        //添加进度条
        _progressView = [[PDProgressView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _progressView.center = _scrollView.center;
        _progressView.hidden = YES;
        [self addSubview:_progressView];
        self.progressView.progress = 0;
        
        //添加状态提示label
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        _stateLabel.center = _scrollView.center;
        [self addSubview:_stateLabel];
        _stateLabel.text = @"图片加载失败...";
        _stateLabel.font = [UIFont systemFontOfSize:16];
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        _stateLabel.layer.cornerRadius = 5;
        _stateLabel.clipsToBounds = YES;
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.hidden = YES;

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize boundsSize = _scrollView.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) { // 长图才会出现这种情况
        frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(self.imageView.frame, frameToCenter)){
        self.imageView.frame = frameToCenter;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    _scrollView.scrollEnabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    _scrollView.userInteractionEnabled = YES;
}

#pragma mark - 手势处理,缩放图片

//单击退出图片浏览器
- (void)singleTapScrollView:(UIGestureRecognizer *)sender{
    if (self.singleTapHandle) {
        self.singleTapHandle();
    }
}

- (void)longPressScrollView:(UILongPressGestureRecognizer *)sender{
    
     if(sender.state == UIGestureRecognizerStateBegan){
         if (self.longPressHandle) {
             self.longPressHandle();
         }
    }
}

//双击放大
- (void)doubleTapScrollView:(UITapGestureRecognizer *)sender{
    _scrollView.userInteractionEnabled = NO;
    CGPoint point = [sender locationInView:sender.view];
    CGFloat touchX = point.x;
    CGFloat touchY = point.y;
    touchX *= 1/_scrollView.zoomScale;
    touchY *= 1/_scrollView.zoomScale;
    touchX += _scrollView.contentOffset.x;
    touchY += _scrollView.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

- (void)handleDoubleTap:(CGPoint)point
{
    _scrollView.userInteractionEnabled = NO;
    CGRect zoomRect = [self zoomRectForScale:[self willBecomeZoomScale] withCenter:point];
    [_scrollView zoomToRect:zoomRect animated:YES];
}

/**
 *  计算要伸缩到的目的比例
 */
- (CGFloat)willBecomeZoomScale
{
    if (_scrollView.zoomScale > _scrollView.minimumZoomScale) {
        return _scrollView.minimumZoomScale;
    } else {
        return _scrollView.maximumZoomScale;
    }
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGFloat height = _scrollView.frame.size.height / scale;
    CGFloat width  = _scrollView.frame.size.width  / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

/**
 *  根据图片和屏幕比例关系,调整最大和最小伸缩比例
 */
- (void)setMaxAndMinZoomScales
{
    // self.photoImageView的初始位置
    UIImage *image = self.imageView.image;
    if (image == nil || image.size.height == 0) {
        return;
    }
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    
    CGRect imageViewFrame = CGRectZero;
    imageViewFrame.size.width = _scrollView.frame.size.width;
    imageViewFrame.size.height = _scrollView.frame.size.width / imageWidthHeightRatio;
    imageViewFrame.origin.x = 0;
    
    //垂直方向长图
    if (imageViewFrame.size.height > _scrollView.frame.size.height) {
        imageViewFrame.origin.y = 0;
        _scrollView.scrollEnabled = YES;
    } else {
         imageViewFrame.origin.y = (_scrollView.frame.size.height -  imageViewFrame.size.height ) * 0.5;
        _scrollView.scrollEnabled = NO;
    }
    
    self.imageView.frame = imageViewFrame;

    _scrollView.maximumZoomScale = MAX(_scrollView.frame.size.height / self.imageView.bounds.size.height, 3.0);
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.zoomScale = 1.0;
    _scrollView.contentSize = CGSizeMake(imageViewFrame.size.width, MAX(imageViewFrame.size.height, _scrollView.frame.size.height));
}

- (void)resetZoomScale
{
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.minimumZoomScale = 1.0;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.progressView.hidden = YES;
    _stateLabel.hidden = YES;
    self.progressView.progress = 0;
    [self resetZoomScale];
}

@end
