/*
 * DragSortListView.
 *
 * A subclass of the Android ListView component that enables drag
 * and drop re-ordering of list items.
 *
 * Copyright 2012 Carl Bauer
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.mobeta.android.dslv;

import android.content.Context;
import android.content.res.TypedArray;
import android.database.DataSetObserver;
import android.graphics.Canvas;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.SystemClock;
import android.util.AttributeSet;
import android.util.SparseIntArray;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.Checkable;
import android.widget.ListAdapter;
import android.widget.ListView;

import com.mkulesh.onpc.R;

import java.util.ArrayList;

/**
 * ListView subclass that mediates drag and drop resorting of items.
 *
 * @noinspection FieldCanBeLocal
 */
public class DragSortListView extends ListView
{


    /**
     * The View that floats above the ListView and represents
     * the dragged item.
     */
    private View mFloatView;

    /**
     * The float View location. First based on touch location
     * and given deltaX and deltaY. Then restricted by callback
     * to FloatViewManager.onDragFloatView(). Finally restricted
     * by bounds of DSLV.
     */
    private final Point mFloatLoc = new Point();

    private final Point mTouchLoc = new Point();

    /**
     * The middle (in the y-direction) of the floating View.
     */
    private int mFloatViewMid;

    /**
     * Flag to make sure float View isn't measured twice
     */
    private boolean mFloatViewOnMeasured = false;

    /**
     * Watch the Adapter for data changes. Cancel a drag if
     * coincident with a change.
     */
    private final DataSetObserver mObserver;

    /**
     * Transparency for the floating View (XML attribute).
     */
    private float mFloatAlpha = 1.0f;
    private float mCurrFloatAlpha = 1.0f;

    /**
     * While drag-sorting, the current position of the floating
     * View. If dropped, the dragged item will land in this position.
     */
    private int mFloatPos;

    /**
     * The first expanded ListView position that helps represent
     * the drop slot tracking the floating View.
     */
    private int mFirstExpPos;

    /**
     * The second expanded ListView position that helps represent
     * the drop slot tracking the floating View. This can equal
     * mFirstExpPos if there is no slide shuffle occurring; otherwise
     * it is equal to mFirstExpPos + 1.
     */
    private int mSecondExpPos;

    /**
     * Flag set if slide shuffling is enabled.
     */
    private boolean mAnimate = false;

    /**
     * The user dragged from this position.
     */
    private int mSrcPos;

    /**
     * Offset (in x) within the dragged item at which the user
     * picked it up (or first touched down with the digitalis).
     */
    private int mDragDeltaX;

    /**
     * Offset (in y) within the dragged item at which the user
     * picked it up (or first touched down with the digitalis).
     */
    private int mDragDeltaY;

    /**
     * A listener that receives callbacks whenever the floating View
     * hovers over a new position.
     */
    private DragListener mDragListener;

    /**
     * A listener that receives a callback when the floating View
     * is dropped.
     */
    private DropListener mDropListener;

    /**
     * A listener that receives a callback when the floating View
     * (or more precisely the originally dragged item) is removed
     * by one of the provided gestures.
     */
    private RemoveListener mRemoveListener;

    /**
     * Enable/Disable item dragging
     */
    private boolean mDragEnabled = true;

    /**
     * Drag state enum.
     */
    private final static int IDLE = 0;
    private final static int REMOVING = 1;
    private final static int DROPPING = 2;
    private final static int STOPPED = 3;
    private final static int DRAGGING = 4;

    private int mDragState = IDLE;

    /**
     * Height in pixels to which the originally dragged item
     * is collapsed during a drag-sort. Currently, this value
     * must be greater than zero.
     */
    private int mItemHeightCollapsed = 1;

    /**
     * Height of the floating View. Stored for the purpose of
     * providing the tracking drop slot.
     */
    private int mFloatViewHeight;

    /**
     * Convenience member. See above.
     */
    private int mFloatViewHeightHalf;

    /**
     * Save the given width spec for use in measuring children
     */
    private int mWidthMeasureSpec = 0;

    /**
     * Sample Views ultimately used for calculating the height
     * of ListView items that are off-screen.
     */
    private View[] mSampleViewTypes = new View[1];

    /**
     * Drag-scroll encapsulator!
     */
    private final DragScroller mDragScroller;

    /**
     * Determines the start of the upward drag-scroll region
     * at the top of the ListView. Specified by a fraction
     * of the ListView height, thus screen resolution agnostic.
     */
    private float mDragUpScrollStartFrac = 1.0f / 3.0f;

    /**
     * Determines the start of the downward drag-scroll region
     * at the bottom of the ListView. Specified by a fraction
     * of the ListView height, thus screen resolution agnostic.
     */
    private float mDragDownScrollStartFrac = 1.0f / 3.0f;

    /**
     * The following are calculated from the above fracs.
     */
    private int mUpScrollStartY;
    private int mDownScrollStartY;
    private float mDownScrollStartYF;
    private float mUpScrollStartYF;

    /**
     * Calculated from above above and current ListView height.
     */
    private float mDragUpScrollHeight;

    /**
     * Calculated from above above and current ListView height.
     */
    private float mDragDownScrollHeight;

    /**
     * Maximum drag-scroll speed in pixels per ms. Only used with
     * default linear drag-scroll profile.
     */
    private float mMaxScrollSpeed = 0.5f;

    /**
     * Defines the scroll speed during a drag-scroll. User can
     * provide their own; this default is a simple linear profile
     * where scroll speed increases linearly as the floating View
     * nears the top/bottom of the ListView.
     */
    private final DragScrollProfile mScrollProfile = (w, t) -> mMaxScrollSpeed * w;

    /**
     * Current touch x.
     */
    private int mX;

    /**
     * Current touch y.
     */
    private int mY;

    /**
     * Last touch y.
     */
    private int mLastY;

    /**
     * Drag flag bit. Floating View can move in the positive
     * x direction.
     */
    final static int DRAG_POS_X = 0x1;

    /**
     * Drag flag bit. Floating View can move in the negative
     * x direction.
     */
    final static int DRAG_NEG_X = 0x2;

    /**
     * Drag flag bit. Floating View can move in the positive
     * y direction. This is subtle. What this actually means is
     * that, if enabled, the floating View can be dragged below its starting
     * position. Remove in favor of upper-bounding item position?
     */
    final static int DRAG_POS_Y = 0x4;

    /**
     * Drag flag bit. Floating View can move in the negative
     * y direction. This is subtle. What this actually means is
     * that the floating View can be dragged above its starting
     * position. Remove in favor of lower-bounding item position?
     */
    final static int DRAG_NEG_Y = 0x8;

    /**
     * Flags that determine limits on the motion of the
     * floating View. See flags above.
     */
    private int mDragFlags = 0;

    /**
     * Last call to an on*TouchEvent was a call to
     * onInterceptTouchEvent.
     */
    private boolean mLastCallWasIntercept = false;

    /**
     * A touch event is in progress.
     */
    private boolean mInTouchEvent = false;

    /**
     * Let the user customize the floating View.
     */
    private FloatViewManager mFloatViewManager = null;

    /**
     * Given to ListView to cancel its action when a drag-sort
     * begins.
     */
    private final MotionEvent mCancelEvent;

    /**
     * Enum telling where to cancel the ListView action when a
     * drag-sort begins
     */
    private static final int NO_CANCEL = 0;
    private static final int ON_TOUCH_EVENT = 1;
    private static final int ON_INTERCEPT_TOUCH_EVENT = 2;

    /**
     * Where to cancel the ListView action when a
     * drag-sort begins
     */
    private int mCancelMethod = NO_CANCEL;

    /**
     * Determines when a slide shuffle animation starts. That is,
     * defines how close to the edge of the drop slot the floating
     * View must be to initiate the slide.
     */
    private float mSlideRegionFrac = 0.25f;

    /**
     * Number between 0 and 1 indicating the relative location of
     * a sliding item (only used if drag-sort animations
     * are turned on). Nearly 1 means the item is
     * at the top of the slide region (nearly full blank item
     * is directly below).
     */
    private float mSlideFrac = 0.0f;

    /**
     * Wraps the user-provided ListAdapter. This is used to wrap each
     * item View given by the user inside another View (currenly
     * a RelativeLayout) which
     * expands and collapses to simulate the item shuffling.
     */
    private AdapterWrapper mAdapterWrapper;

    /**
     * Needed for adjusting item heights from within layoutChildren
     */
    private boolean mBlockLayoutRequests = false;

    /**
     * Set to true when a down event happens during drag sort;
     * for example, when drag finish animations are
     * playing.
     */
    private boolean mIgnoreTouchEvent = false;

    /**
     * Caches DragSortItemView child heights. Sometimes DSLV has to
     * know the height of an offscreen item. Since ListView virtualizes
     * these, DSLV must get the item from the ListAdapter to obtain
     * its height. That process can be expensive, but often the same
     * offscreen item will be requested many times in a row. Once an
     * offscreen item height is calculated, we cache it in this guy.
     * Actually, we cache the height of the child of the
     * DragSortItemView since the item height changes often during a
     * drag-sort.
     */
    private static final int sCacheSize = 3;
    private final HeightCache mChildHeightCache = new HeightCache(sCacheSize);

    private RemoveAnimator mRemoveAnimator;

    private DropAnimator mDropAnimator;

    private boolean mUseRemoveVelocity;
    private float mRemoveVelocityX = 0;

    public DragSortListView(Context context, AttributeSet attrs)
    {
        super(context, attrs);

        int defaultDuration = 150;
        int removeAnimDuration = defaultDuration; // ms
        int dropAnimDuration = defaultDuration; // ms

        if (attrs != null)
        {
            TypedArray a = getContext().obtainStyledAttributes(attrs,
                    R.styleable.DragSortListView, 0, 0);

            mItemHeightCollapsed = Math.max(1, a.getDimensionPixelSize(
                    R.styleable.DragSortListView_collapsed_height, 1));

            // alpha between 0 and 255, 0=transparent, 255=opaque
            mFloatAlpha = a.getFloat(R.styleable.DragSortListView_float_alpha, mFloatAlpha);
            mCurrFloatAlpha = mFloatAlpha;

            mDragEnabled = a.getBoolean(R.styleable.DragSortListView_drag_enabled, mDragEnabled);

            mSlideRegionFrac = Math.max(0.0f,
                    Math.min(1.0f, 1.0f - a.getFloat(
                            R.styleable.DragSortListView_slide_shuffle_speed,
                            0.75f)));

            mAnimate = mSlideRegionFrac > 0.0f;

            float frac = a.getFloat(
                    R.styleable.DragSortListView_drag_scroll_start,
                    mDragUpScrollStartFrac);

            setDragScrollStart(frac);

            mMaxScrollSpeed = a.getFloat(
                    R.styleable.DragSortListView_max_drag_scroll_speed,
                    mMaxScrollSpeed);

            removeAnimDuration = a.getInt(
                    R.styleable.DragSortListView_remove_animation_duration,
                    removeAnimDuration);

            dropAnimDuration = a.getInt(
                    R.styleable.DragSortListView_drop_animation_duration,
                    dropAnimDuration);

            boolean useDefault = a.getBoolean(
                    R.styleable.DragSortListView_use_default_controller,
                    true);

            if (useDefault)
            {
                boolean removeEnabled = a.getBoolean(
                        R.styleable.DragSortListView_remove_enabled,
                        false);
                int removeMode = a.getInt(
                        R.styleable.DragSortListView_remove_mode,
                        DragSortController.FLING_REMOVE);
                boolean sortEnabled = a.getBoolean(
                        R.styleable.DragSortListView_sort_enabled,
                        true);
                int dragInitMode = a.getInt(
                        R.styleable.DragSortListView_drag_start_mode,
                        DragSortController.ON_DOWN);
                int dragHandleId = a.getResourceId(
                        R.styleable.DragSortListView_drag_handle_id,
                        0);
                int flingHandleId = a.getResourceId(
                        R.styleable.DragSortListView_fling_handle_id,
                        0);
                int clickRemoveId = a.getResourceId(
                        R.styleable.DragSortListView_click_remove_id,
                        0);
                int bgResource = a.getResourceId(
                        R.styleable.DragSortListView_float_background_id,
                        0);

                DragSortController controller = new DragSortController(
                        this, dragHandleId, dragInitMode, removeMode,
                        clickRemoveId, flingHandleId);
                controller.setRemoveEnabled(removeEnabled);
                controller.setSortEnabled(sortEnabled);
                controller.setBackgroundResource(bgResource);

                mFloatViewManager = controller;
                // must register this on ListView (super), not 'this'.
                super.setOnTouchListener(controller);
            }

            a.recycle();
        }

        mDragScroller = new DragScroller();

        float smoothness = 0.5f;
        if (removeAnimDuration > 0)
        {
            mRemoveAnimator = new RemoveAnimator(smoothness, removeAnimDuration);
        }
        if (dropAnimDuration > 0)
        {
            mDropAnimator = new DropAnimator(smoothness, dropAnimDuration);
        }

        mCancelEvent = MotionEvent.obtain(0, 0, MotionEvent.ACTION_CANCEL, 0f, 0f, 0f, 0f, 0, 0f,
                0f, 0, 0);

        // construct the dataset observer
        mObserver = new DataSetObserver()
        {
            private void cancel()
            {
                if (mDragState == DRAGGING)
                {
                    cancelDrag();
                }
            }

            @Override
            public void onChanged()
            {
                cancel();
            }

            @Override
            public void onInvalidated()
            {
                cancel();
            }
        };
    }

    /**
     * DragSortListView registers the the controler as an onTouch listener.
     * We implement this method to ensure that users of this listview can also
     * register their own onTouch listener without disabling our own registration.
     */
    @Override
    public void setOnTouchListener(View.OnTouchListener l)
    {
        if (mFloatViewManager != null)
        {
            mFloatViewManager.setSecondaryOnTouchListener(l);
        }
    }

    /**
     * For each DragSortListView Listener interface implemented by
     * <code>adapter</code>, this method calls the appropriate
     * set*Listener method with <code>adapter</code> as the argument.
     *
     * @param adapter The ListAdapter providing data to back
     *                DragSortListView.
     * @see android.widget.ListView#setAdapter(android.widget.ListAdapter)
     */
    @Override
    public void setAdapter(ListAdapter adapter)
    {
        if (adapter != null)
        {
            mAdapterWrapper = new AdapterWrapper(adapter);
            adapter.registerDataSetObserver(mObserver);

            if (adapter instanceof DropListener)
            {
                setDropListener((DropListener) adapter);
            }
            if (adapter instanceof DragListener)
            {
                setDragListener((DragListener) adapter);
            }
            if (adapter instanceof RemoveListener)
            {
                setRemoveListener((RemoveListener) adapter);
            }
        }
        else
        {
            mAdapterWrapper = null;
        }

        super.setAdapter(mAdapterWrapper);
    }

    private class AdapterWrapper extends BaseAdapter
    {
        private final ListAdapter mAdapter;

        AdapterWrapper(ListAdapter adapter)
        {
            super();
            mAdapter = adapter;

            mAdapter.registerDataSetObserver(new DataSetObserver()
            {
                public void onChanged()
                {
                    notifyDataSetChanged();
                }

                public void onInvalidated()
                {
                    notifyDataSetInvalidated();
                }
            });
        }

        @Override
        public long getItemId(int position)
        {
            return mAdapter.getItemId(position);
        }

        @Override
        public Object getItem(int position)
        {
            return mAdapter.getItem(position);
        }

        @Override
        public int getCount()
        {
            return mAdapter.getCount();
        }

        @Override
        public boolean areAllItemsEnabled()
        {
            return mAdapter.areAllItemsEnabled();
        }

        @Override
        public boolean isEnabled(int position)
        {
            return mAdapter.isEnabled(position);
        }

        @Override
        public int getItemViewType(int position)
        {
            return mAdapter.getItemViewType(position);
        }

        @Override
        public int getViewTypeCount()
        {
            return mAdapter.getViewTypeCount();
        }

        @Override
        public boolean hasStableIds()
        {
            return mAdapter.hasStableIds();
        }

        @Override
        public boolean isEmpty()
        {
            return mAdapter.isEmpty();
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent)
        {

            DragSortItemView v;
            View child;
            if (convertView != null)
            {
                v = (DragSortItemView) convertView;
                View oldChild = v.getChildAt(0);

                child = mAdapter.getView(position, oldChild, DragSortListView.this);
                if (child != oldChild)
                {
                    // shouldn't get here if user is reusing convertViews
                    // properly
                    if (oldChild != null)
                    {
                        v.removeViewAt(0);
                    }
                    v.addView(child);
                }
            }
            else
            {
                child = mAdapter.getView(position, null, DragSortListView.this);
                if (child instanceof Checkable)
                {
                    v = new DragSortItemViewCheckable(getContext());
                }
                else
                {
                    v = new DragSortItemView(getContext());
                }
                v.setLayoutParams(new AbsListView.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT));
                v.addView(child);
            }

            // Set the correct item height given drag state; passed
            // View needs to be measured if measurement is required.
            adjustItem(position + getHeaderViewsCount(), v, true);

            return v;
        }
    }

    private void drawDivider(int expPosition, Canvas canvas)
    {

        final Drawable divider = getDivider();
        final int dividerHeight = getDividerHeight();
        // Log.d("mobeta", "div="+divider+" divH="+dividerHeight);

        if (divider != null && dividerHeight != 0)
        {
            final ViewGroup expItem = (ViewGroup) getChildAt(expPosition
                    - getFirstVisiblePosition());
            if (expItem != null)
            {
                final int l = getPaddingLeft();
                final int r = getWidth() - getPaddingRight();
                final int t;
                final int b;

                final int childHeight = expItem.getChildAt(0).getHeight();

                if (expPosition > mSrcPos)
                {
                    t = expItem.getTop() + childHeight;
                    b = t + dividerHeight;
                }
                else
                {
                    b = expItem.getBottom() - childHeight;
                    t = b - dividerHeight;
                }
                // Log.d("mobeta", "l="+l+" t="+t+" r="+r+" b="+b);

                // Have to clip to support ColorDrawable on <= Gingerbread
                canvas.save();
                canvas.clipRect(l, t, r, b);
                divider.setBounds(l, t, r, b);
                divider.draw(canvas);
                canvas.restore();
            }
        }
    }

    /**
     * @noinspection RedundantSuppression
     */
    @Override
    @SuppressWarnings("deprecation")
    protected void dispatchDraw(Canvas canvas)
    {
        super.dispatchDraw(canvas);

        if (mDragState != IDLE)
        {
            // draw the divider over the expanded item
            if (mFirstExpPos != mSrcPos)
            {
                drawDivider(mFirstExpPos, canvas);
            }
            if (mSecondExpPos != mFirstExpPos && mSecondExpPos != mSrcPos)
            {
                drawDivider(mSecondExpPos, canvas);
            }
        }

        if (mFloatView != null)
        {
            // draw the float view over everything
            final int w = mFloatView.getWidth();
            final int h = mFloatView.getHeight();

            int x = mFloatLoc.x;

            int width = getWidth();
            if (x < 0)
                x = -x;
            float alphaMod;
            if (x < width)
            {
                alphaMod = ((float) (width - x)) / ((float) width);
                alphaMod *= alphaMod;
            }
            else
            {
                alphaMod = 0;
            }

            final int alpha = (int) (255f * mCurrFloatAlpha * alphaMod);

            canvas.save();
            // Log.d("mobeta", "clip rect bounds: " + canvas.getClipBounds());
            canvas.translate(mFloatLoc.x, mFloatLoc.y);
            canvas.clipRect(0, 0, w, h);

            // Log.d("mobeta", "clip rect bounds: " + canvas.getClipBounds());
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            {
                canvas.saveLayerAlpha(0, 0, w, h, alpha);
            }
            else
            {
                canvas.saveLayerAlpha(0, 0, w, h, alpha, Canvas.ALL_SAVE_FLAG);
            }
            mFloatView.draw(canvas);
            canvas.restore();
            canvas.restore();
        }
    }

    private int getItemHeight(int position)
    {
        View v = getChildAt(position - getFirstVisiblePosition());

        if (v != null)
        {
            // item is onscreen, just get the height of the View
            return v.getHeight();
        }
        else
        {
            // item is offscreen. get child height and calculate
            // item height based on current shuffle state
            return calcItemHeight(position, getChildHeight(position));
        }
    }

    private static class HeightCache
    {

        private final SparseIntArray mMap;
        private final ArrayList<Integer> mOrder;
        private final int mMaxSize;

        HeightCache(int size)
        {
            mMap = new SparseIntArray(size);
            mOrder = new ArrayList<>(size);
            mMaxSize = size;
        }

        /**
         * Add item height at position if doesn't already exist.
         */
        void add(int position, int height)
        {
            int currHeight = mMap.get(position, -1);
            if (currHeight != height)
            {
                if (currHeight == -1)
                {
                    if (mMap.size() == mMaxSize)
                    {
                        // remove oldest entry
                        mMap.delete(mOrder.remove(0));
                    }
                }
                else
                {
                    // move position to newest slot
                    mOrder.remove((Integer) position);
                }
                mMap.put(position, height);
                mOrder.add(position);
            }
        }

        int get(int position)
        {
            return mMap.get(position, -1);
        }

        void clear()
        {
            mMap.clear();
            mOrder.clear();
        }

    }

    /**
     * Get the shuffle edge for item at position when top of
     * item is at y-coord top. Assumes that current item heights
     * are consistent with current float view location and
     * thus expanded positions and slide fraction. i.e. Should not be
     * called between update of expanded positions/slide fraction
     * and layoutChildren.
     *
     * @noinspection ConstantValue
     */
    private int getShuffleEdge(int position, int top)
    {

        final int numHeaders = getHeaderViewsCount();
        final int numFooters = getFooterViewsCount();

        // shuffle edges are defined between items that can be
        // dragged; there are N-1 of them if there are N draggable
        // items.

        if (position <= numHeaders || (position >= getCount() - numFooters))
        {
            return top;
        }

        int divHeight = getDividerHeight();

        int edge;

        int maxBlankHeight = mFloatViewHeight - mItemHeightCollapsed;
        int childHeight = getChildHeight(position);
        int itemHeight = getItemHeight(position);

        // first calculate top of item given that floating View is
        // centered over src position
        int otop = top;
        if (mSecondExpPos <= mSrcPos)
        {
            // items are expanded on and/or above the source position

            if (position == mSecondExpPos && mFirstExpPos != mSecondExpPos)
            {
                if (position == mSrcPos)
                {
                    otop = top + itemHeight - mFloatViewHeight;
                }
                else
                {
                    int blankHeight = itemHeight - childHeight;
                    otop = top + blankHeight - maxBlankHeight;
                }
            }
            else if (position > mSecondExpPos && position <= mSrcPos)
            {
                otop = top - maxBlankHeight;
            }

        }
        else
        {
            // items are expanded on and/or below the source position

            if (position > mSrcPos && position <= mFirstExpPos)
            {
                otop = top + maxBlankHeight;
            }
            else if (position == mSecondExpPos && mFirstExpPos != mSecondExpPos)
            {
                int blankHeight = itemHeight - childHeight;
                otop = top + blankHeight;
            }
        }

        // otop is set
        if (position <= mSrcPos)
        {
            edge = otop + (mFloatViewHeight - divHeight - getChildHeight(position - 1)) / 2;
        }
        else
        {
            edge = otop + (childHeight - divHeight - mFloatViewHeight) / 2;
        }

        return edge;
    }

    private boolean updatePositions()
    {

        final int first = getFirstVisiblePosition();
        int startPos = mFirstExpPos;
        View startView = getChildAt(startPos - first);

        if (startView == null)
        {
            startPos = first + getChildCount() / 2;
            startView = getChildAt(startPos - first);
        }
        int startTop = startView.getTop();

        int itemHeight = startView.getHeight();

        int edge = getShuffleEdge(startPos, startTop);
        int lastEdge = edge;

        int divHeight = getDividerHeight();

        // Log.d("mobeta", "float mid="+mFloatViewMid);

        int itemPos = startPos;
        int itemTop = startTop;
        if (mFloatViewMid < edge)
        {
            // scanning up for float position
            // Log.d("mobeta", "    edge="+edge);
            while (itemPos >= 0)
            {
                itemPos--;
                itemHeight = getItemHeight(itemPos);

                if (itemPos == 0)
                {
                    edge = itemTop - divHeight - itemHeight;
                    break;
                }

                itemTop -= itemHeight + divHeight;
                edge = getShuffleEdge(itemPos, itemTop);
                // Log.d("mobeta", "    edge="+edge);

                if (mFloatViewMid >= edge)
                {
                    break;
                }

                lastEdge = edge;
            }
        }
        else
        {
            // scanning down for float position
            // Log.d("mobeta", "    edge="+edge);
            final int count = getCount();
            while (itemPos < count)
            {
                if (itemPos == count - 1)
                {
                    edge = itemTop + divHeight + itemHeight;
                    break;
                }

                itemTop += divHeight + itemHeight;
                itemHeight = getItemHeight(itemPos + 1);
                edge = getShuffleEdge(itemPos + 1, itemTop);
                // Log.d("mobeta", "    edge="+edge);

                // test for hit
                if (mFloatViewMid < edge)
                {
                    break;
                }

                lastEdge = edge;
                itemPos++;
            }
        }

        final int numHeaders = getHeaderViewsCount();
        final int numFooters = getFooterViewsCount();

        boolean updated = false;

        int oldFirstExpPos = mFirstExpPos;
        int oldSecondExpPos = mSecondExpPos;
        float oldSlideFrac = mSlideFrac;

        if (mAnimate)
        {
            int edgeToEdge = Math.abs(edge - lastEdge);

            int edgeTop, edgeBottom;
            if (mFloatViewMid < edge)
            {
                edgeBottom = edge;
                edgeTop = lastEdge;
            }
            else
            {
                edgeTop = edge;
                edgeBottom = lastEdge;
            }
            // Log.d("mobeta", "edgeTop="+edgeTop+" edgeBot="+edgeBottom);

            int slideRgnHeight = (int) (0.5f * mSlideRegionFrac * edgeToEdge);
            float slideRgnHeightF = (float) slideRgnHeight;
            int slideEdgeTop = edgeTop + slideRgnHeight;
            int slideEdgeBottom = edgeBottom - slideRgnHeight;

            // Three regions
            if (mFloatViewMid < slideEdgeTop)
            {
                mFirstExpPos = itemPos - 1;
                mSecondExpPos = itemPos;
                mSlideFrac = 0.5f * ((float) (slideEdgeTop - mFloatViewMid)) / slideRgnHeightF;
            }
            else if (mFloatViewMid < slideEdgeBottom)
            {
                mFirstExpPos = itemPos;
                mSecondExpPos = itemPos;
            }
            else
            {
                mFirstExpPos = itemPos;
                mSecondExpPos = itemPos + 1;
                mSlideFrac = 0.5f * (1.0f + ((float) (edgeBottom - mFloatViewMid))
                        / slideRgnHeightF);
            }

        }
        else
        {
            mFirstExpPos = itemPos;
            mSecondExpPos = itemPos;
        }

        // correct for headers and footers
        if (mFirstExpPos < numHeaders)
        {
            itemPos = numHeaders;
            mFirstExpPos = itemPos;
            mSecondExpPos = itemPos;
        }
        else if (mSecondExpPos >= getCount() - numFooters)
        {
            itemPos = getCount() - numFooters - 1;
            mFirstExpPos = itemPos;
            mSecondExpPos = itemPos;
        }

        if (mFirstExpPos != oldFirstExpPos || mSecondExpPos != oldSecondExpPos
                || mSlideFrac != oldSlideFrac)
        {
            updated = true;
        }

        if (itemPos != mFloatPos)
        {
            if (mDragListener != null)
            {
                mDragListener.drag(mFloatPos - numHeaders, itemPos - numHeaders);
            }

            mFloatPos = itemPos;
            updated = true;
        }

        return updated;
    }

    private class SmoothAnimator implements Runnable
    {
        long mStartTime;

        private final float mDurationF;

        private final float mAlpha;
        private final float mA, mB, mC, mD;

        private boolean mCanceled;

        SmoothAnimator(float smoothness, int duration)
        {
            mAlpha = smoothness;
            mDurationF = (float) duration;
            mA = mD = 1f / (2f * mAlpha * (1f - mAlpha));
            mB = mAlpha / (2f * (mAlpha - 1f));
            mC = 1f / (1f - mAlpha);
        }

        float transform(float frac)
        {
            if (frac < mAlpha)
            {
                return mA * frac * frac;
            }
            else if (frac < 1f - mAlpha)
            {
                return mB + mC * frac;
            }
            else
            {
                return 1f - mD * (frac - 1f) * (frac - 1f);
            }
        }

        void start()
        {
            mStartTime = SystemClock.uptimeMillis();
            mCanceled = false;
            onStart();
            post(this);
        }

        void cancel()
        {
            mCanceled = true;
        }

        void onStart()
        {
            // stub
        }

        void onUpdate(float frac, float smoothFrac)
        {
            // stub
        }

        void onStop()
        {
            // stub
        }

        @Override
        public void run()
        {
            if (mCanceled)
            {
                return;
            }

            float fraction = ((float) (SystemClock.uptimeMillis() - mStartTime)) / mDurationF;

            if (fraction >= 1f)
            {
                onUpdate(1f, 1f);
                onStop();
            }
            else
            {
                onUpdate(fraction, transform(fraction));
                post(this);
            }
        }
    }

    /**
     * Centers floating View over drop slot before destroying.
     */
    private class DropAnimator extends SmoothAnimator
    {

        private int mDropPos;
        private int srcPos;
        private float mInitDeltaY;
        private float mInitDeltaX;

        DropAnimator(float smoothness, int duration)
        {
            super(smoothness, duration);
        }

        @Override
        void onStart()
        {
            mDropPos = mFloatPos;
            srcPos = mSrcPos;
            mDragState = DROPPING;
            mInitDeltaY = mFloatLoc.y - getTargetY();
            mInitDeltaX = mFloatLoc.x - getPaddingLeft();
        }

        private int getTargetY()
        {
            final int first = getFirstVisiblePosition();
            final int otherAdjust = (mItemHeightCollapsed + getDividerHeight()) / 2;
            View v = getChildAt(mDropPos - first);
            int targetY = -1;
            if (v != null)
            {
                if (mDropPos == srcPos)
                {
                    targetY = v.getTop();
                }
                else if (mDropPos < srcPos)
                {
                    // expanded down
                    targetY = v.getTop() - otherAdjust;
                }
                else
                {
                    // expanded up
                    targetY = v.getBottom() + otherAdjust - mFloatViewHeight;
                }
            }
            else
            {
                // drop position is not on screen?? no animation
                cancel();
            }

            return targetY;
        }

        @Override
        void onUpdate(float frac, float smoothFrac)
        {
            final int targetY = getTargetY();
            final int targetX = getPaddingLeft();
            final float deltaY = mFloatLoc.y - targetY;
            final float deltaX = mFloatLoc.x - targetX;
            final float f = 1f - smoothFrac;
            if (f < Math.abs(deltaY / mInitDeltaY) || f < Math.abs(deltaX / mInitDeltaX))
            {
                mFloatLoc.y = targetY + (int) (mInitDeltaY * f);
                mFloatLoc.x = getPaddingLeft() + (int) (mInitDeltaX * f);
                doDragFloatView(true);
            }
        }

        @Override
        void onStop()
        {
            dropFloatView();
        }

    }

    /**
     * Collapses expanded items.
     */
    private class RemoveAnimator extends SmoothAnimator
    {

        private float mFloatLocX;
        private float mFirstStartBlank;
        private float mSecondStartBlank;

        private int mFirstChildHeight = -1;
        private int mSecondChildHeight = -1;

        private int mFirstPos;
        private int mSecondPos;

        RemoveAnimator(float smoothness, int duration)
        {
            super(smoothness, duration);
        }

        @Override
        void onStart()
        {
            mFirstChildHeight = -1;
            mSecondChildHeight = -1;
            mFirstPos = mFirstExpPos;
            mSecondPos = mSecondExpPos;
            mDragState = REMOVING;

            mFloatLocX = mFloatLoc.x;
            if (mUseRemoveVelocity)
            {
                float minVelocity = 2f * getWidth();
                if (mRemoveVelocityX == 0)
                {
                    mRemoveVelocityX = (mFloatLocX < 0 ? -1 : 1) * minVelocity;
                }
                else
                {
                    minVelocity *= 2;
                    if (mRemoveVelocityX < 0 && mRemoveVelocityX > -minVelocity)
                        mRemoveVelocityX = -minVelocity;
                    else if (mRemoveVelocityX > 0 && mRemoveVelocityX < minVelocity)
                        mRemoveVelocityX = minVelocity;
                }
            }
            else
            {
                destroyFloatView();
            }
        }

        @Override
        void onUpdate(float frac, float smoothFrac)
        {
            float f = 1f - smoothFrac;

            final int firstVis = getFirstVisiblePosition();
            View item = getChildAt(mFirstPos - firstVis);
            ViewGroup.LayoutParams lp;
            int blank;

            if (mUseRemoveVelocity)
            {
                float dt = (float) (SystemClock.uptimeMillis() - mStartTime) / 1000;
                if (dt == 0)
                    return;
                float dx = mRemoveVelocityX * dt;
                int w = getWidth();
                mRemoveVelocityX += (mRemoveVelocityX > 0 ? 1 : -1) * dt * w;
                mFloatLocX += dx;
                mFloatLoc.x = (int) mFloatLocX;
                if (mFloatLocX < w && mFloatLocX > -w)
                {
                    mStartTime = SystemClock.uptimeMillis();
                    doDragFloatView(true);
                    return;
                }
            }

            if (item != null)
            {
                if (mFirstChildHeight == -1)
                {
                    mFirstChildHeight = getChildHeight(mFirstPos, item, false);
                    mFirstStartBlank = (float) (item.getHeight() - mFirstChildHeight);
                }
                blank = Math.max((int) (f * mFirstStartBlank), 1);
                lp = item.getLayoutParams();
                lp.height = mFirstChildHeight + blank;
                item.setLayoutParams(lp);
            }
            if (mSecondPos != mFirstPos)
            {
                item = getChildAt(mSecondPos - firstVis);
                if (item != null)
                {
                    if (mSecondChildHeight == -1)
                    {
                        mSecondChildHeight = getChildHeight(mSecondPos, item, false);
                        mSecondStartBlank = (float) (item.getHeight() - mSecondChildHeight);
                    }
                    blank = Math.max((int) (f * mSecondStartBlank), 1);
                    lp = item.getLayoutParams();
                    lp.height = mSecondChildHeight + blank;
                    item.setLayoutParams(lp);
                }
            }
        }

        @Override
        void onStop()
        {
            doRemoveItem();
        }
    }

    void removeItem(int which)
    {

        mUseRemoveVelocity = false;
        removeItem(which, 0);
    }

    /**
     * Removes an item from the list and animates the removal.
     */
    private void removeItem(int which, float velocityX)
    {
        if (mDragState == IDLE || mDragState == DRAGGING)
        {

            if (mDragState == IDLE)
            {
                // called from outside drag-sort
                mSrcPos = getHeaderViewsCount() + which;
                mFirstExpPos = mSrcPos;
                mSecondExpPos = mSrcPos;
                mFloatPos = mSrcPos;
                View v = getChildAt(mSrcPos - getFirstVisiblePosition());
                if (v != null)
                {
                    v.setVisibility(View.INVISIBLE);
                }
            }

            mDragState = REMOVING;
            mRemoveVelocityX = velocityX;

            if (mInTouchEvent)
            {
                switch (mCancelMethod)
                {
                case ON_TOUCH_EVENT:
                    super.onTouchEvent(mCancelEvent);
                    break;
                case ON_INTERCEPT_TOUCH_EVENT:
                    super.onInterceptTouchEvent(mCancelEvent);
                    break;
                }
            }

            if (mRemoveAnimator != null)
            {
                mRemoveAnimator.start();
            }
            else
            {
                doRemoveItem(which);
            }
        }
    }

    private void cancelDrag()
    {
        if (mDragState == DRAGGING)
        {
            mDragScroller.stopScrolling(true);
            destroyFloatView();
            clearPositions();
            adjustAllItems();

            if (mInTouchEvent)
            {
                mDragState = STOPPED;
            }
            else
            {
                mDragState = IDLE;
            }
        }
    }

    private void clearPositions()
    {
        mSrcPos = -1;
        mFirstExpPos = -1;
        mSecondExpPos = -1;
        mFloatPos = -1;
    }

    private void dropFloatView()
    {
        // must set to avoid cancelDrag being called from the
        // DataSetObserver
        mDragState = DROPPING;

        if (mDropListener != null && mFloatPos >= 0 && mFloatPos < getCount())
        {
            final int numHeaders = getHeaderViewsCount();
            mDropListener.drop(mSrcPos - numHeaders, mFloatPos - numHeaders);
        }

        destroyFloatView();

        adjustOnReorder();
        clearPositions();
        adjustAllItems();

        // now the drag is done
        if (mInTouchEvent)
        {
            mDragState = STOPPED;
        }
        else
        {
            mDragState = IDLE;
        }
    }

    private void doRemoveItem()
    {
        doRemoveItem(mSrcPos - getHeaderViewsCount());
    }

    /**
     * Removes dragged item from the list. Calls RemoveListener.
     */
    private void doRemoveItem(int which)
    {
        // must set to avoid cancelDrag being called from the
        // DataSetObserver
        mDragState = REMOVING;

        // end it
        if (mRemoveListener != null)
        {
            mRemoveListener.remove(which);
        }

        destroyFloatView();

        adjustOnReorder();
        clearPositions();

        // now the drag is done
        if (mInTouchEvent)
        {
            mDragState = STOPPED;
        }
        else
        {
            mDragState = IDLE;
        }
    }

    private void adjustOnReorder()
    {
        final int firstPos = getFirstVisiblePosition();
        // Log.d("mobeta", "first="+firstPos+" src="+mSrcPos);
        if (mSrcPos < firstPos)
        {
            // collapsed src item is off screen;
            // adjust the scroll after item heights have been fixed
            View v = getChildAt(0);
            int top = 0;
            if (v != null)
            {
                top = v.getTop();
            }
            // Log.d("mobeta", "top="+top+" fvh="+mFloatViewHeight);
            setSelectionFromTop(firstPos - 1, top - getPaddingTop());
        }
    }

    /**
     * Stop a drag in progress. Pass <code>true</code> if you would
     * like to remove the dragged item from the list.
     *
     * @param remove Remove the dragged item from the list. Calls
     *               a registered RemoveListener, if one exists. Otherwise, calls
     *               the DropListener, if one exists.
     */
    private void stopDrag(boolean remove)
    {
        mUseRemoveVelocity = false;
        stopDrag(remove, 0);
    }

    void stopDragWithVelocity(boolean remove, float velocityX)
    {
        mUseRemoveVelocity = true;
        stopDrag(remove, velocityX);
    }

    private void stopDrag(boolean remove, float velocityX)
    {
        if (mFloatView != null)
        {
            mDragScroller.stopScrolling(true);

            if (remove)
            {
                removeItem(mSrcPos - getHeaderViewsCount(), velocityX);
            }
            else
            {
                if (mDropAnimator != null)
                {
                    mDropAnimator.start();
                }
                else
                {
                    dropFloatView();
                }
            }
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev)
    {
        if (mIgnoreTouchEvent)
        {
            mIgnoreTouchEvent = false;
            return false;
        }

        if (!mDragEnabled)
        {
            return super.onTouchEvent(ev);
        }

        boolean more = false;

        boolean lastCallWasIntercept = mLastCallWasIntercept;
        mLastCallWasIntercept = false;

        if (!lastCallWasIntercept)
        {
            saveTouchCoords(ev);
        }

        // if (mFloatView != null) {
        if (mDragState == DRAGGING)
        {
            onDragTouchEvent(ev);
            more = true; // give us more!
        }
        else
        {
            // what if float view is null b/c we dropped in middle
            // of drag touch event?

            // if (mDragState != STOPPED) {
            if (mDragState == IDLE)
            {
                if (super.onTouchEvent(ev))
                {
                    more = true;
                }
            }

            int action = ev.getAction() & MotionEvent.ACTION_MASK;

            switch (action)
            {
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                doActionUpOrCancel();
                break;
            default:
                if (more)
                {
                    mCancelMethod = ON_TOUCH_EVENT;
                }
            }
        }

        return more;
    }

    private void doActionUpOrCancel()
    {
        mCancelMethod = NO_CANCEL;
        mInTouchEvent = false;
        if (mDragState == STOPPED)
        {
            mDragState = IDLE;
        }
        mCurrFloatAlpha = mFloatAlpha;
        mListViewIntercepted = false;
        mChildHeightCache.clear();
    }

    private void saveTouchCoords(MotionEvent ev)
    {
        int action = ev.getAction() & MotionEvent.ACTION_MASK;
        if (action != MotionEvent.ACTION_DOWN)
        {
            mLastY = mY;
        }
        mX = (int) ev.getX();
        mY = (int) ev.getY();
        if (action == MotionEvent.ACTION_DOWN)
        {
            mLastY = mY;
        }
    }

    boolean listViewIntercepted()
    {
        return mListViewIntercepted;
    }

    private boolean mListViewIntercepted = false;

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev)
    {
        if (!mDragEnabled)
        {
            return super.onInterceptTouchEvent(ev);
        }

        saveTouchCoords(ev);
        mLastCallWasIntercept = true;

        int action = ev.getAction() & MotionEvent.ACTION_MASK;

        if (action == MotionEvent.ACTION_DOWN)
        {
            if (mDragState != IDLE)
            {
                // intercept and ignore
                mIgnoreTouchEvent = true;
                return true;
            }
            mInTouchEvent = true;
        }

        boolean intercept = false;

        // the following deals with calls to super.onInterceptTouchEvent
        if (mFloatView != null)
        {
            // super's touch event canceled in startDrag
            intercept = true;
        }
        else
        {
            if (super.onInterceptTouchEvent(ev))
            {
                mListViewIntercepted = true;
                intercept = true;
            }

            switch (action)
            {
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                doActionUpOrCancel();
                break;
            default:
                if (intercept)
                {
                    mCancelMethod = ON_TOUCH_EVENT;
                }
                else
                {
                    mCancelMethod = ON_INTERCEPT_TOUCH_EVENT;
                }
            }
        }

        if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL)
        {
            mInTouchEvent = false;
        }

        return intercept;
    }

    /**
     * Set the width of each drag scroll region by specifying
     * a fraction of the ListView height.
     *
     * @param heightFraction Fraction of ListView height. Capped at
     *                       0.5f.
     */
    private void setDragScrollStart(float heightFraction)
    {
        setDragScrollStarts(heightFraction, heightFraction);
    }

    /**
     * Set the width of each drag scroll region by specifying
     * a fraction of the ListView height.
     *
     * @param upperFrac Fraction of ListView height for up-scroll bound.
     *                  Capped at 0.5f.
     * @param lowerFrac Fraction of ListView height for down-scroll bound.
     *                  Capped at 0.5f.
     * @noinspection ManualMinMaxCalculation
     */
    private void setDragScrollStarts(float upperFrac, float lowerFrac)
    {
        if (lowerFrac > 0.5f)
        {
            mDragDownScrollStartFrac = 0.5f;
        }
        else
        {
            mDragDownScrollStartFrac = lowerFrac;
        }

        if (upperFrac > 0.5f)
        {
            mDragUpScrollStartFrac = 0.5f;
        }
        else
        {
            mDragUpScrollStartFrac = upperFrac;
        }

        if (getHeight() != 0)
        {
            updateScrollStarts();
        }
    }

    private void continueDrag(int x, int y)
    {

        // proposed position
        mFloatLoc.x = x - mDragDeltaX;
        mFloatLoc.y = y - mDragDeltaY;

        doDragFloatView(true);

        int minY = Math.min(y, mFloatViewMid + mFloatViewHeightHalf);
        int maxY = Math.max(y, mFloatViewMid - mFloatViewHeightHalf);

        // get the current scroll direction
        int currentScrollDir = mDragScroller.getScrollDir();

        if (minY > mLastY && minY > mDownScrollStartY && currentScrollDir != DragScroller.DOWN)
        {
            // dragged down, it is below the down scroll start and it is not
            // scrolling up

            if (currentScrollDir != DragScroller.STOP)
            {
                // moved directly from up scroll to down scroll
                mDragScroller.stopScrolling(true);
            }

            // start scrolling down
            mDragScroller.startScrolling(DragScroller.DOWN);
        }
        else if (maxY < mLastY && maxY < mUpScrollStartY && currentScrollDir != DragScroller.UP)
        {
            // dragged up, it is above the up scroll start and it is not
            // scrolling up

            if (currentScrollDir != DragScroller.STOP)
            {
                // moved directly from down scroll to up scroll
                mDragScroller.stopScrolling(true);
            }

            // start scrolling up
            mDragScroller.startScrolling(DragScroller.UP);
        }
        else if (maxY >= mUpScrollStartY && minY <= mDownScrollStartY
                && mDragScroller.isScrolling())
        {
            // not in the upper nor in the lower drag-scroll regions but it is
            // still scrolling

            mDragScroller.stopScrolling(true);
        }
    }

    private void updateScrollStarts()
    {
        final int padTop = getPaddingTop();
        final int listHeight = getHeight() - padTop - getPaddingBottom();
        float heightF = (float) listHeight;

        mUpScrollStartYF = padTop + mDragUpScrollStartFrac * heightF;
        mDownScrollStartYF = padTop + (1.0f - mDragDownScrollStartFrac) * heightF;

        mUpScrollStartY = (int) mUpScrollStartYF;
        mDownScrollStartY = (int) mDownScrollStartYF;

        mDragUpScrollHeight = mUpScrollStartYF - padTop;
        mDragDownScrollHeight = padTop + listHeight - mDownScrollStartYF;
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh)
    {
        super.onSizeChanged(w, h, oldw, oldh);
        updateScrollStarts();
    }

    private void adjustAllItems()
    {
        final int first = getFirstVisiblePosition();
        final int last = getLastVisiblePosition();

        int begin = Math.max(0, getHeaderViewsCount() - first);
        int end = Math.min(last - first, getCount() - 1 - getFooterViewsCount() - first);

        for (int i = begin; i <= end; ++i)
        {
            View v = getChildAt(i);
            if (v != null)
            {
                adjustItem(first + i, v, false);
            }
        }
    }

    /**
     * Sets layout param height, gravity, and visibility  on
     * wrapped item.
     */
    private void adjustItem(int position, View v, boolean invalidChildHeight)
    {

        // Adjust item height
        ViewGroup.LayoutParams lp = v.getLayoutParams();
        int height;
        if (position != mSrcPos && position != mFirstExpPos && position != mSecondExpPos)
        {
            height = ViewGroup.LayoutParams.WRAP_CONTENT;
        }
        else
        {
            height = calcItemHeight(position, v, invalidChildHeight);
        }

        if (height != lp.height)
        {
            lp.height = height;
            v.setLayoutParams(lp);
        }

        // Adjust item gravity
        if (position == mFirstExpPos || position == mSecondExpPos)
        {
            if (position < mSrcPos)
            {
                ((DragSortItemView) v).setGravity(Gravity.BOTTOM);
            }
            else if (position > mSrcPos)
            {
                ((DragSortItemView) v).setGravity(Gravity.TOP);
            }
        }

        // Finally adjust item visibility

        int oldVis = v.getVisibility();
        int vis = View.VISIBLE;

        if (position == mSrcPos && mFloatView != null)
        {
            vis = View.INVISIBLE;
        }

        if (vis != oldVis)
        {
            v.setVisibility(vis);
        }
    }

    private int getChildHeight(int position)
    {
        if (position == mSrcPos)
        {
            return 0;
        }

        View v = getChildAt(position - getFirstVisiblePosition());

        if (v != null)
        {
            // item is onscreen, therefore child height is valid,
            // hence the "true"
            return getChildHeight(position, v, false);
        }
        else
        {
            // item is offscreen
            // first check cache for child height at this position
            int childHeight = mChildHeightCache.get(position);
            if (childHeight != -1)
            {
                // Log.d("mobeta", "found child height in cache!");
                return childHeight;
            }

            final ListAdapter adapter = getAdapter();
            int type = adapter.getItemViewType(position);

            // There might be a better place for checking for the following
            final int typeCount = adapter.getViewTypeCount();
            if (typeCount != mSampleViewTypes.length)
            {
                mSampleViewTypes = new View[typeCount];
            }

            if (type >= 0)
            {
                if (mSampleViewTypes[type] == null)
                {
                    v = adapter.getView(position, null, this);
                    mSampleViewTypes[type] = v;
                }
                else
                {
                    v = adapter.getView(position, mSampleViewTypes[type], this);
                }
            }
            else
            {
                // type is HEADER_OR_FOOTER or IGNORE
                v = adapter.getView(position, null, this);
            }

            // current child height is invalid, hence "true" below
            childHeight = getChildHeight(position, v, true);

            // cache it because this could have been expensive
            mChildHeightCache.add(position, childHeight);

            return childHeight;
        }
    }

    private int getChildHeight(int position, View item, boolean invalidChildHeight)
    {
        if (position == mSrcPos)
        {
            return 0;
        }

        View child;
        if (position < getHeaderViewsCount() || position >= getCount() - getFooterViewsCount())
        {
            child = item;
        }
        else
        {
            child = ((ViewGroup) item).getChildAt(0);
        }

        ViewGroup.LayoutParams lp = child.getLayoutParams();

        if (lp != null)
        {
            if (lp.height > 0)
            {
                return lp.height;
            }
        }

        int childHeight = child.getHeight();

        if (childHeight == 0 || invalidChildHeight)
        {
            measureItem(child);
            childHeight = child.getMeasuredHeight();
        }

        return childHeight;
    }

    private int calcItemHeight(int position, View item, boolean invalidChildHeight)
    {
        return calcItemHeight(position, getChildHeight(position, item, invalidChildHeight));
    }

    private int calcItemHeight(int position, int childHeight)
    {
        boolean isSliding = mAnimate && mFirstExpPos != mSecondExpPos;
        int maxNonSrcBlankHeight = mFloatViewHeight - mItemHeightCollapsed;
        int slideHeight = (int) (mSlideFrac * maxNonSrcBlankHeight);

        int height;

        if (position == mSrcPos)
        {
            if (mSrcPos == mFirstExpPos)
            {
                if (isSliding)
                {
                    height = slideHeight + mItemHeightCollapsed;
                }
                else
                {
                    height = mFloatViewHeight;
                }
            }
            else if (mSrcPos == mSecondExpPos)
            {
                // if gets here, we know an item is sliding
                height = mFloatViewHeight - slideHeight;
            }
            else
            {
                height = mItemHeightCollapsed;
            }
        }
        else if (position == mFirstExpPos)
        {
            if (isSliding)
            {
                height = childHeight + slideHeight;
            }
            else
            {
                height = childHeight + maxNonSrcBlankHeight;
            }
        }
        else if (position == mSecondExpPos)
        {
            // we know an item is sliding (b/c 2ndPos != 1stPos)
            height = childHeight + maxNonSrcBlankHeight - slideHeight;
        }
        else
        {
            height = childHeight;
        }

        return height;
    }

    @Override
    public void requestLayout()
    {
        if (!mBlockLayoutRequests)
        {
            super.requestLayout();
        }
    }

    private int adjustScroll(int movePos, View moveItem, int oldFirstExpPos, int oldSecondExpPos)
    {
        int adjust = 0;

        final int childHeight = getChildHeight(movePos);

        int moveHeightBefore = moveItem.getHeight();
        int moveHeightAfter = calcItemHeight(movePos, childHeight);

        int moveBlankBefore = moveHeightBefore;
        int moveBlankAfter = moveHeightAfter;
        if (movePos != mSrcPos)
        {
            moveBlankBefore -= childHeight;
            moveBlankAfter -= childHeight;
        }

        int maxBlank = mFloatViewHeight;
        if (mSrcPos != mFirstExpPos && mSrcPos != mSecondExpPos)
        {
            maxBlank -= mItemHeightCollapsed;
        }

        if (movePos <= oldFirstExpPos)
        {
            if (movePos > mFirstExpPos)
            {
                adjust += maxBlank - moveBlankAfter;
            }
        }
        else if (movePos == oldSecondExpPos)
        {
            if (movePos <= mFirstExpPos)
            {
                adjust += moveBlankBefore - maxBlank;
            }
            else if (movePos == mSecondExpPos)
            {
                adjust += moveHeightBefore - moveHeightAfter;
            }
            else
            {
                adjust += moveBlankBefore;
            }
        }
        else
        {
            if (movePos <= mFirstExpPos)
            {
                adjust -= maxBlank;
            }
            else if (movePos == mSecondExpPos)
            {
                adjust -= moveBlankAfter;
            }
        }

        return adjust;
    }

    private void measureItem(View item)
    {
        ViewGroup.LayoutParams lp = item.getLayoutParams();
        if (lp == null)
        {
            lp = new AbsListView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            item.setLayoutParams(lp);
        }
        int wspec = ViewGroup.getChildMeasureSpec(mWidthMeasureSpec, getListPaddingLeft()
                + getListPaddingRight(), lp.width);
        int hspec;
        if (lp.height > 0)
        {
            hspec = MeasureSpec.makeMeasureSpec(lp.height, MeasureSpec.EXACTLY);
        }
        else
        {
            hspec = MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED);
        }
        item.measure(wspec, hspec);
    }

    private void measureFloatView()
    {
        if (mFloatView != null)
        {
            measureItem(mFloatView);
            mFloatViewHeight = mFloatView.getMeasuredHeight();
            mFloatViewHeightHalf = mFloatViewHeight / 2;
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        // Log.d("mobeta", "onMeasure called");
        if (mFloatView != null)
        {
            if (mFloatView.isLayoutRequested())
            {
                measureFloatView();
            }
            mFloatViewOnMeasured = true; // set to false after layout
        }
        mWidthMeasureSpec = widthMeasureSpec;
    }

    @Override
    protected void layoutChildren()
    {
        super.layoutChildren();

        if (mFloatView != null)
        {
            if (mFloatView.isLayoutRequested() && !mFloatViewOnMeasured)
            {
                // Have to measure here when usual android measure
                // pass is skipped. This happens during a drag-sort
                // when layoutChildren is called directly.
                measureFloatView();
            }
            mFloatView.layout(0, 0, mFloatView.getMeasuredWidth(), mFloatView.getMeasuredHeight());
            mFloatViewOnMeasured = false;
        }
    }

    private void onDragTouchEvent(MotionEvent ev)
    {
        switch (ev.getAction() & MotionEvent.ACTION_MASK)
        {
        case MotionEvent.ACTION_CANCEL:
            if (mDragState == DRAGGING)
            {
                cancelDrag();
            }
            doActionUpOrCancel();
            break;
        case MotionEvent.ACTION_UP:
            // Log.d("mobeta", "calling stopDrag from onDragTouchEvent");
            if (mDragState == DRAGGING)
            {
                stopDrag(false);
            }
            doActionUpOrCancel();
            break;
        case MotionEvent.ACTION_MOVE:
            continueDrag((int) ev.getX(), (int) ev.getY());
            break;
        }
    }

    /**
     * Start a drag of item at <code>position</code> using the
     * registered FloatViewManager. Calls through
     * to {@link #startDrag(int, View, int, int, int)} after obtaining
     * the floating View from the FloatViewManager.
     *
     * @param position  Item to drag.
     * @param dragFlags Flags that restrict some movements of the
     *                  floating View. For example, set <code>dragFlags |=
     *                  ~{@link #DRAG_NEG_X}</code> to allow dragging the floating
     *                  View in all directions except off the screen to the left.
     * @param deltaX    Offset in x of the touch coordinate from the
     *                  left edge of the floating View (i.e. touch-x minus float View
     *                  left).
     * @param deltaY    Offset in y of the touch coordinate from the
     *                  top edge of the floating View (i.e. touch-y minus float View
     *                  top).
     * @return True if the drag was started, false otherwise. This
     * <code>startDrag</code> will fail if we are not currently in
     * a touch event, there is no registered FloatViewManager,
     * or the FloatViewManager returns a null View.
     */
    boolean startDrag(int position, int dragFlags, int deltaX, int deltaY)
    {
        if (!mInTouchEvent || mFloatViewManager == null)
        {
            return false;
        }

        View v = mFloatViewManager.onCreateFloatView(position);

        if (v == null)
        {
            return false;
        }
        else
        {
            return startDrag(position, v, dragFlags, deltaX, deltaY);
        }

    }

    /**
     * Start a drag of item at <code>position</code> without using
     * a FloatViewManager.
     *
     * @param position  Item to drag.
     * @param floatView Floating View.
     * @param dragFlags Flags that restrict some movements of the
     *                  floating View. For example, set <code>dragFlags |=
     *                  ~{@link #DRAG_NEG_X}</code> to allow dragging the floating
     *                  View in all directions except off the screen to the left.
     * @param deltaX    Offset in x of the touch coordinate from the
     *                  left edge of the floating View (i.e. touch-x minus float View
     *                  left).
     * @param deltaY    Offset in y of the touch coordinate from the
     *                  top edge of the floating View (i.e. touch-y minus float View
     *                  top).
     * @return True if the drag was started, false otherwise. This
     * <code>startDrag</code> will fail if we are not currently in
     * a touch event, <code>floatView</code> is null, or there is
     * a drag in progress.
     */
    private boolean startDrag(int position, View floatView, int dragFlags, int deltaX, int deltaY)
    {
        if (mDragState != IDLE || !mInTouchEvent || mFloatView != null || floatView == null
                || !mDragEnabled)
        {
            return false;
        }

        if (getParent() != null)
        {
            getParent().requestDisallowInterceptTouchEvent(true);
        }

        int pos = position + getHeaderViewsCount();
        mFirstExpPos = pos;
        mSecondExpPos = pos;
        mSrcPos = pos;
        mFloatPos = pos;

        // mDragState = dragType;
        mDragState = DRAGGING;
        mDragFlags = 0;
        mDragFlags |= dragFlags;

        mFloatView = floatView;
        measureFloatView(); // sets mFloatViewHeight

        mDragDeltaX = deltaX;
        mDragDeltaY = deltaY;

        // updateFloatView(mX - mDragDeltaX, mY - mDragDeltaY);
        mFloatLoc.x = mX - mDragDeltaX;
        mFloatLoc.y = mY - mDragDeltaY;

        // set src item invisible
        final View srcItem = getChildAt(mSrcPos - getFirstVisiblePosition());

        if (srcItem != null)
        {
            srcItem.setVisibility(View.INVISIBLE);
        }

        // once float view is created, events are no longer passed
        // to ListView
        switch (mCancelMethod)
        {
        case ON_TOUCH_EVENT:
            super.onTouchEvent(mCancelEvent);
            break;
        case ON_INTERCEPT_TOUCH_EVENT:
            super.onInterceptTouchEvent(mCancelEvent);
            break;
        }

        requestLayout();
        return true;
    }

    private void doDragFloatView(boolean forceInvalidate)
    {
        int movePos = getFirstVisiblePosition() + getChildCount() / 2;
        View moveItem = getChildAt(getChildCount() / 2);

        if (moveItem == null)
        {
            return;
        }

        doDragFloatView(movePos, moveItem, forceInvalidate);
    }

    private void doDragFloatView(int movePos, View moveItem, boolean forceInvalidate)
    {
        mBlockLayoutRequests = true;

        updateFloatView();

        int oldFirstExpPos = mFirstExpPos;
        int oldSecondExpPos = mSecondExpPos;

        boolean updated = updatePositions();

        if (updated)
        {
            adjustAllItems();
            int scroll = adjustScroll(movePos, moveItem, oldFirstExpPos, oldSecondExpPos);
            // Log.d("mobeta", "  adjust scroll="+scroll);

            setSelectionFromTop(movePos, moveItem.getTop() + scroll - getPaddingTop());
            layoutChildren();
        }

        if (updated || forceInvalidate)
        {
            invalidate();
        }

        mBlockLayoutRequests = false;
    }

    /**
     * Sets float View location based on suggested values and
     * constraints set in mDragFlags.
     */
    private void updateFloatView()
    {

        if (mFloatViewManager != null)
        {
            mTouchLoc.set(mX, mY);
            mFloatViewManager.onDragFloatView(mFloatView, mFloatLoc, mTouchLoc);
        }

        final int floatX = mFloatLoc.x;
        final int floatY = mFloatLoc.y;

        // restrict x motion
        int padLeft = getPaddingLeft();
        if ((mDragFlags & DRAG_POS_X) == 0 && floatX > padLeft)
        {
            mFloatLoc.x = padLeft;
        }
        else if ((mDragFlags & DRAG_NEG_X) == 0 && floatX < padLeft)
        {
            mFloatLoc.x = padLeft;
        }

        // keep floating view from going past bottom of last header view
        final int numHeaders = getHeaderViewsCount();
        final int numFooters = getFooterViewsCount();
        final int firstPos = getFirstVisiblePosition();
        final int lastPos = getLastVisiblePosition();

        int topLimit = getPaddingTop();
        if (firstPos < numHeaders)
        {
            topLimit = getChildAt(numHeaders - firstPos - 1).getBottom();
        }
        if ((mDragFlags & DRAG_NEG_Y) == 0)
        {
            if (firstPos <= mSrcPos)
            {
                topLimit = Math.max(getChildAt(mSrcPos - firstPos).getTop(), topLimit);
            }
        }
        // bottom limit is top of first footer View or
        // bottom of last item in list
        int bottomLimit = getHeight() - getPaddingBottom();
        if (lastPos >= getCount() - numFooters - 1)
        {
            bottomLimit = getChildAt(getCount() - numFooters - 1 - firstPos).getBottom();
        }
        if ((mDragFlags & DRAG_POS_Y) == 0)
        {
            if (lastPos >= mSrcPos)
            {
                bottomLimit = Math.min(getChildAt(mSrcPos - firstPos).getBottom(), bottomLimit);
            }
        }

        if (floatY < topLimit)
        {
            mFloatLoc.y = topLimit;
        }
        else if (floatY + mFloatViewHeight > bottomLimit)
        {
            mFloatLoc.y = bottomLimit - mFloatViewHeight;
        }

        // get y-midpoint of floating view (constrained to ListView bounds)
        mFloatViewMid = mFloatLoc.y + mFloatViewHeightHalf;
    }

    private void destroyFloatView()
    {
        if (mFloatView != null)
        {
            mFloatView.setVisibility(GONE);
            if (mFloatViewManager != null)
            {
                mFloatViewManager.onDestroyFloatView(mFloatView);
            }
            mFloatView = null;
            invalidate();
        }
    }

    /**
     * Interface for customization of the floating View appearance
     * and dragging behavior.
     */
    interface FloatViewManager
    {
        /**
         * Return the floating View for item at <code>position</code>.
         * DragSortListView will measure and layout this View for you,
         * so feel free to just inflate it. You can help DSLV by
         * setting some {@link ViewGroup.LayoutParams} on this View;
         * otherwise it will set some for you (with a width of FILL_PARENT
         * and a height of WRAP_CONTENT).
         *
         * @param position Position of item to drag (NOTE:
         *                 <code>position</code> excludes header Views; thus, if you
         *                 want to call {@link ListView#getChildAt(int)}, you will need
         *                 to add {@link ListView#getHeaderViewsCount()} to the index).
         * @return The View you wish to display as the floating View.
         */
        View onCreateFloatView(int position);

        /**
         * Called whenever the floating View is dragged. Float View
         * properties can be changed here. Also, the upcoming location
         * of the float View can be altered by setting
         * <code>location.x</code> and <code>location.y</code>.
         *
         * @param floatView The floating View.
         * @param location  The location (top-left; relative to DSLV
         *                  top-left) at which the float
         *                  View would like to appear, given the current touch location
         *                  and the offset provided in {@link DragSortListView#startDrag}.
         * @param touch     The current touch location (relative to DSLV
         *                  top-left).
         */
        void onDragFloatView(View floatView, Point location, Point touch);

        /**
         * Called when the float View is dropped; lets you perform
         * any necessary cleanup. The internal DSLV floating View
         * reference is set to null immediately after this is called.
         *
         * @param floatView The floating View passed to
         *                  {@link #onCreateFloatView(int)}.
         */
        void onDestroyFloatView(View floatView);

        /**
         * Register a class which will get onTouch events.
         */
        void setSecondaryOnTouchListener(View.OnTouchListener l);
    }

    private void setDragListener(DragListener l)
    {
        mDragListener = l;
    }

    boolean isDragEnabled()
    {
        return mDragEnabled;
    }

    public void setDropListener(DropListener l)
    {
        mDropListener = l;
    }

    /**
     * Probably a no-brainer, but make sure that your remove listener
     * calls {@link BaseAdapter#notifyDataSetChanged()} or something like it.
     * When an item removal occurs, DragSortListView
     * relies on a redraw of all the items to recover invisible views
     * and such. Strictly speaking, if you remove something, your dataset
     * has changed...
     */
    private void setRemoveListener(RemoveListener l)
    {
        mRemoveListener = l;
    }

    interface DragListener
    {
        void drag(int from, int to);
    }

    /**
     * Your implementation of this has to reorder your ListAdapter!
     * Make sure to call
     * {@link BaseAdapter#notifyDataSetChanged()} or something like it
     * in your implementation.
     *
     * @author heycosmo
     */
    public interface DropListener
    {
        void drop(int from, int to);
    }

    /**
     * Make sure to call
     * {@link BaseAdapter#notifyDataSetChanged()} or something like it
     * in your implementation.
     *
     * @author heycosmo
     */
    interface RemoveListener
    {
        void remove(int which);
    }

    /**
     * Interface for controlling
     * scroll speed as a function of touch position and time.
     */
    interface DragScrollProfile
    {
        /**
         * Return a scroll speed in pixels/millisecond. Always return a
         * positive number.
         *
         * @param w Normalized position in scroll region (i.e. w \in [0,1]).
         *          Small w typically means slow scrolling.
         * @param t Time (in milliseconds) since start of scroll (handy if you
         *          want scroll acceleration).
         * @return Scroll speed at position w and time t in pixels/ms.
         */
        float getSpeed(float w, long t);
    }

    private class DragScroller implements Runnable
    {

        private boolean mAbort;

        private long mPrevTime;
        private long mCurrTime;

        private int dy;
        private float dt;
        private long tStart;
        private int scrollDir;

        final static int STOP = -1;
        final static int UP = 0;
        final static int DOWN = 1;

        private float mScrollSpeed; // pixels per ms

        private boolean mScrolling = false;

        boolean isScrolling()
        {
            return mScrolling;
        }

        int getScrollDir()
        {
            return mScrolling ? scrollDir : STOP;
        }

        DragScroller()
        {
        }

        void startScrolling(int dir)
        {
            if (!mScrolling)
            {
                // Debug.startMethodTracing("dslv-scroll");
                mAbort = false;
                mScrolling = true;
                tStart = SystemClock.uptimeMillis();
                mPrevTime = tStart;
                scrollDir = dir;
                post(this);
            }
        }

        void stopScrolling(boolean now)
        {
            if (now)
            {
                DragSortListView.this.removeCallbacks(this);
                mScrolling = false;
            }
            else
            {
                mAbort = true;
            }

            // Debug.stopMethodTracing();
        }

        @Override
        public void run()
        {
            if (mAbort)
            {
                mScrolling = false;
                return;
            }

            // Log.d("mobeta", "scroll");

            final int first = getFirstVisiblePosition();
            final int last = getLastVisiblePosition();
            final int count = getCount();
            final int padTop = getPaddingTop();
            final int listHeight = getHeight() - padTop - getPaddingBottom();

            int minY = Math.min(mY, mFloatViewMid + mFloatViewHeightHalf);
            int maxY = Math.max(mY, mFloatViewMid - mFloatViewHeightHalf);

            if (scrollDir == UP)
            {
                View v = getChildAt(0);
                // Log.d("mobeta", "vtop="+v.getTop()+" padtop="+padTop);
                if (v == null)
                {
                    mScrolling = false;
                    return;
                }
                else
                {
                    if (first == 0 && v.getTop() == padTop)
                    {
                        mScrolling = false;
                        return;
                    }
                }
                mScrollSpeed = mScrollProfile.getSpeed((mUpScrollStartYF - maxY)
                        / mDragUpScrollHeight, mPrevTime);
            }
            else
            {
                View v = getChildAt(last - first);
                if (v == null)
                {
                    mScrolling = false;
                    return;
                }
                else
                {
                    if (last == count - 1 && v.getBottom() <= listHeight + padTop)
                    {
                        mScrolling = false;
                        return;
                    }
                }
                mScrollSpeed = -mScrollProfile.getSpeed((minY - mDownScrollStartYF)
                        / mDragDownScrollHeight, mPrevTime);
            }

            mCurrTime = SystemClock.uptimeMillis();
            dt = (float) (mCurrTime - mPrevTime);

            // dy is change in View position of a list item; i.e. positive dy
            // means user is scrolling up (list item moves down the screen,
            // remember
            // y=0 is at top of View).
            dy = Math.round(mScrollSpeed * dt);

            int movePos;
            if (dy >= 0)
            {
                dy = Math.min(listHeight, dy);
                movePos = first;
            }
            else
            {
                dy = Math.max(-listHeight, dy);
                movePos = last;
            }

            final View moveItem = getChildAt(movePos - first);
            int top = moveItem.getTop() + dy;

            if (movePos == 0 && top > padTop)
            {
                top = padTop;
            }

            // always do scroll
            mBlockLayoutRequests = true;

            setSelectionFromTop(movePos, top - padTop);
            DragSortListView.this.layoutChildren();
            invalidate();

            mBlockLayoutRequests = false;

            // scroll means relative float View movement
            doDragFloatView(movePos, moveItem, false);

            mPrevTime = mCurrTime;
            // Log.d("mobeta", "  updated prevTime="+mPrevTime);

            post(this);
        }
    }
}
