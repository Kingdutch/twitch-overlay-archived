# Kingdutch Twitch Overlay - Archived

*This repository has been superceded by a project which is not currently public.
This repository has been left up for people to reference.*

This repository contains the overlay used for streams at twitch.tv/TheKingdutch

It provides info about where you can find me on the internet and shows the current
title of my stream. It also provides an animated standby screen for before the stream
and during short breaks.

To see how the overlays are build look at the Kingdutch__TwitchOverlay__Scenes_** modules.
For info on how the stream title is fetched from the Twitch API take a look at the
Kingdutch__TwitchOverlay__Hooks module.

If you want to run this overlay yourself you will have to create a Twitch application
at dev.twitch.tv/ in order to be able to talk to the Twitch API. The configuration for
the overlay is done by copying `config.example.js` to `config.js` filling in the values.

The overlay can be started using:

```
yarn start
```

By default it will show the standby screen. By using a URL hash you can navigate to 
`#overlay` for the main overlay or `#brb` for the break screen.

![The standby screen shows the streamer name and the stream title. The background is a solid color with animated bubbles.](docs/assets/standby-preview.png)

![The overlay has a titlebar and two main content sections. In the left 1/3rd is space for a webcam and chat. The right 2/3rd shows the main stream content.](docs/assets/overlay-preview.png)
