+++
date = "2016-09-29T19:21:01+03:00"
title = "Setting up a server from scratch without ever logging in to it"
type = "post"
+++

Technical people often use different blogging platforms than "normal people". One particularly appealing option is to 
use a static site generator instead of a more traditional blogging or CMS platform (like WordPress). Using a static 
site generator has a few perks, a major one being you can host it for free on e.g. GitHub pages. Another major 
advantage is speed; everyone hates shitty slow loading websites.

If you don't want to leech some free hosting, you can always just get a good old server somewhere and host everything 
on that. I'm a strong believer in making automated and reproducible infrastructure, so I thought I'd explain how the 
server serving you this content was set up from scratch, without me ever logging in to it to manually configure things.

<!--more-->

Granted, it's pretty easy to just get a server somewhere, log into to it with the auto-generated password, run 
`apt-get install nginx`, drop some files on it and be good to go. It's also not very interesting.

There are a lot of different tools I've had to use in this process:

* [Packer](https://www.packer.io/), for creating a template on UpCloud which I can use to launch an instance of my server
* [Ansible](https://www.ansible.com/), for provisioning the server (user account, firewall, nginx, Hugo)
* [Capistrano](http://capistranorb.com/), for trigger re-provisioning and for deploying new content to the website

## Building the server

The first step was to create a bare-bones server template that I can use to spin up the server. The idea is that once 
you have the server and are able to access it, you can continue to refine the provisioning process with almost instant 
feedback. This is easier than attempting to get everything right on the first shot.

This bare-bones build basically has this:

* a user account with sudo access. The only way to authenticate is by using an SSH key pair.
* some firewall rules. It's enough to allow `tcp/22` at this stage.

I decided to use a VPS from [UpCloud](https://www.upcloud.com/). I like them; their servers are fast, their support is 
great, and they have a datacenter in Helsinki.

The Packer template file I used looks something like this:

{{< highlight json >}}
{
  "variables": {
    "UPCLOUD_USERNAME": "{{ env `UPCLOUD_USER` }}",
    "UPCLOUD_PASSWORD": "{{ env `UPCLOUD_PASSWORD` }}"
  },
  "builders": [
    {
      "type": "upcloud",
      "username": "{{ user `UPCLOUD_USERNAME` }}",
      "password": "{{ user `UPCLOUD_PASSWORD` }}",
      "zone": "fi-hel1",
      "storage_uuid": "01000000-0000-4000-8000-000030060200"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "scripts": [
        "scripts/update.sh",
        "scripts/ansible.sh"
      ]
    },
    {
      "type": "ansible-local",
      "playbook_file": "ansible/stalin.yml",
      "playbook_dir":  "ansible",
      "inventory_file": "ansible/inventory/production",
      "extra_arguments": ["-i", "inventory/production", "--limit", "stalin"]
    }
  ]
}
{{< /highlight >}}

## Provisioning software

So a server that has nothing installed is pretty useless. To be able to serve my static site I'll need a web server. 
nginx is what I'm used to so I went with that. A static site doesn't really need any fancy web server configuration so 
this step wasn't too difficult.

I also installed Hugo itself on the server because I'm going to be deploying updates to it with Capistrano. Capistrano 
in a nutshell is just a fancy tool for SSHing into a server to run a bunch of commands. If I want to be able to build 
my site on the fly from source, I'll need Hugo installed on the target server. Luckily, installing Hugo is about as 
easy as it can get - just download a binary to `/usr/local/bin` and you're good to go.

The playbook I used looks like this:

{{< highlight yaml >}}
- hosts: all
  connection: local
  become: true
  roles:
    - init
    - swap
    - deployuser
    - firewall
    - nginx
    - hugo
{{< /highlight >}}

Obviously this is not very useful since all the magic happens in the roles, but I can't share this code at the moment.

## Deploying content

Deploying a Hugo site with Capistrano is kinda overkill, as can be seen from the simplicity of the configuration. 
Capistrano can do a lot more than this. It's what I'm familiar with though so that's what I'm using.

Basically my `deploy.rb` looks like this (with the boilerplate stuff that gets generated from `cap install` omitted):

{{< highlight ruby >}}
namespace :website do

	desc "Build neggefi"
	task :build do
		on roles(:all) do
			within File.join(fetch(:release_path), 'neggefi') do
				execute :hugo
			end
		end
	end

end

namespace :deploy do

	after :updated, "website:build"
	
end
{{< /highlight >}}

And that's it, now I have my own static website!
