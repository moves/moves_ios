 platform :ios, '14.0'

target 'Moves' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for
pod 'SDWebImage', '~> 5.0'
pod 'DPOTPView'
pod 'PhoneNumberKit', '~> 3.7'
pod 'Toast-Swift', '~> 5.1.1'
pod 'FirebaseFunctions'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'FirebaseStorage'
pod 'FirebaseDatabase'
pod 'FirebaseAnalytics'
pod 'GoogleSignIn'
pod 'FacebookCore'
pod 'FacebookLogin'
pod 'FacebookShare'
pod 'FirebaseMessaging'
pod 'SVProgressHUD'
pod 'SwiftVideoGenerator'
pod 'GSPlayer'
pod "NextLevel", "~> 0.16.3"
pod 'YPImagePicker'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'QCropper'
pod 'GrowingTextView', '0.7.2'
pod 'GTProgressBar'
pod 'CoreAnimator'
pod 'SnapKit'
pod 'SkeletonView'
pod 'TextFieldFormatter'
pod 'BadgeControl'
pod 'MarqueeLabel'
pod 'EFInternetIndicator'
pod 'JXSegmentedView'
pod 'Alamofire'
pod 'MJRefresh'
pod 'DZNEmptyDataSet'
pod 'ZFPlayer'
pod 'KTVHTTPCache'
pod 'ZFPlayer/ControlView'
pod 'PryntTrimmerView'
pod 'ZoomingTransition'
pod 'SwiftyStoreKit'
pod 'AgoraRtcEngine_iOS'
pod 'Firebase'
pod 'lottie-ios'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      # OR
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      if target.name == 'BoringSSL-GRPC'
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            flags = file.settings['COMPILER_FLAGS'].split
            flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
            file.settings['COMPILER_FLAGS'] = flags.join(' ')
          end
        end
      end
    end
  end
end
