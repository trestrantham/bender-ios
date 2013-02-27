# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bubble-wrap/reactor'
require 'time'
require 'bundler'

Bundler.require

Motion::Project::App.setup do |app|
	# Use `rake config' to see complete project settings.
	app.name = 'bender-ios'
	#app.device_family = :ipad #[:ipad,:iphone]

	app.pods do
		pod 'SVPullToRefresh'
	end

	app.vendor_project 'vendor/JSONKit', :static
	app.vendor_project 'vendor/FayeObjc', :static, cflags: '-fobjc-arc'
	app.vendor_project 'vendor/MGSplitViewController', :static


	app.codesign_certificate = 'iPhone Developer: William Trantham III (3E8KX84744)'
	app.identifier = '3MXD5J8GME.com.collectiveidea.bender'
	app.provisioning_profile = '/Users/Tres/Downloads/iOS_Team_Provisioning_Profile_.mobileprovision'
end
