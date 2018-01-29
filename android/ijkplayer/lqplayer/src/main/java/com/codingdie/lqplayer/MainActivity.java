package com.codingdie.lqplayer;

import android.app.Activity;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;

import com.codingdie.lqplayer.media.IjkVideoView;

import java.text.SimpleDateFormat;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.logging.SimpleFormatter;

import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;

public class MainActivity extends Activity {

    private IjkVideoView ijkVideoView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);//remove title bar  即隐藏标题栏
        setContentView(R.layout.activity_main);

        IjkMediaPlayer.loadLibrariesOnce(null);
        IjkMediaPlayer.native_profileBegin("libijkplayer.so");
        ijkVideoView=findViewById(R.id.player);
        ijkVideoView.setVideoURI(Uri.parse("rtmp://20630.liveplay.myqcloud.com/live/20630_2d8c508f00e411e892905cb9018cf0d4"));
        ijkVideoView.setmOnTimeListener(new IMediaPlayer.OnTimeListener() {
            @Override
            public boolean onTime(IMediaPlayer mp, long time) {
                Log.i("time", new SimpleDateFormat("yyyy-MM-dd  HH:mm:ss.SSS").format(new Date(time)));
                return false;
            }
        });
        ijkVideoView.setOnInfoListener(new IMediaPlayer.OnInfoListener() {
            @Override
            public boolean onInfo(IMediaPlayer mp, int what, int extra) {
                Log.i("info", what+"/"+extra);

                return false;
            }
        });
        ijkVideoView.start();
     }


    @Override
    protected void onStop() {
        super.onStop();
        ijkVideoView.stopPlayback();
        ijkVideoView.release(true);
        IjkMediaPlayer.native_profileEnd();
    }
}

