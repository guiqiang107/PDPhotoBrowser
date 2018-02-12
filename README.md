## 实现效果

![PhotoBrowser.gif](https://github.com/guiqiang107/PDPhotoBrowser/raw/master/PhotoBrowser.gif)


## 目录结构
![image.png](http://upload-images.jianshu.io/upload_images/3286073-28ce6ba596712f0d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 调用方法

1. 不带过渡动画,直接添加图片浏览器到window上
```
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

```

2. 附带微信图片浏览器一样的过渡动画
```
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

```

## 实现原理
1. 利用UICollectionView实现图片浏览
2. UICollectionView的Cell底部是一个UIScrollView，在_scrollView上添加UIImageView用来展示图片，添加自定义的progressView用来显示加载进度
3. UICollectionView的Cell添加单击手势退出图片浏览器，双击手势放大图片，长按手势弹出操作框
4. 根据图片和屏幕比例关系,调整最大和最小伸缩比例，和换算长图的宽高
- 如果图片宽度比屏幕宽度小，将图片设置为屏幕等宽，根据比例换算高度
- 如果图片是横向长图，调整imageView大小为图片实际尺寸将_scrollView的contentSize宽度设置为图片实际宽度，调整imageView的center，设置_scrollView的contentSize确保横向滚动
- 如果图片是竖向长图，调整imageView大小为图片实际尺寸将_scrollView的contentSize高度设置为图片实际高度，调整imageView的center，设置_scrollView的contentSize确保众向滚动
- 设置_scrollView的最大最小缩放比例
```
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
```
5. 添加打开图片浏览器和退出时的过渡动画
- 先获取点击的view，将view从原父容器坐标转换到图片浏览器的坐标，记为开始坐标
- 换算view动画完成的坐标，记为目的坐标
- 创建一个临时的动画view，来完成从开始坐标到目的坐标的动画
- 退出图片浏览器的动画反之
```
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
```

>`PDPhotoBrowser`是基于collectionView实现的图片浏览器，详情请点击[简书地址](https://www.jianshu.com/p/c7bba6c76cd4)

