# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'bender-ipad'
  app.device_family = :ipad #[:ipad,:iphone]

	app.pods do
		pod 'SVPullToRefresh'
	end
end
