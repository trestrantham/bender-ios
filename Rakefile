# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bubble-wrap/reactor'
require 'time'
require 'sugarcube-attributedstring'

require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'Bender'
  app.device_family = :ipad
  app.deployment_target = '5.1'

  app.icons = ['Icon-72.png', 'Icon-72@2x.png', 'Icon-Small-50.png', 'Icon-Small-50@2x.png', 'Icon-Small.png', 'Icon-Small@2x.png', 'Icon.png', 'Icon@2x.png']
  app.prerendered_icon = true

  app.pods do
    pod 'JSONKit'
    pod 'SocketRocket'
  end

  app.vendor_project 'vendor/MTStatusBarOverlay', :static
  app.vendor_project 'vendor/FayeObjc', :static, cflags: '-fobjc-arc -I../Pods/Headers'

  app.identifier = 'com.collectiveidea.bender'
  app.codesign_certificate = 'iPhone Developer: William Trantham III (3E8KX84744)'
  app.provisioning_profile = '/Users/Tres/Downloads/iOS_Team_Provisioning_Profile_ChatApp.mobileprovision'

  # app.development do
  #   app.testflight do
  #     app.codesign_certificate = 'iPhone Distribution: Collective Idea Inc.'
  #     app.provisioning_profile = '/Users/Tres/Downloads/6F464A4C-7CB4-4C9C-BB5A-779F581D0926.mobileprovision'
  #     app.entitlements['get-task-allow'] = false

  #     app.testflight.sdk = 'vendor/TestFlightSDK'
  #     app.testflight.api_token = 'pHkocYYUXxYVWdCJT9jiqubSfrU8akeVMaJfHB9fKDQ'
  #     app.testflight.team_token = '67033b7e74755b39d011adeb999bc42b_ODc5NzgyMDEyLTA1LTA3IDE2OjM4OjEyLjMyOTAzMw'
  #     app.testflight.app_token = '0e1c6e97-4591-4b15-80da-585563fe0b71'
  #   end
  # end

  app.detect_dependencies = false
end
