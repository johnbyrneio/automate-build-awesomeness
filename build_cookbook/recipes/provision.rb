#
# Cookbook Name:: build_cookbook
# Recipe:: provision
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::provision'

project_secrets = get_project_secrets

terraform_install_dir = workflow_workspace

terraform_plan_dir = "#{node['delivery']['workspace']['cache']}/terraform"

terraform_cmd = "#{workflow_workspace}/terraform/terraform"

 ark "terraform" do
   path terraform_install_dir
   url 'https://releases.hashicorp.com/terraform/0.7.5/terraform_0.7.5_linux_amd64.zip'
   checksum '7def82015b3a9a1bab13b4548e4c8d4ac960322a815cff7d9ebf76ef74a4cb34'
   strip_components 0
   owner 'dbuild'
   group 'dbuild'
   action :put
 end

directory terraform_plan_dir do
  owner 'dbuild'
  group 'dbuild'
  mode '0755'
  action :create
end

template "#{terraform_plan_dir}/main.tf" do
  source 'main.tf.erb'
  owner 'dbuild'
  group 'dbuild'
  mode '0644'
  action :create
end

template "#{terraform_plan_dir}/main.tfvars" do
  source 'main.tfvars.erb'
  owner 'dbuild'
  group 'dbuild'
  mode '0644'
  variables ({
    :chef_environment_name => workflow_chef_environment_for_stage
  })
  action :create
end

file "#{terraform_plan_dir}/aws_ssh_key.pem" do
  content project_secrets['aws_ssh_key']
  owner 'dbuild'
  group 'dbuild'
  mode '0600'
  action :create
end

file "#{terraform_plan_dir}/chef_user_key.pem" do
  content project_secrets['chef_user_key']
  owner 'dbuild'
  group 'dbuild'
  mode '0600'
  action :create
end

execute 'Apply Terraform Plan' do
  command "#{terraform_cmd} apply --var-file main.tfvars"
  cwd terraform_plan_dir
  environment ({
    'AWS_ACCESS_KEY_ID' => project_secrets['aws_access_key_id'],
    'AWS_SECRET_ACCESS_KEY' => project_secrets['aws_secret_access_key']
    })
  live_stream true
  action :run
end