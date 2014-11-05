platform :ios, '7.0'

inhibit_all_warnings!

pod 'AFNetworking'
pod 'MSDynamicsDrawerViewController'
pod 'SSKeychain'
pod 'TwilioSDK'
pod 'IOSLinkedInAPI'
pod 'Facebook-iOS-SDK'
pod 'google-plus-ios-sdk'
pod 'TestFlightSDK'
pod 'MediaRSSParser'
pod 'GoogleAnalytics-iOS-SDK'
pod 'KVOController'
pod 'Shimmer'
pod "AWSiOSSDKv2"
pod "AWSCognitoSync"

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    # Here we need to add "-Xanalyzer deadcode" to the compiler flags
    # IF "-Xanalyzer -analyzer-disable-checker" is present, for all pod .m files
    # See https://github.com/CocoaPods/CocoaPods/issues/2402
    if target.name.start_with? 'Pods'
      files = target.source_build_phase.files().select { |file|
        file.display_name().end_with? ".m"
      }

      # compiler flags key in settings
      compiler_flags_key = "COMPILER_FLAGS"
      disable_checker_flag = "-Xanalyzer -analyzer-disable-checker"
      deadcode_flag = "-Xanalyzer deadcode"

      if files.length > 0
        files.each do |build_file|
          settings = build_file.settings
          if !settings.nil?
              compiler_flags = settings[compiler_flags_key]
              #Add " -Xanalyzer deadcode" to the compiler flags
              if ((compiler_flags.include? disable_checker_flag) && (!compiler_flags.include? deadcode_flag))
                  compiler_flags << " " << deadcode_flag
                  settings[compiler_flags_key] = compiler_flags
              end
            end
            build_file.settings = settings
        end
      end
    end #end target name if
  end
end