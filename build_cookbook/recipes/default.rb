#
# Cookbook Name:: build_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::default'

# Test setting up SSH for Github Enterprise private repo access

project_secrets = get_project_secrets

directory "#{node['delivery']['workspace_path']}/.ssh" do
  owner 'dbuild'
  group 'dbuild'
  mode '0700'
  action :create
end

file "#{node['delivery']['workspace_path']}/.ssh/github-key.pem" do
  content project_secrets['github_ssh_key']
  owner 'dbuild'
  group 'dbuild'
  mode '0600'
  action :create
end

template "#{node['delivery']['workspace_path']}/.ssh/config" do
  source 'ssh_config.erb'
  owner 'dbuild'
  group 'dbuild'
  mode '0600'
  action :create
end