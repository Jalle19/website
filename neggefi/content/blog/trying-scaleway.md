+++
date = "2016-11-24T11:40:41+02:00"
title = "Trying Scaleway's dedicated ARM servers"
type = "post"
+++

While UpCloud is great, I realized I'm spending a bit too much money just to host a static website. The idea was 
originally to host other things on the server as well, but I never got around to doing that. So I started looking for 
cheaper alternatives.

There was a great article on Hacker News the other day 
([Ask HN: What free or low-cost static site hosting do you use most?](https://news.ycombinator.com/item?id=13021722)) 
where I found some reasonable alternatives. I first looked at [Netlify](https://www.netlify.com/). Their service seems 
to offer just what I need, and it's apparently free as long as you don't have that many visitors.

After reading a bit more someone mentioned a new player called [Scaleway](https://www.scaleway.com/). I vaguely 
remember reading about them on Hacker News over a year ago when they announced themselves. I had completely forgotten 
about them though, so I decided to check them out for real this time.

What's interesting about Scaleway is that they offer dedicated ARM-based quad-core servers (with 2 GB RAM, 50 GB of 
disk storage, and an unlimited 200 Mbit/s network connection) for just 2,99 € / month. Normally if it sounds too good 
to be true, it probably isn't, and this is no exception.

The management interface is very good, and provisioning a new bare metal server takes about as long as provisioning a 
VPS on any other cloud provider. What they don't really mention in their sales material is that the hard disk is 
never local - your server is booted over PXE and then bootstrapped into a locally mounted NBD device. This means disk 
I/O performance is pretty abysmal (`hdparm` gave me roughly 50 MB/s). For web site hosting this isn't a big deal, but 
it's still pretty lame.

Once the server was deployed it was time to provision some software on it so I could host this site on it. In contrast 
to reports from 2015 saying many packages don't work or aren't available on armhf, everything installed just fine. The 
only difference for me compared to my previous UpCloud server was that I couldn't use Packer to build a template (there 
is a community-built [Packer builder for Scaleway](https://github.com/meatballhat/packer-builder-onlinelabs) but I 
haven't tried it). Apart from that it was just a matter of changing the DNS record and kicking Capistrano once to get 
the site deployed again.

Continuing on the performance part, if you can live with bad disk I/O the server is pretty snappy. I wouldn't try 
comparing it to similar x86 offerings, but for basic stuff it's pretty good. Plus, at 2,99 € / month per server you 
can scale pretty cheaply.

Other downsides include no IPv6 support (you'll find people ranting about it on the Internet), and `ufw` (the firewall) 
doesn't work like you'd expect since the root device is mounted over the network. I ended up using a rather lame 
workaround where instead of changing the default INPUT policy to DROP I manually append a "drop all" rule to the INPUT 
chain. While this works, it's a bit unfortunate since you have to bypass `ufw''s noob-friendliness and deal with the 
underlying iptables layer directly. But hey, it works!

So there you have it, this site is now served to you from a dedicated ARM server!
