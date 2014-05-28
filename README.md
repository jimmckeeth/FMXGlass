FMXGlass
========

Glass overlays to apply effects to portions of the underlying form. 

Inspired by & based on the the [answer on StackOverflow](http://stackoverflow.com/a/23900954/255) by Eric.

TGlass paints itself with what it covers on its parents (like it is transparent, but it actually contains what it covers).

The TGlass desendents then apply an effect.

This allows applying an effect to a portion of a form, including multiple controls.

Currently Blur and Pixelate are implemented, more will follow.

Has a crude caching mechanism to only apply the effect if the parent image changes.

Ignores other instances of TGlass if they are stacked.
