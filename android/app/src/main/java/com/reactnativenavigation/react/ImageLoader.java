package com.reactnativenavigation.react;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;

import android.content.Context;
import android.graphics.Paint;
import android.graphics.Canvas;
import android.graphics.Typeface;
import android.graphics.Rect;
import android.graphics.Bitmap.CompressFormat;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.FileNotFoundException;
import com.facebook.react.views.text.ReactFontManager;


import com.reactnativenavigation.NavigationApplication;

public class ImageLoader {
    private static final String TAG = "ImageLoader";

    private static final String FILE_SCHEME = "file";
    // we support get file url from font_scheme
    private static final String FONT_SCHEME = "font";

    public static Drawable loadImage(String iconSource) {

        // if we have font scheme, get the actually file scheme from it
        if(iconSource.startsWith(FONT_SCHEME)){
            String[] params = iconSource.substring(7).split(":");
            Integer fontSize = Integer.valueOf(params[1]);
            return getImageForFont(params[0], params[3], fontSize, params[2]);
        }

        if (NavigationApplication.instance.isDebug()) {
            return JsDevImageLoader.loadIcon(iconSource);
        } else {
            Uri uri = Uri.parse(iconSource);
            if (isLocalFile(uri)) {
                return loadFile(uri);
            } else {
                return loadResource(iconSource);
            }
        }
    }

    private static boolean isLocalFile(Uri uri) {
        return FILE_SCHEME.equals(uri.getScheme());
    }


    private static Drawable loadFile(Uri uri) {
        Bitmap bitmap = BitmapFactory.decodeFile(uri.getPath());
        return new BitmapDrawable(NavigationApplication.instance.getResources(), bitmap);
    }

    private static Drawable loadResource(String iconSource) {
        return ResourceDrawableIdHelper.instance.getResourceDrawable(NavigationApplication.instance, iconSource);
    }

    private static Drawable getImageForFont(String fontFamily, String glyph, Integer fontSize, String colorStr) {
        Context context = NavigationApplication.instance;
        File cacheFolder = context.getCacheDir();
        String cacheFolderPath = cacheFolder.getAbsolutePath() + "/";
        Integer color = Color.parseColor(colorStr);
        float scale = context.getResources().getDisplayMetrics().density;
        String scaleSuffix = "@" + (scale == (int) scale ? Integer.toString((int) scale) : Float.toString(scale)) + "x";
        int size = Math.round(fontSize*scale);
        String cacheKey = fontFamily + ":" + glyph + ":" + color;
        String hash = Integer.toString(cacheKey.hashCode(), 32);
        String cacheFilePath = cacheFolderPath + hash + "_" + Integer.toString(fontSize) + scaleSuffix + ".png";
        String cacheFileUrl = "file://" + cacheFilePath;
        File cacheFile = new File(cacheFilePath);
        Bitmap bitmap;
        
        if(cacheFile.exists()) {
            bitmap = BitmapFactory.decodeFile(cacheFilePath);
        } else {
            // save to cache
            FileOutputStream fos = null;
            Typeface typeface = ReactFontManager.getInstance().getTypeface(fontFamily, 0, context.getAssets());
            Paint paint = new Paint();
            paint.setTypeface(typeface);
            paint.setColor(color);
            paint.setTextSize(size);
            paint.setAntiAlias(true);
            Rect textBounds = new Rect();
            paint.getTextBounds(glyph, 0, glyph.length(), textBounds);

            bitmap = Bitmap.createBitmap(textBounds.width(), textBounds.height(), Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            canvas.drawText(glyph, -textBounds.left, -textBounds.top, paint);

            try {
                fos = new FileOutputStream(cacheFile);
                bitmap.compress(CompressFormat.PNG, 100, fos);
                fos.flush();
                fos.close();
                fos = null;
            } catch (FileNotFoundException e) {
                Log.e(TAG, "File not found: " + e.getMessage());
            } catch (IOException e) {
                Log.e(TAG, e.getMessage());
            } finally {
                if (fos != null) {
                    try {
                        fos.close();
                        fos = null;
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

        }

//        return Drawable.createFromPath(cacheFilePath);
        return new BitmapDrawable(NavigationApplication.instance.getResources(), bitmap);

    }
}
