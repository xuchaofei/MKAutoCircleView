//
//  MKAutoCircleView.m
//  CustomAutoScroll
//
//  Created by csm on 2017/9/8.
//  Copyright © 2017年 YiJu. All rights reserved.
//

#import "MKAutoCircleView.h"
#import "AdvisementViewController.h"

@interface MKAutoCircleView ()<UIScrollViewDelegate> {
    
    
    NSMutableArray * _changeMutableArray;
    NSMutableArray * _weburlsArray;
    
    //当前展示的图片的索引。
    NSInteger _pageIndex;
    
    //当前张图片。
    UIImageView* _currentImageView;
    
    //上一张图片。
    UIImageView* _lastImageView;
    
    //下一张图片。
    UIImageView* _nextImageView;
    
    UIImageView * _selectedImageView;
    
}
@property (nonatomic, weak)UIPageControl *pageControl;
@property (nonatomic, strong)UIScrollView * scrollView;
@property (nonatomic, weak)NSTimer *timer;


@end

@implementation MKAutoCircleView

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

-(void)setImages:(NSArray *)images{

    _images = images;
    [self setUpUI];
}

-(void)setUrls:(NSArray *)urls{

    _urls = urls;
    

}

-(void)setTimeInterval:(NSInteger)timeInterval{

    _timeInterval = timeInterval;
    [self addTimer];

}

-(void)addTimer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

-(void)deleteTimer{
    [_timer invalidate];
    _timer = nil;
}


-(void)autoScroll{
    if (_images.count ==  2) {
        if (_pageIndex%2 == 0) {
            _pageControl.currentPage = 0;
        }else{
            _pageControl.currentPage = 1;
        }
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 2, 0) animated:YES];

    }else if (_images.count > 2){
        _pageControl.currentPage = _pageIndex;
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 2, 0) animated:YES];

    }else if (_images.count == 1){
        _pageControl.currentPage = 0;
    }

}

-(void)setUpUI{
    
    _changeMutableArray = [self.images mutableCopy];

    if (_images.count == 2) {
        [_changeMutableArray addObjectsFromArray:_images];
    }
    
    
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
        if (_images.count == 1) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_images[0]];
            imageView.userInteractionEnabled = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];

            [_scrollView addSubview:imageView];
            
            _scrollView.contentOffset = CGPointZero;
            
            UITapGestureRecognizer  *imageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(skitToWebview:)];
            [imageView addGestureRecognizer:imageTap];
            
        }else{
            //无论有多少数据，只创建三个 UIImageView，分别表示，上一张，当前，下一张。
            for (NSInteger i = 0; i < 3; i++) {
                
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.frame.size.height)];
                imageView.userInteractionEnabled = YES;

                if (_images.count == 2) {
                    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_changeMutableArray[i]];
                    
                    [imageView sd_setImageWithURL:[NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

                }else{
                    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_images[i]];
                    
                    [imageView sd_setImageWithURL:[NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

                }
                [_scrollView addSubview:imageView];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(skitToWebview:)];
                [imageView addGestureRecognizer:tap];
                
                switch (i) {
                    case 0:{
                        
                        _lastImageView = imageView;
                    }
                        break;
                    case 1:{
                        
                        _currentImageView = imageView;
                    }
                        break;
                    case 2:{
                        
                        _nextImageView = imageView;
                    }
                        break;
                    default:
                        break;
                }
            }
            if (_images.count == 1) {
                _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.frame.size.height);
            }else if (_images.count > 1){
                _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, self.frame.size.height);
            }
            //设置偏移量在中间，初始的时候能够左右滑动。
            _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
        }
        
        _scrollView.pagingEnabled = YES;
        
        _scrollView.bounces = NO;
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        //通过协议方法，控制滑动。
        _scrollView.delegate = self;
    
        //默认的展示的数据内容索引。
        _pageIndex = 1;
        
        [self addSubview:_scrollView];
        
        UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.frame.size.height-30, SCREEN_WIDTH,30)];
        pageControl.currentPage = 0;
        pageControl.numberOfPages = _images.count;
        pageControl.pageIndicatorTintColor = [UIColor blackColor];
        pageControl.currentPageIndicatorTintColor = WhiteColor;
        pageControl.hidesForSinglePage = YES;
        [self addSubview:pageControl];
        _pageControl = pageControl;
    
}

-(void)skitToWebview:(UITapGestureRecognizer *)tap{
    
    _selectedImageView = (UIImageView *)tap.view;
    
    _weburlsArray = [self.urls mutableCopy];
    
    if (_images.count == 2) {
        
        [_weburlsArray addObjectsFromArray:_urls];
    }

    if (_images.count == 1) {
        AdvisementViewController *adviseVC = [[AdvisementViewController alloc]init];
        adviseVC.URLStr = _urls[0];
        [[self viewController].navigationController pushViewController:adviseVC animated:YES];
    }else{
        NSString *URLStr;
        if (_lastImageView == _selectedImageView) {
            if (_pageIndex-1 < 0) {
                URLStr = [NSString stringWithFormat:@"%@",[_weburlsArray lastObject]];
            }else{
                URLStr = [NSString stringWithFormat:@"%@",_weburlsArray[_pageIndex-1]];
            }
        }else if (_currentImageView == _selectedImageView){
            URLStr = [NSString stringWithFormat:@"%@",_weburlsArray[_pageIndex]];
            
        }else if (_nextImageView == _selectedImageView){
            if (_pageIndex+1 > _weburlsArray.count-1) {
                URLStr = [NSString stringWithFormat:@"%@",[_weburlsArray firstObject]];
            }else{
                URLStr = [NSString stringWithFormat:@"%@",_weburlsArray[_pageIndex+1]];
            }
        }
        
        AdvisementViewController *adviseVC = [[AdvisementViewController alloc]init];
        adviseVC.URLStr = URLStr;
        adviseVC.backInfo = @"";
        [[self viewController].navigationController pushViewController:adviseVC animated:YES];
    
    }

}
#pragma 获取view的父视图的跟控制器
- (UIViewController *)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
#pragma mark - UIScrollViewDelegate

//为了实现连续的滚动，到了边界需要重置 contentOffset.x 为中间 view 的位置。
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_images.count > 1){
        if (_images.count == 2) {
            
            if (_pageIndex%2 == 0) {
                _pageControl.currentPage = 0;
            }else{
                _pageControl.currentPage = 1;
            }
        }
        if (_scrollView.contentOffset.x == 0.0f) {
            
            //到左边界了。
            
            //重置偏移量，使能够继续滑动。
            _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
            
            //重置数据
            
            _pageIndex--;
            
            //如果前边没有了，就展示最后一张的数据。
            if (_pageIndex < 0) {
                
                _pageIndex = _changeMutableArray.count - 1;
            }
            NSString *currentImageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_changeMutableArray[_pageIndex]];
            
            [_currentImageView sd_setImageWithURL:[NSURL URLWithString:[currentImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
           // _currentImageView.image = _changeMutableArray[_pageIndex];
            
            
            NSInteger last = _pageIndex - 1;
            
            if (last < 0) {
                
                last = _changeMutableArray.count - 1;
            }
            
            NSString *lastImageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_changeMutableArray[last]];
            
            [_lastImageView sd_setImageWithURL:[NSURL URLWithString:[lastImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//            _lastImageView.image = _changeMutableArray[last];
            
            NSInteger next = _pageIndex + 1;
            
            if (next == _changeMutableArray.count) {
                
                next = 0;
            }
            NSString *nextImageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_changeMutableArray[next]];
            
            [_nextImageView sd_setImageWithURL:[NSURL URLWithString:[nextImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            //_nextImageView.image = _changeMutableArray[next];
            
        }else if (_scrollView.contentOffset.x == _scrollView.frame.size.width * 2) {
            
            //到右边界了。
            
            //重置偏移量，使能够继续滑动。
            _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
            
            //重置数据
            
            _pageIndex++;
            
            //如果后边没有了，就展示第一张的数据。
            if (_pageIndex == _changeMutableArray.count) {
                
                _pageIndex = 0;
            }
            
            NSString *currentImageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_changeMutableArray[_pageIndex]];
            
            [_currentImageView sd_setImageWithURL:[NSURL URLWithString:[currentImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
           // _currentImageView.image = _changeMutableArray[_pageIndex];
            
            
            NSInteger last = _pageIndex - 1;
            
            if (last < 0) {
                
                last = _changeMutableArray.count - 1;
            }
            NSString *lastImageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_changeMutableArray[last]];
            
            [_lastImageView sd_setImageWithURL:[NSURL URLWithString:[lastImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            //_lastImageView.image = _changeMutableArray[last];
            
            NSInteger next = _pageIndex + 1;
            
            if (next == _changeMutableArray.count) {
                
                next = 0;
            }
            NSString *nextImageUrl = [NSString stringWithFormat:@"%@%@",app_image_url,_changeMutableArray[next]];
            
            [_nextImageView sd_setImageWithURL:[NSURL URLWithString:[nextImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
           // _nextImageView.image = _changeMutableArray[next];

        }
    }
}

//拖拽开始的时候，暂停定时器。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    //fireDate，启动时间。
    //distantFuture，一个永远也到不了的时间。
    //暂停定时器。
   // _timer.fireDate = [NSDate distantFuture];
    
    [self deleteTimer];
}

//结束减速，开启定时器。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //一个已经过去的时间。
    //开启定时器。
    //_timer.fireDate = [NSDate distantPast];
    
    [self addTimer];
}



@end
