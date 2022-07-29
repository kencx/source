---
title: "Transition to Linux"
date: 2021-11-18T22:46:03+08:00
lastmod: 2021-12-01
draft: false
toc: true
images:
tags:
  - linux
---

{{< figure src="https://imgs.xkcd.com/comics/cautionary.png" caption="relevant xkcd 456" link="https://xkcd.com/456" class="center" >}}

Learning and experimenting with Linux and Unix tools had always been on my mind.
This year, I finally had the time, motivation and courage to dive into it
proper.

<!--more-->

## Time

I had a surprising amount of free time to do tons of self studying. It also
helps that I work with Linux systems at work.

## Motivation

I'm going to be honest here - the largest motivator for learning Linux was my
hatred of Windows. A weekend of reinstalling Windows after a broken update was
the last straw[^1]. I primarily worked on Linux VMs thereafter, before finally
moving full-time to Xubuntu[^2].

I'm not saying Windows is terrible. I'm just saying its terrible for me. There
are many [problems](https://corn.codeberg.page/notlinux.html) with the Linux
ecosystem, and I will say its definitely not for the average user who just
wishes to get things done. There are many things that will **not** just work.
You **must** be ready to tinker.

Even so, there were pull factors that drew me to using Linux
- Better support for dev tooling and packages (especially [Docker](https://www.docker.com/))
- Flexibility and [customization](https://github.com/kencx/dotfiles)
- Fun

I came for the first point but probably stuck around due to the latter two.
[Ricing](https://www.reddit.com/r/unixporn/)[^3] my system probably taught me
much more than any tutorial or book. I also learned an unnecessary amount of
[Lua](https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/)
just from configuring neovim.

## Courage

In the beginning, I was really scared of the terminal. That put me of learning
Linux for a few years. Linux commands aren't really interactive. That was scary.
I had to come to terms with the fact that having no output is usually a good
thing. But we all have to start somewhere.

Increased exposure eventually led to familiarity and habit. Its important to
start small and pick up new information as you go along. For example, before I
made the switch to Linux full-time, I mainly worked on a VM. When I decided to
make the switch to a bare-metal OS, I made sure to "rehearse" the full
installation, understanding what I was doing at every step. Of course, things
never go as planned.

As I have been working exclusively on VMs, I failed to account for the necessary
(Nvidia) drivers that were absent or incompatible. Cue 3 hours of
troubleshooting before I got my Wifi and graphics card to work. It was a boon
however, as I did learn a whole lot more about troubleshooting in Linux systems
(which is a plus since I work in environment stability!).

>Bonus: A full installation now just takes me 10 minutes with Ansible![^4]

## Outcome

What started out as a goal to stop using Windows out of spite has evolved into
something more. Through the process, I have picked up many other concepts and
tools:
- Operating systems, computer networking
- Containers and Virtualization
- Proper use of Git and Github
- Automation (Ansible and CI/CD)
- (n)vim!!

and the journey isn't ending any time soon.

If you are going through a similar journey, I have just one piece of advice:
Docker and Vagrant are your friends. A lab environment is **REALLY, REALLY**
helpful. It incentivizes you to test things out, providing some hands-on
experience, while not having to worry about breaking your system.

There's still a few kinks in my new system but I'm satisfied and happy with the
outcome. The journey has been a fruitful one and I look forward to learning more
everyday.

[^1]: Thankfully, my backup systems made the process much smoother than it would
  have been otherwise.
[^2]: Still testing out Arch on the side
[^3]: Ricing is the process of customizing your Unix desktop visually.
[^4]: I created a full [Ansible playbook](https://github.com/kencx/playbooks) to
  configure my entire workstation from scratch with just one command.
