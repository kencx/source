---
title: "Keyboards - Planck"
date: 2022-01-21T17:10:11+08:00
lastmod: 2024-01-22
draft: true
toc: true
tags:
  - keyboards
---

{{< figure src="https://imgs.xkcd.com/comics/borrow_your_laptop.png" caption="relevant xkcd 1806" link="https://xkcd.com/1806" class="center" >}}

At the time of writing, I have been using the [Planck
keyboard](https://olkb.com/collections/planck) for almost a year. Specs ([bill of materials](#bill-of-materials)):
- 67g Tangerines linear switches
- Black DSA blank keycaps
- Lubed and filmed with Krytox 205g0 and Deskeys


{{< figure src="/posts/keyboards/images/planck.png" caption="The Planck Rev 6" alt="The Planck Rev 6" class="center" width="350px">}}

## Features

I got the Planck because I wanted to try out a 40% ortholinear keyboard. Why? I
just thought it might be fun.

The Planck has a 4x12 layout with a maximum of just 48 keys. It is fully
programmable with [QMK firmware](https://github.com/qmk/qmk_firmware) and fully
hotswappable[^1].

As far as 40% keyboards go, the Planck is a classic choice. Layers[^2] make up
for the lack of number and function rows, and you can create some cool key
combos based on your workflow.

However, the ortholinear layout does take some time getting used to, as opposed
to the staggered layout. My WPM fell sharply in my first 3 weeks, but I adapted
quickly as I was already practicing touch typing. I also switched to the Planck
around the time I was fully writing my undergraduate thesis which helped me
practice.

{{< figure src="/posts/keyboards/images/monkeytype.png" caption="You can clearly see the steep drop, followed by consistently low tries. From [monkeytype.com](https://monkeytype.com)" alt="My drop in WPM" class="center" >}}

The most challenging aspect by far (even now), is typing symbols. I struggled
greatly with typing passwords and the use of symbols in programming. I've gotten
a little better now - I can pinpoint `$` as the 4th symbol, although I still
occasionally mix up the positions of `%, ^, &` and `*`.

I also discovered that I use my index finger to hit the spacebar as opposed to
my thumbs and this is considered weird. To me, it seems natural, granted I've
been doing it all my life. I did consider forcing myself to relearn this but I
didn't see a point since my keyboard was already so tiny.

## Layout

As the Planck is fully programmable, you can come up with some fun custom
layouts with QMK. My personal Planck layout is tailored towards programming,
(neo)vim and Linux systems, as these are what I primarily work with.

I have 3 main layers that I use: the home layer, number layer and symbols layer.
The layouts of each layer also are made with two rules in mind.
- Each command key binding must not consist of more than 2 keys with one hand
- The 2 keys to be pressed with one hand must not be too far away from each
  other.

For example, instead of `Ctrl + Shift + A`, which is 3 keys with the left hand,
I use `Ctrl + Shift + L` - 2 keys on the left, 1 on the right. `Ctrl` is
also quite far from the home row, which I solve by binding it to `F` and `J`, as
can be seen below. It is only activated when *held down*. Having it on both keys
allows me to have any `Ctrl + [a-z]` combo without straining my fingers. I use
this a lot as I navigate between tmux panes and vim windows with `Ctrl +
h,j,k,l`.

{{< figure src="/posts/keyboards/images/home-layer.png" caption="Home Layer" alt="Home Layer" class="center" width="650px">}}

Also, I found that I use caps lock enough (like once a day) that it
deserved to be somewhere accessible. Instead of a whole dedicated key, caps lock
is activated and deactivated by quickly tapping `Esc` twice.

{{< figure src="/posts/keyboards/images/number-layer.png" caption="Number Layer (Lower)" alt="Number Layer" class="center" width="650px">}}

The number and function keys are arranged in a numpad layout in the lower layer.
It has worked well for me so far.

{{< figure src="/posts/keyboards/images/symbols-layer.png" caption="Symbols Layer (Raise)" alt="Symbols Layer" class="center" width="650px">}}

Finally, the symbols are arranged in their typical fashion on the num row. I
moved the bracket pairs (,[,{ next to each other for easy access.

I specifically binded the number keys, which are on the `Lower` layer, to my
right hand. That way, I can hold down `Lower` with my left hand and press any
number with my right. This goes for symbol keys on the `Raise` layer as well.

This will not be the final layout. I am constantly tweaking it to find out what
works best. I also have yet to leverage the full power of QMK. I plan to
incorporate the use of [tap dance](https://docs.qmk.fm/#/feature_tap_dance)
keys, [macros](https://docs.qmk.fm/#/feature_macros) and add a whole new layer
just for window navigation.

## Future

I gotten really comfortable with the Planck, but my keyboard journey doesn't
stop here. I have also soldered and built the
[Discipad](https://github.com/coseyfannitutti/discipad), which I will hopefully
write about soon, and I currently am working on the
[Lumberjack](https://github.com/peej/lumberjack-keyboard), although its on hold
at the moment.


## Bill of Materials

| Item                    | Price (SGD)             | Link      |
| :---------------------- | :---------------------- | :---------|
| Planck Rev 6            | 161.99 (incl. shipping) | [Massdrop](https://drop.com/buy/planck-mechanical-keyboard)  |
| 50x Tangerines          | 48.60                   | [Ilumkb](https://ilumkb.com/collections/switches/products/c3-tangerine-switch)    |
| Black blank DSA keycaps | 15.24                   | Aliexpress|
| 1x 2u Stabilizer        | 3.79                    | Aliexpress|
| Deskeys switch film     | 4.35                    | Aliexpress|
| Lube kit                | 13.50                   | Carousell |
| Total					  | 247.47					| |

You also need the following optional items:
- Switch puller
- Switch opener (or use a screwdriver)

[^1]: Soldering is fun, but there are other opportunities for that.
[^2]: Layers are activated by holding down the *raise* or *lower* keys and pressing the desired key.
