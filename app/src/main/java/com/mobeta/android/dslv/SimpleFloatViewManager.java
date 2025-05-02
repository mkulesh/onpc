package com.mobeta.android.dslv;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Point;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ListView;

/**
 * Simple implementation of the FloatViewManager class. Uses list
 * items as they appear in the ListView to create the floating View.
 */
public class SimpleFloatViewManager implements DragSortListView.FloatViewManager
{

    private Bitmap mFloatBitmap;

    private ImageView mImageView;

    private int mFloatBGResource = 0;

    private final ListView mListView;

    SimpleFloatViewManager(ListView lv)
    {
        mListView = lv;
    }

    void setBackgroundResource(int res)
    {
        mFloatBGResource = res;
    }

    /**
     * This simple implementation creates a Bitmap copy of the
     * list item currently shown at ListView <code>position</code>.
     */
    @Override
    public View onCreateFloatView(int position)
    {
        // Guaranteed that this will not be null? I think so. Nope, got
        // a NullPointerException once...
        View v = mListView.getChildAt(position + mListView.getHeaderViewsCount() - mListView.getFirstVisiblePosition());

        if (v == null)
        {
            return null;
        }

        v.setPressed(false);

        mFloatBitmap = getBitmapFromView(v);

        if (mImageView == null)
        {
            mImageView = new ImageView(mListView.getContext());
        }
        if (mFloatBGResource > 0)
        {
            mImageView.setBackgroundResource(mFloatBGResource);
        }
        mImageView.setPadding(0, 0, 0, 0);
        mImageView.setImageBitmap(mFloatBitmap);
        mImageView.setLayoutParams(new ViewGroup.LayoutParams(v.getWidth(), v.getHeight()));

        return mImageView;
    }

    private Bitmap getBitmapFromView(View view)
    {
        Bitmap bitmap = Bitmap.createBitmap(
                view.getWidth(), view.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        view.draw(canvas);
        return bitmap;
    }

    /**
     * This does nothing
     */
    @Override
    public void onDragFloatView(View floatView, Point position, Point touch)
    {
        // do nothing
    }

    /**
     * Removes the Bitmap from the ImageView created in
     * onCreateFloatView() and tells the system to recycle it.
     */
    @Override
    public void onDestroyFloatView(View floatView)
    {
        ((ImageView) floatView).setImageDrawable(null);

        mFloatBitmap.recycle();
        mFloatBitmap = null;
    }

    @Override
    public void setSecondaryOnTouchListener(View.OnTouchListener l)
    {
        // do nothing
    }
}

