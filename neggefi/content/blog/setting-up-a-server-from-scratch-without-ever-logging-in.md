+++
date = "2016-09-29T19:21:01+03:00"
title = "Setting up a server from scratch without ever logging in to it"
type = "post"
tags = ["x", "y"]
categories = ["x", "y"]
+++

Technical people often use different blogging platforms than "normal people". One particularly appealing option is to 
use a static site generator instead of a more traditional blogging or CMS platform (like WordPress). Using a static 
site generator has a few perks, a major one being you can host it for free on e.g. GitHub pages.

If you don't want to leech some free hosting, you can always just get a good old server somewhere and host everything 
on that. I'm a strong believer in making automated and reproducable infrastructure, so I thought I'd explain how the 
server serving you this content was set up from scratch, without me ever logging in to it to manually configure things.

Granted, it's pretty easy to just get a server somewhere, log into to it with the auto-generated password, run 
`apt-get install nginx`, drop some files on it and be good to go. It's also not very interesting.

There are a lot of different tools I've had to use in this process:

* Packer, for creating a template on UpCloud which I can use to launch an instance of my server
* Ansible, for provisioning the server (user account, firewall, nginx, Hugo)
* Capistrano, for trigger re-provisioning and for deploying new content to the website

## Building the server

The first step was to create a bare-bones server template that I can use to spin up the server. The idea is that once 
you have the server and are able to access it, you can continue to refine the provisioning process with almost instant 
feedback. This is easier than attempting to get everything right on the first shot.

This bare-bones build basically has this:

* a user account with sudo access. The only way to authenticate is by using an SSH key pair.
* some firewall rules. It's enough to allow `tcp/22` at this stage.

