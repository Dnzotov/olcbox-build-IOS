#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

static AVAudioPlayer *olcboxSilentPlayer;
static NSData *olcboxSilentWaveData;

static NSData *OlcboxCreateSilentWaveData(void) {
    const uint32_t sampleRate = 8000;
    const uint16_t channels = 1;
    const uint16_t bitsPerSample = 16;
    const uint16_t blockAlign = channels * bitsPerSample / 8;
    const uint32_t byteRate = sampleRate * blockAlign;
    const uint32_t dataSize = sampleRate * blockAlign;
    const uint32_t riffSize = 36 + dataSize;

    NSMutableData *data = [NSMutableData dataWithCapacity:44 + dataSize];
    const char riff[] = "RIFF";
    const char wave[] = "WAVE";
    const char fmt[] = "fmt ";
    const char dataChunk[] = "data";
    const uint32_t fmtSize = 16;
    const uint16_t audioFormat = 1;

    [data appendBytes:riff length:4];
    [data appendBytes:&riffSize length:4];
    [data appendBytes:wave length:4];
    [data appendBytes:fmt length:4];
    [data appendBytes:&fmtSize length:4];
    [data appendBytes:&audioFormat length:2];
    [data appendBytes:&channels length:2];
    [data appendBytes:&sampleRate length:4];
    [data appendBytes:&byteRate length:4];
    [data appendBytes:&blockAlign length:2];
    [data appendBytes:&bitsPerSample length:2];
    [data appendBytes:dataChunk length:4];
    [data appendBytes:&dataSize length:4];

    NSMutableData *silence = [NSMutableData dataWithLength:dataSize];
    [data appendData:silence];
    return data;
}

static BOOL OlcboxIsTargetProcess(void) {
    return [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"org.olcbox.app.ios"];
}

static void OlcboxUpdateNowPlayingInfo(void) {
    MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo = @{
        MPMediaItemPropertyTitle: @"Olcbox",
        MPMediaItemPropertyArtist: @"Background connection keep-alive",
        MPMediaItemPropertyPlaybackDuration: @(24 * 60 * 60),
        MPNowPlayingInfoPropertyElapsedPlaybackTime: @0,
        MPNowPlayingInfoPropertyPlaybackRate: @1
    };
}

static void OlcboxStartSilentPlayback(void) {
    if (!OlcboxIsTargetProcess()) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        AVAudioSession *session = AVAudioSession.sharedInstance;
        NSError *error = nil;
        [session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:AVAudioSessionCategoryOptionMixWithOthers
                       error:&error];
        [session setActive:YES error:&error];

        if (!olcboxSilentWaveData) {
            olcboxSilentWaveData = OlcboxCreateSilentWaveData();
        }

        if (!olcboxSilentPlayer) {
            olcboxSilentPlayer = [[AVAudioPlayer alloc] initWithData:olcboxSilentWaveData error:&error];
            olcboxSilentPlayer.numberOfLoops = -1;
            olcboxSilentPlayer.volume = 0.0f;
            [olcboxSilentPlayer prepareToPlay];
        }

        if (!olcboxSilentPlayer.isPlaying) {
            [olcboxSilentPlayer play];
        }

        [UIApplication.sharedApplication beginReceivingRemoteControlEvents];
        OlcboxUpdateNowPlayingInfo();
    });
}

%ctor {
    if (!OlcboxIsTargetProcess()) {
        return;
    }

    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    NSArray<NSNotificationName> *notifications = @[
        UIApplicationDidFinishLaunchingNotification,
        UIApplicationDidBecomeActiveNotification,
        UIApplicationDidEnterBackgroundNotification
    ];

    for (NSNotificationName notificationName in notifications) {
        [center addObserverForName:notificationName
                            object:nil
                             queue:NSOperationQueue.mainQueue
                        usingBlock:^(__unused NSNotification *notification) {
            OlcboxStartSilentPlayback();
        }];
    }

    OlcboxStartSilentPlayback();
}