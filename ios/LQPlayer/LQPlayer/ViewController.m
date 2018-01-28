//
//  ViewController.m
//  LQPlayer
//
//  Created by 徐芃 on 2018/1/27.
//  Copyright © 2018年 徐芃. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()
@property(atomic, retain) id<IJKMediaPlayback> player;
@end

@implementation ViewController
-(void)detroyPlayer{
    [self.player shutdown];
    [self.view willRemoveSubview:self.player.view];
     self.player=nil;

}
- (void)initPlayer {
    if(self.player!=NULL){
        return;
    }
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setPlayerOptionIntValue:1 forKey:@"framedrop"];
    [options setPlayerOptionIntValue:0 forKey:@"packet-buffering"];  //  关闭播放器缓冲
    [options setPlayerOptionIntValue:100 forKey:@"analyzemaxduration"];  //  关闭播放器缓冲
    [options setPlayerOptionIntValue:10240 forKey:@"probesize"];
    [options setPlayerOptionIntValue:1 forKey:@"flush_packets"];
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[[NSURL alloc]initWithString:@"rtmp://20630.liveplay.myqcloud.com/live/20630_2d8c508f00e411e892905cb9018cf0d4"] withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.view.bounds;
    //    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFill;
    [self.view addSubview:self.player.view];
    [self.player prepareToPlay];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view from its nib.
    
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initPlayer];

    [self installMovieNotificationObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self detroyPlayer];

    [self removeMovieNotificationObservers];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self detroyPlayer];

}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self initPlayer];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    // Dispose of any resources that can be recreated.
}

- (void)timeUpdate:(NSNotification*)notification{
    NSLog(@"time update:%ld\n", [[[notification userInfo] valueForKey:@"time"] longLongValue]);
}


- (void)moviePlayBackStateDidChange:(NSNotification*)notification{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
   
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Remove Movie Notification Handlers



/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timeUpdate:)
                                                 name:IJKMPMoviePlayerTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
   [ [NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
    
    

}

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerTimeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}


@end
