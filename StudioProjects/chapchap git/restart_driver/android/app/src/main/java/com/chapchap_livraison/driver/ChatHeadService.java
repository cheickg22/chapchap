package com.chapchap_livraison.driver;

import com.chapchap_livraison.driver.MainActivity;
import java.util.Random;
import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.ImageView;
import android.graphics.Rect;
import android.content.pm.ServiceInfo;

import androidx.core.app.NotificationCompat;


public class ChatHeadService extends Service {

    private WindowManager mWindowManager;
    private View mChatHeadView;
    private View closeBtnView;
    private ImageView chatHeadImage;
    private ImageView closeBtnImage;

    private WindowManager.LayoutParams quicknavParams;
    private Animation showAnimation;
    private Animation hideAnimation;

    double screenHeight = 0.0;
    double screenWidth = 0.0;
    double density = 0.0f;
    double navigationBarHeight = 0.0f;
    boolean stopService = false;
    String chatHeadIcon = "";
    String notificationIcon = "";
    String notificationTitle = "";
    String notificationBody = "";
    int notificationIconIdentifier = 0;
    long notificationCircleHexColor = 0;

    final Handler handler = new Handler(Looper.getMainLooper());

    int chatHeadPadding = 0;
    public static final int NOTIFICATION_ID = new Random().nextInt(10000);

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    @SuppressLint({"ClickableViewAccessibility"})
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Handle null intent (service restarted by system)
        if (intent == null) {
            // Stop the service if restarted without proper initialization
            stopSelf();
            return START_NOT_STICKY;
        }
        
        screenHeight = intent.getDoubleExtra("height",0.0);
        screenWidth = intent.getDoubleExtra("width",0.0);
        density = intent.getDoubleExtra("density",0.0);
        navigationBarHeight = intent.getDoubleExtra("navigationBarHeight",0.0);
        stopService = intent.getBooleanExtra("stopService",false);
        chatHeadIcon = intent.getStringExtra("chatHeadIcon");
        notificationIcon = intent.getStringExtra("notificationIcon");
        notificationTitle = intent.getStringExtra("notificationTitle");
        notificationBody = intent.getStringExtra("notificationBody");
        notificationCircleHexColor = intent.getLongExtra("notificationCircleHexColor",0);
        //Setting notification icon and Chat head iconmohamed_nasr@unifisolutions.io
        if(notificationIcon != null){
            notificationIconIdentifier = getApplicationContext().getResources().getIdentifier(notificationIcon, "drawable", getApplicationContext().getPackageName());
        }
        if(chatHeadIcon != null && chatHeadImage != null){
            int identifier = getApplicationContext().getResources().getIdentifier( chatHeadIcon, "drawable", getApplicationContext().getPackageName());
            if(identifier != 0) {
                chatHeadImage.setImageResource(identifier);
            }
        }


        if(stopService){
            stopSelf();
            return Service.START_NOT_STICKY;
        }

        createNotificationChannel();
        closeBtnView.setVisibility(View.INVISIBLE);

        //Delay ZERO (nothing) to bind xml component in view
        handler.postDelayed(() -> {
            showAnimation = new TranslateAnimation(0, 0,closeBtnView.getHeight(), 0);
            showAnimation.setDuration(500);
            showAnimation.setFillAfter(true);

            hideAnimation = new TranslateAnimation(0, 0,0, closeBtnView.getHeight());
            hideAnimation.setDuration(500);
            hideAnimation.setFillAfter(true);
            //Start with hide close btn
            toggleAnimation(closeBtnImage,hideAnimation);

            chatHeadImage.setOnTouchListener(new View.OnTouchListener() {
                private int lastAction;
                private int initialX;
                private int initialY;
                private float initialTouchX;
                private float initialTouchY;

                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    switch (event.getAction()) {
                        case MotionEvent.ACTION_DOWN:
                            if(navigationBarHeight <= 24 && navigationBarHeight > 0){
                                //Padding from left                     //Padding from right
                                if(event.getRawX() < 60 || event.getRawX()> (screenWidth-60)) return false;
                            }
                            //Show Close Btn First
                            toggleAnimation(closeBtnImage,showAnimation);
                            closeBtnView.setVisibility(View.VISIBLE);

                            //remember the initial position.
                            initialX  = quicknavParams.x;
                            initialY = quicknavParams.y;

                            //get the touch location
                            initialTouchX = event.getRawX();
                            initialTouchY = event.getRawY();

                            lastAction = event.getAction();
                            return true;

                        case MotionEvent.ACTION_UP:
                            toggleAnimation(closeBtnImage,hideAnimation);
                            handler.postDelayed(()->closeBtnView.setVisibility(View.INVISIBLE),400);
                            if (isViewOverlapping(mChatHeadView, closeBtnView)) {
                                stopSelf();
                            }

                            if(quicknavParams.x >= screenWidth / 2){
                                quicknavParams.x = (int) screenWidth - chatHeadImage.getWidth() - chatHeadPadding;
                            }
                            else {
                                quicknavParams.x = chatHeadPadding;
                            }
                            quicknavParams.y = initialY + (int) (event.getRawY() - initialTouchY);

                            mWindowManager.updateViewLayout(mChatHeadView, quicknavParams);

                            if (lastAction == MotionEvent.ACTION_DOWN) {

                                Intent intent = new Intent();

                                intent.setClassName(getPackageName(), getPackageName()+".MainActivity");
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                startActivity(intent);

                                //close the service and remove the chat heads
                                stopSelf();
                            } else {
                                double heightOfCloseBtnImage = closeBtnImage.getHeight();
                                double heightOfCloseBtnView = closeBtnView.getHeight();

                                boolean insideLeftSideOfCloseBtn = event.getRawX() > (screenWidth / 2) - (heightOfCloseBtnImage / 2);
                                boolean insideRightSideOfCloseBtn = event.getRawX() < (screenWidth / 2) + ( heightOfCloseBtnImage / 2);
                                boolean reachTheBottomOfScreen = event.getRawY() > (screenHeight - (heightOfCloseBtnView + (heightOfCloseBtnView/2)));

                                if(reachTheBottomOfScreen && insideLeftSideOfCloseBtn && insideRightSideOfCloseBtn){
                                    //Update Chat Head position to be center of screen
                                    quicknavParams.y = (int) (heightOfCloseBtnView - heightOfCloseBtnImage);
                                    mWindowManager.updateViewLayout(mChatHeadView, quicknavParams);
                                    // Start Animation
                                    toggleAnimation(closeBtnImage,hideAnimation);
                                    toggleAnimation(chatHeadImage,hideAnimation);
                                    handler.postDelayed(()->{
                                        closeBtnView.setVisibility(View.INVISIBLE);
                                        chatHeadImage.setVisibility(View.INVISIBLE);
                                    },450);
                                    //Show notification
                                    showServiceNotification();
                                }
                            }
                            lastAction = event.getAction();
                            return true;

                        case MotionEvent.ACTION_MOVE:
                            double heightOfCloseBtnImage = closeBtnImage.getHeight();
                            double heightOfCloseBtnView = closeBtnView.getHeight();

                            boolean insideLeftSideOfCloseBtn = event.getRawX() > (screenWidth / 2) - (heightOfCloseBtnImage / 2);
                            boolean insideRightSideOfCloseBtn = event.getRawX() < (screenWidth / 2) + ( heightOfCloseBtnImage / 2);
                            boolean reachTheBottomOfScreen = event.getRawY() > (screenHeight - (heightOfCloseBtnView + (heightOfCloseBtnView/2)));

                            if(reachTheBottomOfScreen && insideLeftSideOfCloseBtn && insideRightSideOfCloseBtn) {
                                quicknavParams.gravity = Gravity.BOTTOM;
                                quicknavParams.y = (int) (heightOfCloseBtnView - heightOfCloseBtnImage);
                                quicknavParams.x =  0;
                            }
                            else {
                                quicknavParams.gravity = Gravity.TOP | Gravity.START;
                                quicknavParams.y = initialY + (int) (event.getRawY() - initialTouchY);
                                quicknavParams.x = initialX + (int) (event.getRawX() - initialTouchX);
                            }
                            //Update the layout with new X & Y coordinate
                            mWindowManager.updateViewLayout(mChatHeadView, quicknavParams);
                            if( Math.abs(initialX - quicknavParams.x) > 10 || Math.abs(initialY - quicknavParams.y) > 10 ){
                                lastAction = event.getAction();
                            }
                            return true;
                    }
                    return false;
                }

            });
        }, 0);

        return super.onStartCommand(intent, flags, startId);
    }

    @SuppressLint("InflateParams")
    @Override
    public void onCreate() {
        super.onCreate();
        
        // IMPORTANT: Call startForeground immediately to avoid ForegroundServiceDidNotStartInTimeException
        try {
            createNotificationChannel();
            startForegroundNotification();
        } catch (Exception e) {
            // If startForeground fails, stop the service to prevent crash
            stopSelf();
            return;
        }
        
        try {
            //Inflate the views layout we created
            mChatHeadView = LayoutInflater.from(this).inflate(R.layout.layout_bubble, null);
            closeBtnView = LayoutInflater.from(this).inflate(R.layout.close_button_layout, null);

            //Get chat head from xml
            chatHeadImage = mChatHeadView.findViewById(R.id.chat_head_profile_iv);

            //Get close button view and prepare their animation
            closeBtnImage = closeBtnView.findViewById(R.id.close_btn);


            int LAYOUT_FLAG ;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                LAYOUT_FLAG = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
            } else {
                LAYOUT_FLAG = WindowManager.LayoutParams.TYPE_PHONE;
            }

            //init chat head view to the window.
             quicknavParams = createWindow(LAYOUT_FLAG);
            quicknavParams.x = chatHeadPadding;
            quicknavParams.y = 120;
            quicknavParams.gravity = Gravity.TOP | Gravity.START;

            //init close button view to the window.
            WindowManager.LayoutParams closeBtnParams = createWindow(LAYOUT_FLAG);
            closeBtnParams.gravity = Gravity.BOTTOM | Gravity.CENTER;

            mWindowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
            
            if (mWindowManager == null) {
                stopSelf();
                return;
            }

            // add the views layout to window manager with error handling
            try {
                mWindowManager.addView(mChatHeadView, quicknavParams);
                mWindowManager.addView(closeBtnView, closeBtnParams);
            } catch (WindowManager.BadTokenException e) {
                // Window token is invalid, stop service
                stopSelf();
                return;
            }
        } catch (Exception e) {
            // If view initialization fails, stop the service
            stopSelf();
        }
    }
    
    private void startForegroundNotification() {
        Intent intent = new Intent();
        intent.setClassName(getPackageName(), getPackageName()+".MainActivity");
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        intent.setAction(Intent.ACTION_MAIN);

        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE);
        String channelId = getString(R.string.channel_id);

        Notification notification = new NotificationCompat.Builder(this, channelId)
                .setSmallIcon(R.drawable.logo)
                .setContentTitle("Luigo Driver")
                .setContentText("Service actif")
                .setOngoing(true)
                .setContentIntent(pendingIntent)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE);
        } else {
            startForeground(NOTIFICATION_ID, notification);
        }
    }


    private WindowManager.LayoutParams createWindow(int LAYOUT_FLAG){
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                LAYOUT_FLAG,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE | WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
                PixelFormat.TRANSPARENT);
        
        // Set format to reduce GPU rendering issues
        params.format = PixelFormat.TRANSLUCENT;
        
        return params;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            String channelID = getString(R.string.channel_id);
            String channelName = getString(R.string.channel_name);
            String channelDescription = getString(R.string.channel_description);
            NotificationChannel channel = new NotificationChannel(channelID, channelName, importance);
            channel.setDescription(channelDescription);

            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private void showServiceNotification() {
        Intent intent = new Intent();
        intent.setClassName(getPackageName(), getPackageName()+".MainActivity");
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        intent.setAction(Intent.ACTION_MAIN);

        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE);
        String channelId = getString(R.string.channel_id);

        Notification builder = new NotificationCompat.Builder(this,channelId)
                .setSmallIcon(notificationIconIdentifier == 0 ? R.drawable.logo : notificationIconIdentifier)
                .setColor(notificationCircleHexColor == 0 ? Color.TRANSPARENT: (int) notificationCircleHexColor)
                .setContentTitle(notificationTitle == null ? getApplicationName(getApplicationContext()) : notificationTitle)
                .setContentText(notificationBody == null ? "Your Service is still working" : notificationBody)
                .setOngoing(true)
                .setContentIntent(pendingIntent)
                .setPriority(NotificationCompat.PRIORITY_HIGH).build();

        NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        mNotificationManager.notify(NOTIFICATION_ID, builder);
    }

    void toggleAnimation(ImageView closeBtnImage, Animation animation){
        closeBtnImage.startAnimation(animation);
        closeBtnImage.setVisibility(View.VISIBLE);
    }

    public static String getApplicationName(Context context) {
        ApplicationInfo applicationInfo = context.getApplicationInfo();
        int stringId = applicationInfo.labelRes;
        return stringId == 0 ? applicationInfo.nonLocalizedLabel.toString() : context.getString(stringId);
    }
    @Override
    public void onDestroy() {
        super.onDestroy();
        removeView();
    }

    private void removeView(){
        try {
            if (closeBtnView != null) {
                closeBtnView.setVisibility(View.INVISIBLE);
            }
            
            if (mWindowManager != null) {
                if (mChatHeadView != null && mChatHeadView.isAttachedToWindow()) {
                    mWindowManager.removeView(mChatHeadView);
                }
                if (closeBtnView != null && closeBtnView.isAttachedToWindow()) {
                    mWindowManager.removeView(closeBtnView);
                }
            }
        } catch (IllegalArgumentException e) {
            // View not attached to window manager, ignore
        } catch (Exception e) {
            // Handle any other exceptions during cleanup
        }
    }

    private boolean isViewOverlapping(View firstView, View secondView) {
        int[] firstPosition = new int[2];
        int[] secondPosition = new int[2];

        firstView.getLocationOnScreen(firstPosition);
        secondView.getLocationOnScreen(secondPosition);

        Rect firstRect = new Rect(
                firstPosition[0],
                firstPosition[1],
                firstPosition[0] + firstView.getWidth(),
                firstPosition[1] + firstView.getHeight()
        );

        Rect secondRect = new Rect(
                secondPosition[0],
                secondPosition[1],
                secondPosition[0] + secondView.getWidth(),
                secondPosition[1] + secondView.getHeight()
        );

        return Rect.intersects(firstRect, secondRect);
    }
}