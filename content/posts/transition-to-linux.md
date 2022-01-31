---
title: "My Transition to Linux"
date: 2021-11-18T22:46:03+08:00
draft: true
toc: false
images:
tags:
  - linux
  - reflections
---

{{< figure src="https://imgs.xkcd.com/comics/cautionary.png" caption="relevant xkcd 456" link="https://xkcd.com/456" class="center" >}}

Learning and experimenting with Linux and Unix tools had always been on my mind.
This year, I finally had the time, motivation and courage to dive into it
proper.

<!--more-->

## Time

Graduating meant that I had some downtime for self learning.

## Motivation

I'm going to be honest here - the largest motivator for learning Linux was my
hatred of Windows. A weekend of reinstalling Windows after a broken update was
the last straw[^1]. I primarily worked on Linux VMs thereafter, before finally
moving full-time to Xubuntu[^2] with a Windows VM.

I'm not saying Windows is terrible. I'm just saying its terrible for me. There
are many [problems]() with the Linux ecosystem, and I will say its definitely
not for the average user who just wishes to get things done. There are many
things that will not *just* work.

Even so, there were pull factors that drew me into Linux
- Better support for dev tooling and packages (especially Docker)
- Flexibility and [customization](https://reddit.com/r/unixporn)
- Fun

I came for the first point but probably stuck around due to the latter two. The
process of customization in `r/unixporn`, `r/vim` and `r/neovim` probably taught
me much more about shell scripting than I can learn from any videos or tutorials.
`r/selfhosted` also opened the doors to FOSS, DevOps, automation and network
security, which are all super interesting to me.

## Courage

Another confession - half the time, I don't really know what I'm doing. That was
probably what put me off the command line for so long. Linux commands aren't
really interactive. That was scary. I had to come to terms with the fact that
having no output is usually a good thing.

Increased exposure and use of tools eventually led to familiarity and habit. Its
important to start small and pick up new information as you go along. For
example, before I made the switch to Linux full-time, I "rehearsed" the
installation of my tools, packages and dotfiles in the VM. I assumed the actual
installation and setup would then be quick and easy.

I was wrong of course. As I have been working exclusively on VMs, I failed to
account for the necessary drivers that were absent or incompatible. Cue 3 hours
of troubleshooting before I got my Wifi and graphics card to work. It was a boon
however, as I did learn a whole lot more about troubleshooting in Linux systems
(which is a plus since I work in environment stability!).

## Outcome

What started out as a goal to stop using Windows out of spite has opened many
doors. Through the process, I have picked up many tools and concepts
- Operating systems, computer networking
- Containers and Virtualization (Docker and Vagrant)
- Proper use of Git and Github
- Automation (Ansible and Terraform)
- Vim!!

If you are going through a similar journey, I have just one piece of advice:
Docker and Vagrant are your friends. A lab environment is REALLY, REALLY
helpful. It incentivizes you to test things out, providing some hands-on
experience, while not having to worry about breaking your system.

There's still a few kinks in my new system but I'm satisfied and happy with the
outcome. The journey has been a fruitful one and I look forward to learning more
everyday.

[^1]: Thankfully, my backup systems made the process much smoother than it would have been otherwise.
[^2]: Still testing out Arch on the side
