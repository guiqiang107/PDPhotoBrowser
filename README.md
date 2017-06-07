# PDPhotoBrowser
基于collectionView实现的图片浏览器
/*
 * 查看本地图片
 * 用image数组快速创建图片浏览器
 * currentIndex 当前操作的下标
 * animateView 获取缩放返回的imageView的回调block
 */
+ (PDPhotoBrowser *)photoWithImages:(NSArray *)images currentIndex:(NSInteger)currentIndex animateView:(PDAnimateView)animateView;

/*
 * 查看网络图片
 * urls 大图的url数组
 * currentIndex 当前操作的下标
 * animateView 获取缩放返回的imageView的回调block
 */
+ (PDPhotoBrowser *)photoWithUrls:(NSArray *)urls currentIndex:(NSInteger)currentIndex animateView:(PDAnimateView)animateView;

![screenShot](https://github.com/guiqiang107/PDPhotoBrowser/raw/master/PDPhotoBrowserGif.gif)
