#!/usr/bin/env ruby
# coding: utf-8
#--
# ニフティクラウドSDK for Ruby
#
# Ruby Gem Name::  nifty-cloud-sdk
# Author::    NIFTY Corporation
# Copyright:: Copyright 2011 NIFTY Corporation All Rights Reserved.
# License::   Distributes under the same terms as Ruby
# Home::      http://cloud.nifty.com/api/
#++

require 'rubygems'
require File.dirname(__FILE__) + "/../../lib/NIFTY"
require 'pp'

ACCESS_KEY = ENV["NIFTY_CLOUD_ACCESS_KEY"] || "<Your Access Key ID>"
SECRET_KEY = ENV["NIFTY_CLOUD_SECRET_KEY"] || "<Your Secret Access Key>"


ncs4r = NIFTY::Cloud::Base.new(:access_key => ACCESS_KEY, :secret_key => SECRET_KEY)

options = {
  #:group_name => ["groupName"],
  #:filter     => [{:name  => "group-name",
  #                 :value => "groupName"}]
}

pp response = ncs4r.nifty_describe_private_lans(options)
p ncs4r.raw_xml

response.privateLanSet.item.each do |private_lan|
  p private_lan.networkId
  p private_lan.privateLanName
  p private_lan.state
  p private_lan.cidrBlock
  p private_lan.availabilityZone
  p private_lan.accountingType
  p private_lan.description
  if instances_set = private_lan.instancesSet
    instances_set.item.each do |instance|
      p instance.instanceId
    end
  end
  if network_interface_set = private_lan.networkInterfaceSet
    network_interface_set.item.each do |network_interface|
      p network_interface.networkInterfaceId
      p network_interface.ipAddress
    end
  end
  p private_lan.createdTime
  p private_lan.sharingStatus
end
