# Uncomment the next line to define a global platform for your project
#platform :ios, '12.0'

target 'Kismmet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Kismat App
  
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxSwiftExt'
  
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  
  pod 'SwiftSignalRClient'
  pod 'Alamofire'
  pod 'SwiftDate'
  pod 'RealmSwift'
  #pod "RxRealm"
  pod 'Siren'
  pod 'SwiftyStoreKit'

  pod 'GoogleSignIn'
  pod 'GoogleMaps'

  pod 'TransitionableTab', '~> 0.2.0'
  pod 'PKHUD'
  pod 'SDWebImage'
  pod 'CountryPickerView'
  pod 'MaterialComponents/Snackbar'
  pod 'MaterialComponents/Ripple'
  pod 'CDAlertView'
  pod 'MultiSlider'
  pod 'FSCalendar'
  pod 'UIMultiPicker'
  pod 'IQKeyboardManagerSwift'

  #pod 'iOSDropDown'#, :path => '../' #should be added to text field
  
  pod 'DropDown' # can be added to any view
  pod 'MKToolTip'
  pod 'TransitionableTab', '~> 0.2.0'
  pod 'FLAnimatedImage'

  
  pod 'MessageKit', '~> 3.0.0'
  pod 'Cosmos', '~> 23.0'
  pod 'PopoverKit', '~> 0.2.0'
  pod 'DateTimePicker' #always copy DateTimePicker.swift content before installing new one.
  
  pod 'Stripe', '~> 15.0.0'
  

  target 'Kismat AppTests' do
    inherit! :search_paths
    # Pods for testing

  end

  target 'Kismat AppUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
          config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
        end
      end
    end
  end

end
