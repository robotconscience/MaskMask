#Mask-Mask

Mask Mask is a tool for prototyping with projection. It is a Mac-only app that allows for the quick creation of shapes that mask your entire screen. This lets you try any app your heart desires underneath–be it YouTube videos, live drawing in Photoshop, GIFs on Tumblr, etc!

##FAQ
* *Why did you make this?*
  * **Short:** I love projection. It's easy to get up-and-running, and a great way to test everything from size of a screen to the speed of an animation. I wanted an easy way for myself, my students, my friends, etc, to quickly prototype with projection on objects and environments. 
  * **Long:** I was at a concert at the Guggenheim in NYC that featured a lovely ambient loop of video projected behind the performer. The problem was, the Guggenheim is an incredible unique piece of architecture and this artist had prepared a normal 16:9 projection that was spilling over onto many surfaces. It looked weird, and kind of bad. Nit-picky? Maybe. But, at that moment, I realized that if they'd had an app to simply "cut out" the surface they were projecting on, and react to the angles of the Guggenheim, their backdrop would have looked amazing. After a bit of experimentation, I realized I could pretty easily make a mask that floated over an entire screen, allowing even the artist I saw to project anywhere and have it look intentional with a minimal amount of setup. After using a rudimentary version of this tool in an installation for a client, I've spent the last few months rolling the tool into MaskMask. Enjoy!

* *Is this a projection mapping app?*
  * Nope! Projection masking is simply projecting only onto the surface you want to put visuals onto. Projection mapping usually requires some type of warping to compensate for perspective, complicated geometry, etc. I've been working on a [running list of projection mapping tools](https://github.com/robotconscience/InteractiveResources/wiki/1.b.-Techniques:-Projection-Mapping), so head there if that's what you're looking for!

* *Why is this Mac-only?*
  * Because I'm not smart enough to make a Windows version! I believe it's possible, but it'd require a level of Windows expertise I don't have. Interested in forking/cloning this project for Windows? Please do!

##Setup
* This app is based on [openFrameworks](http://github.com/openFrameworks/openFrameworks) and requires the [ofxCocoaGLView](https://github.com/robotconscience/ofxCocoaGLView) addon.
  * Clone openFrameworks
  * cd into openFrameworks/addons
  * Clone [ofxCocoaGLView](https://github.com/robotconscience/ofxCocoaGLView)
  * Clone this repo into apps/myApps (or a similar level)
  * You will not have any of the fonts! <-- I'm figuring this out, and may in the end just use a system font. Stay tuned.