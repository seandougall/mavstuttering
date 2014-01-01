Mavericks Stuttering
====================

This is a demo app to illustrate bad refresh rates in OS X 10.9 Mavericks.

## About the bug

### Title

Poor refresh rates with multiple display links under Mavericks

### Summary

When two NSOpenGLViews are rendering to different screens, each using its own display link, redrawing is normally reasonably close to full refresh rate. However, if the view on the external display covers the entire screen, something causes -[NSOpenGLContext flushBuffer] to block for inordinately long times, resulting in a dramatically reduced refresh rate (often as low as 8 fps).

### Steps to reproduce

1) Create two borderless windows, one filling each of two displays.
2) Make each window's content view an instance of an NSOpenGLView subclass.
3) Make each view set up its own display link for the screen it's on.
4) Start rendering, and keep track of the refresh rate.

### Expected results

With minimal rendering load, it should be possible to get more or less full-framerate redrawing.

### Actual results

If (and only if) the external display is completely covered by one of these views, its refresh rate varies wildly, often dipping down to less than 10% of full framerate. 

### Regression

The same code renders at full framerate (or close enough to appear smooth) if any of the following is true:

1) it is run in 10.8.x or earlier.
2) any amount of the external display (even a single row of pixels) is left unoccluded by the borderless window.
3) rendering happens only on one display.
4) the window is set to non-opaque, with any alpha value < 1.0 (though overall performance is degraded by the extra load on WindowServer).

### Notes

Attached is code for a sample app that demonstrates this problem when run with an external display attached. The different modes either cover the screens fully or leave the bottom few rows of pixels open. Both of the modes that fully and opaquely cover the external display should show stuttering, and the real refresh rate is logged to the console periodically.

In case of a problem with the attachment, this code can also be found at [https://github.com/seandougall/mavstuttering](https://github.com/seandougall/mavstuttering).

Also: CVDisplayLinkGetActualOutputVideoRefreshPeriod does not show the problem, evidently because the display link is still firing at the correct rate; the problem is that -flushBuffer is blocking.