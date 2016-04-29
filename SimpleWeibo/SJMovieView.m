//
//  SJMovieView.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/26.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "SJMovieView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

NS_ENUM(NSInteger, PlayerState){
    PlayerStateBuffering,
    PlayerStatePlaying,
    PlayerStateStopped,
    PlayerStatePause,
};

#define SJMoviewViewHeight 180

@interface SJMovieView ()

@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerItem*playerItem;
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) UISlider *videoSlider;
@property(nonatomic, strong) UILabel *currentTimeLabel;
@property(nonatomic, strong) UILabel * totalTimeLabel;
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) UIButton *fullScreenBtn;
@property(nonatomic, strong) UIButton *startBtn;
@property(nonatomic, strong) UIActivityIndicatorView *activity;
@property(nonatomic, assign) BOOL isPauseByUser;
@property(nonatomic, assign) BOOL isDragSlider;
@property(nonatomic, assign) enum PlayerState playState;

@property(nonatomic, assign) CGRect smallFrame;
@property(nonatomic, assign) CGRect bigFrame;

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIButton *button;


@end

@implementation SJMovieView

-(instancetype)init
{
    self = [super init];
    if(self){
        [self setupView];
    }
    return self;
}

-(void)setupView
{
//    self.startBtn = [[UIButton alloc] init];
//    [self.startBtn setImage:[UIImage imageNamed:@"video_player_play"] forState:UIControlStateNormal];
//    [self.startBtn addTarget:self action:@selector(startBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.startBtn];
//    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.mas_left);
//        make.bottom.mas_equalTo(self.mas_bottom);
//        make.size.mas_equalTo(CGSizeMake(50, 50));
//    }];
//    
//    self.currentTimeLabel = [[UILabel alloc] init];
//    self.currentTimeLabel.text = @"00:00";
//    self.currentTimeLabel.textColor = [UIColor whiteColor];
//    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
//    self.currentTimeLabel.font = [UIFont systemFontOfSize:15];
//    [self addSubview:self.currentTimeLabel];
//    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.mas_bottom);
//        make.left.mas_equalTo(self.startBtn.mas_right);
//        make.width.mas_equalTo(60);
//    }];
//    
//    self.fullScreenBtn = [[UIButton alloc] init];
//    [self.fullScreenBtn setImage:[UIImage imageNamed:@"video_player_fullscreen"] forState:UIControlStateNormal];
//    [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.fullScreenBtn];
//    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.mas_right);
//        make.bottom.mas_equalTo(self.mas_bottom);
//        make.size.mas_equalTo(CGSizeMake(50, 50));
//    }];
//    
//    self.totalTimeLabel = [[UILabel alloc] init];
//    self.totalTimeLabel.text = @"00:00";
//    self.totalTimeLabel.textColor = [UIColor whiteColor];
//    self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
//    self.totalTimeLabel.font = [UIFont systemFontOfSize:15];
//    [self addSubview:self.totalTimeLabel];
//    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.mas_bottom);
//        make.right.mas_equalTo(self.fullScreenBtn.mas_left);
//        make.width.mas_equalTo(60);
//    }];
//    
//    self.videoSlider = [[UISlider alloc] init];
//    [self.videoSlider setThumbImage:[UIImage imageNamed:@"Slider"] forState:UIControlStateNormal];
//    self.videoSlider.minimumTrackTintColor = [UIColor whiteColor];
//    self.videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
//    [self.videoSlider addTarget:self action:@selector(videoSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
//    [self.videoSlider addTarget:self action:@selector(videoSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//    [self.videoSlider addTarget:self action:@selector(videoSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
//    [self addSubview:self.videoSlider];
//    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.currentTimeLabel.mas_right);
//        make.right.mas_equalTo(self.totalTimeLabel.mas_left);
//        make.bottom.mas_equalTo(self.mas_bottom);
//    }];
//    
//    self.progressView = [[UIProgressView alloc] init];
//    self.progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
//    self.progressView.trackTintColor = [UIColor clearColor];
//    [self addSubview:self.progressView];
//    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.mas_bottom);
//        make.left.mas_equalTo(self.currentTimeLabel.mas_right);
//        make.right.mas_equalTo(self.totalTimeLabel.mas_left);
//    }];
//    
//    
//    self.player = [AVPlayer playerWithURL:[NSURL URLWithString:@""]];
//    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    
//    if([self.playerLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]){
//        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    }else{
//        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    }
//    
//    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGound) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [self listeningRotating];
//    [self setTheProgressOfPlayTime];
//    
    self.fullScreenBtn.hidden = YES;
    self.currentTimeLabel.hidden = YES;
    self.progressView.hidden = YES;
    self.videoSlider.hidden = YES;
    self.totalTimeLabel.hidden = YES;
    self.startBtn.hidden = YES;
    self.activity.hidden = YES;
    
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SJMoviewViewHeight, SJMoviewViewHeight));
        make.center.mas_equalTo(self.center);
    }];
    
    self.button = [[UIButton alloc] init];
    [self addSubview:self.button];
    [self.button setImage:[UIImage imageNamed:@"multimedia_videocard_play"] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SJMoviewViewHeight, SJMoviewViewHeight));
        make.center.mas_equalTo(self.center);
    }];
    
    
}

-(void)setMediaInfo:(NSDictionary *)mediaInfo
{
    _mediaInfo = mediaInfo;
    NSString *str = [[mediaInfo objectForKey:@"pic_info"] objectForKey:@"pic_middle"][@"url"];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:str]];
}

-(void)buttonClicked:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:[self.mediaInfo objectForKey:@"page_url"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:RespondToCellButton object:url userInfo:@{WhichType:MovieViewClicked}];
}

+(CGFloat)getMovieViewHeight
{
    return SJMoviewViewHeight;
}

-(void)setTheProgressOfPlayTime
{
    __weak typeof (self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if(weakSelf.isDragSlider){
            return ;
        }
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([weakSelf.playerItem duration]);
        if(current){
            [weakSelf.videoSlider setValue:(current/total) animated:YES];
        }
        
        NSInteger proSec = (NSInteger) current % 60;
        NSInteger proMin = (NSInteger) current / 60;
        
        NSInteger durSec = (NSInteger) total % 60;
        NSInteger durMin = (NSInteger) total / 60;
        
        weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"%02zdd:%02zd", proMin, proSec];
        weakSelf.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    }];
}

-(void)videoSliderTouchEnded:(UISlider*)sender
{
    CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
    NSInteger dragedSeconds = floorf(total * sender.value);
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [self endSliderTheVideo:dragedCMTime];
}

-(void)videoSliderTouchBegan:(UISlider*)sender
{
    
    self.isDragSlider = YES;
}

-(void)videoSliderValueChanged:(UISlider*)sender
{
    CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
    CGFloat current = total * sender.value;
    NSInteger proSec = (NSInteger)current % 60;
    NSInteger proMin = (NSInteger)current / 60;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
}

-(void)endSliderTheVideo:(CMTime)dragedCMTime
{
    [self.player pause];
    [self.activity startAnimating];
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
        [self.activity stopAnimating];
        if(self.isPauseByUser){
            self.isDragSlider = NO;
            return ;
        }
        if((self.progressView.progress - self.videoSlider.value) < 0.01){
            [self.activity stopAnimating];
            [self.player play];
        }else{
            [self bufferForSeconds];
        }
        self.isDragSlider = NO;
    }];
}

-(void)startBtnClicked:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if(sender.selected){
        self.isPauseByUser = NO;
        [self.player play];
        self.playState = PlayerStatePlaying;
    }else{
        [self.player pause];
        self.isPauseByUser = YES;
        self.playState = PlayerStatePause;
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

-(void)setPlayState:(enum PlayerState)playState
{
    if(playState != PlayerStateBuffering){
        [self.activity stopAnimating];
    }
    _playState = playState;
}

-(void)setVideoURL:(NSURL *)videoURL
{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.playerItem = nil;
    
    self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.player play];
    self.startBtn.selected = YES;
    self.playState = PlayerStatePlaying;
    [self.activity startAnimating];
}

-(void)moviePlayDidEnd:(NSNotification*)noti
{
    [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
        [self.videoSlider setValue:0.0 animated:YES];
        self.currentTimeLabel.text = @"00:00";
    }];
    self.playState = PlayerStateStopped;
    self.startBtn.selected = NO;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if(object == self.playerItem){
        if([keyPath isEqualToString:@"status"]){
            if(self.player.status == AVPlayerStatusReadyToPlay){
                self.playState = PlayerStatePlaying;
            }else if(self.player.status == AVPlayerStatusFailed){
                [self.activity startAnimating];
            }
        }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration = self.playerItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            [self.progressView setProgress: timeInterval / totalDuration animated:NO];
        }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){
            if(self.playerItem.playbackBufferEmpty){
                self.playState = PlayerStateBuffering;
                [self bufferForSeconds];
            }
        }
    }
}

-(void)bufferForSeconds
{
    [self.activity startAnimating];
    static BOOL isBuffering = NO;
    if(isBuffering){
        return;
    }
    isBuffering = YES;
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.isPauseByUser){
            isBuffering = NO;
            return ;
        }
        isBuffering = NO;
        if((self.progressView.progress - self.videoSlider.value) > 0.01){
            self.playState = PlayerStatePlaying;
            [self.player play];
        }else{
            [self bufferForSeconds];
        }
    });
}

-(NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSec = CMTimeGetSeconds(timeRange.start);
    float durSec = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSec + durSec;
    return result;
}

-(void)appDidEnterBackground
{
    [self.player pause];
}

-(void)appDidEnterPlayGound
{
    [self.player play];
}

-(void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]){
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(void)fullScreenBtnClicked:(UIButton*)sender
{
    sender.selected = !sender.selected;
    [self setInterfaceOrientation:sender.selected ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
}

-(void)listeningRotating{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)onDeviceOrientationChange{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    [self transformScreenDiretion:interfaceOrientation];
}

-(void)transformScreenDiretion:(UIInterfaceOrientation)direction
{
    if(direction == UIInterfaceOrientationPortrait){
        self.frame = self.smallFrame;
    }else{
        self.frame = self.bigFrame;
    }
}

@end
