//
//  ANEMPreviewController.swift
//  Anemone
//
//  Created by CoolStar on 1/24/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import UIKit

var springboardPath : URL? = nil

enum DeviceType {
    case iPhone,
    iPad
}

enum PhoneType {
    case iPhone5S,
    iPhone6,
    iPhone6Plus,
    iPhoneX
}

class ANEMPreviewController : UIViewController {
    var _deviceType : DeviceType = DeviceType.iPhone
    var _phoneType : PhoneType = PhoneType.iPhoneX
    var _useBlurredBackground : Bool = true
    
    var _refreshView : UIActivityIndicatorView?
    
    func getIconState() -> NSDictionary? {
        return NSDictionary(contentsOf: springboardPath!.appendingPathComponent("IconState.plist"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
        springboardPath = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Library/SpringBoard/")
        #else
        springboardPath = URL(fileURLWithPath:"/var/mobile/Library/SpringBoard/")
        #endif
        
        _deviceType = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) ? DeviceType.iPad : DeviceType.iPhone
        if (_deviceType == DeviceType.iPhone){
            _phoneType = PhoneType.iPhone5S
            let screenHeight = UIScreen.main.nativeBounds.size.height
            let screenWidth = UIScreen.main.nativeBounds.size.width
            
            if (screenHeight == 2436){
                _phoneType = PhoneType.iPhoneX
            } else if (screenWidth > 400){
                _phoneType = PhoneType.iPhone6Plus
            } else if (screenWidth > 350){
                _phoneType = PhoneType.iPhone6
            }
        }
        
        self.title = NSLocalizedString("Preview", comment: "")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(ANEMPreviewController.dismissController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Apply", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(ANEMPreviewController.applyThemes))
        
        _refreshView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.whiteLarge)
        _refreshView?.layer.zPosition = 5000
        _refreshView?.tintColor = UIColor.black
        _refreshView?.center = CGPoint(x: 335, y: 400)
        self.view.addSubview(_refreshView!)
        _refreshView?.isHidden = true
        
        self.refreshTheme()
    }
    
    var _backgroundView : UIImageView?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let heightMargin : CGFloat = UIApplication.shared.statusBarFrame.size.height
        var totalHeightMargin = heightMargin
        if (self.navigationController?.navigationBar.bounds.size.height != nil){
            totalHeightMargin += (self.navigationController?.navigationBar.bounds.size.height)!
        }
        
        var backgroundViewFrame : CGRect = CGRect(x: 50, y: 80, width: 260, height: 530)
        
        if (_deviceType == DeviceType.iPad){
            backgroundViewFrame = CGRect(x: 100, y: 50, width: 470, height: 700)
        } else {
            if (_phoneType == PhoneType.iPhone5S){
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 226, height: 475)
            } else if (_phoneType == PhoneType.iPhone6){
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 281, height: 570)
            } else if (_phoneType == PhoneType.iPhone6Plus){
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 281, height: 570)
            } else if (_phoneType == PhoneType.iPhoneX){
                backgroundViewFrame = CGRect(x: 50, y: 80, width: 260, height: 530)
            }
        }
        
        let backgroundViewScaleY : CGFloat = (self.view.bounds.size.height - (totalHeightMargin + 30))/backgroundViewFrame.size.height
        let backgroundViewScaleX : CGFloat = (self.view.bounds.size.width - 30.0)/backgroundViewFrame.size.width
        let backgroundViewScale : CGFloat = min(backgroundViewScaleX,backgroundViewScaleY)
        
        _backgroundView?.transform = CGAffineTransform(scaleX: backgroundViewScale, y: backgroundViewScale)
        _backgroundView?.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY + heightMargin)
    }
    
    func refreshTheme(){
        enableThemes()
        var themes : Array<String>? = UserDefaults.standard.value(forKey: "settingsPacked") as? Array<String>
        
        _backgroundView?.removeFromSuperview()
        
        var backgroundViewFrame : CGRect = CGRect(x: 50, y: 80, width: 260, height: 530)
        var homeScreenFrame : CGRect = CGRect(x: 11, y: 10, width: 236, height: 510)
        var homeScreenCornerRadius : CGFloat = 35
        var statusBarHeight : CGFloat = 44
        var transform : CGFloat = 0.63
        var dockHeight : CGFloat = 94
        var screenWidth : CGFloat = 375
        var screenHeight : CGFloat = 812
        var useFloatyDock : Bool = true
        var floatyDockMargins : CGFloat = 20
        var floatyDockYMargin : CGFloat = 20
        
        if (_deviceType == DeviceType.iPad){
            backgroundViewFrame = CGRect(x: 100, y: 50, width: 470, height: 700)
            homeScreenFrame = CGRect(x: 27, y: 72, width: 415, height: 552)
            homeScreenCornerRadius = 0
            statusBarHeight = 20
            transform = 0.54
            dockHeight = 114
            screenWidth = 768
            screenHeight = 1024
            floatyDockMargins = 80
            floatyDockYMargin = 34
        } else {
            if (_phoneType == PhoneType.iPhone5S){
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 226, height: 475)
                homeScreenFrame = CGRect(x: 18, y: 69, width: 192, height: 340)
                homeScreenCornerRadius = 0
                statusBarHeight = 20
                transform = 0.60
                dockHeight = 92
                screenWidth = 320
                screenHeight = 568
                useFloatyDock = false
            } else if (_phoneType == PhoneType.iPhone6){
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 281, height: 570)
                homeScreenFrame = CGRect(x: 19, y: 69, width: 240, height: 427)
                homeScreenCornerRadius = 0
                statusBarHeight = 20
                transform = 0.64
                dockHeight = 92
                screenWidth = 375
                screenHeight = 667
                useFloatyDock = false
            } else if (_phoneType == PhoneType.iPhone6Plus){
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 281, height: 570)
                homeScreenFrame = CGRect(x: 19, y: 68, width: 245, height: 437)
                homeScreenCornerRadius = 0
                statusBarHeight = 20
                transform = 0.59
                dockHeight = 92
                screenWidth = 414
                screenHeight = 736
                useFloatyDock = false
            } else if (_phoneType == PhoneType.iPhoneX){
                backgroundViewFrame = CGRect(x: 50, y: 80, width: 260, height: 530)
                homeScreenFrame = CGRect(x: 11, y: 10, width: 236, height: 510)
                homeScreenCornerRadius = 35
                statusBarHeight = 44
                transform = 0.63
                dockHeight = 94
                screenWidth = 375
                screenHeight = 812
            }
        }
        
        let transformedDockHeight : CGFloat = dockHeight * transform
        _backgroundView = UIImageView(frame: backgroundViewFrame)
        if (_deviceType == DeviceType.iPad){
            _backgroundView?.image = UIImage(named: "iPad mini")
        } else {
            if (_phoneType == PhoneType.iPhone5S){
                _backgroundView?.image = UIImage(named: "iPhone 5s")
            } else if (_phoneType == PhoneType.iPhone6){
                _backgroundView?.image = UIImage(named: "iPhone 6")
            } else if (_phoneType == PhoneType.iPhone6Plus){
                _backgroundView?.image = UIImage(named: "iPhone 6+")
            } else if (_phoneType == PhoneType.iPhoneX){
                _backgroundView?.image = UIImage(named: "iPhone X")
            }
        }
        
        _backgroundView?.isUserInteractionEnabled = false
        self.view.addSubview(_backgroundView!)
        
        var heightMargin : CGFloat = 0.0
        
        if (_deviceType == DeviceType.iPhone && _phoneType == PhoneType.iPhoneX){
            let overlayView : UIImageView? = UIImageView.init(frame: (_backgroundView?.bounds)!)
            overlayView?.image = UIImage(named: "iPhone X-overlay")
            overlayView?.isUserInteractionEnabled = false
            overlayView?.layer.zPosition = 5000
            _backgroundView?.addSubview(overlayView!)
            
            heightMargin = 10.0
        }
        
        self.viewDidLayoutSubviews()
        
        let wallpaper : UIImage? = getWallpaper()
        
        if (_useBlurredBackground){
            let blurredBackgroundView : UIImageView = UIImageView(frame: self.view.bounds)
            blurredBackgroundView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
            blurredBackgroundView.image = wallpaper
            blurredBackgroundView.contentMode = UIView.ContentMode.scaleAspectFill
            
            let darkeningView : UIView = UIView(frame: blurredBackgroundView.bounds)
            darkeningView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
            darkeningView.backgroundColor = UIColor(white:0.0,alpha:0.5)
            blurredBackgroundView.addSubview(darkeningView)
            self.view.addSubview(blurredBackgroundView)
            self.view.sendSubviewToBack(blurredBackgroundView)
        }
        
        let homeScreenView : UIImageView = UIImageView(frame: homeScreenFrame)
        homeScreenView.image = wallpaper
        homeScreenView.contentMode = UIView.ContentMode.scaleAspectFill
        homeScreenView.clipsToBounds = true
        if (homeScreenCornerRadius > 0){
            homeScreenView.layer.cornerRadius = homeScreenCornerRadius
        }
        _backgroundView?.addSubview(homeScreenView)
        
        _backgroundView?.alpha = 0.5
        UIView.animate(withDuration: 0.25, animations: {
            self._backgroundView?.alpha = 1.0
        }) { (Bool) in
            self._refreshView?.stopAnimating()
            self._refreshView?.isHidden = true
        }
        
        let statusBar : UIStatusBar = UIStatusBar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: statusBarHeight))
        statusBar.transform = CGAffineTransform(scaleX: transform, y: transform)
        statusBar.frame = CGRect(x: 0, y: 0, width: homeScreenFrame.size.width, height: statusBarHeight * transform)
        statusBar.request(UIStatusBarStyle.lightContent)
        homeScreenView.addSubview(statusBar)
        
        let homeContentsView : UIView = UIView(frame: CGRect.zero)
        homeContentsView.transform = CGAffineTransform(scaleX: transform, y: transform)
        homeContentsView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        homeScreenView.addSubview(homeContentsView)
        
        let dockContentsView : UIView = UIView(frame: CGRect.zero)
        dockContentsView.transform = CGAffineTransform(scaleX: transform, y: transform)
        dockContentsView.frame = CGRect(x: 0, y: homeScreenFrame.size.height - transformedDockHeight, width: homeScreenFrame.size.width, height: transformedDockHeight)
        homeScreenView.addSubview(dockContentsView)
        
        let iconState : NSDictionary? = getIconState()
        
        let buttonBar : NSArray? = iconState?.object(forKey: "buttonBar") as? NSArray
        
        let dockSettings : _UIBackdropViewSettings = _UIBackdropViewSettings(forStyle: 2060, graphicsQuality: 100)
        dockSettings.blurRadius = 25
        
        var effectiveDockHeight : CGFloat = dockHeight
        
        if (useFloatyDock){
            var x : CGFloat = 21
            
            let floatyDockBackgroundView : _UIBackdropView = _UIBackdropView.init(frame: CGRect.zero, autosizesToFitSuperview: false, settings: dockSettings)
            floatyDockBackgroundView.layer.cornerRadius = 31
            floatyDockBackgroundView.clipsToBounds = true
            
            let floatyDockContentsView : UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1024, height: dockHeight))
            floatyDockBackgroundView.addSubview(floatyDockContentsView)
            
            buttonBar?.forEach({ (rawIdentifier) in
                let iconView : UIView? = iconViewFromIdentifier(bundleIdentifier: rawIdentifier, hasLabel: false)
                if (iconView == nil){
                    return
                }
                var frame : CGRect = (iconView?.frame)!
                frame.origin.x = x
                if (_deviceType != DeviceType.iPad){
                    frame.origin.y = 17
                } else {
                    frame.origin.y = 20
                }
                iconView?.frame = frame
                floatyDockContentsView.addSubview(iconView!)
                if (_deviceType != DeviceType.iPad){
                    x += frame.size.width + 27
                } else {
                    x += frame.size.width + 21
                }
            })
            
            var floatyContentFrame = floatyDockContentsView.frame
            floatyContentFrame.size.width = x
            floatyDockContentsView.frame = floatyContentFrame
            floatyDockBackgroundView.frame = floatyContentFrame
            
            let floatyScale : CGFloat = (screenWidth - floatyDockMargins)/floatyContentFrame.size.width
            if (floatyScale < 1.0){
                floatyDockBackgroundView.transform = CGAffineTransform(scaleX: floatyScale, y: floatyScale)
            }
            
            var floatyDockFrame : CGRect = floatyDockBackgroundView.frame
            floatyDockFrame.origin.x = (screenWidth - floatyDockFrame.size.width)/2
            floatyDockFrame.origin.y = dockHeight - (floatyDockFrame.size.height + 17)
            floatyDockBackgroundView.frame = floatyDockFrame
            
            effectiveDockHeight = floatyDockFrame.size.height + floatyDockYMargin
            dockContentsView.addSubview(floatyDockBackgroundView)
        } else {
            let dockRootView : UIView = UIView.init(frame:CGRect.zero)
            dockRootView.frame = CGRect(x: 0, y: 0, width: homeScreenFrame.size.width, height: transformedDockHeight)
            dockContentsView.addSubview(dockRootView)
            
            let dockView : _UIBackdropView = _UIBackdropView.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), autosizesToFitSuperview: false, settings: dockSettings)
            dockRootView.addSubview(dockView)
            
            let dockOverlayView : UIView = UIView.init(frame:CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            dockOverlayView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
            dockRootView.addSubview(dockOverlayView)
            
            var dockXBase : CGFloat = 168.0
            var dockPosDiff : CGFloat = 38.0
            var dockXSeparation : CGFloat = 76.0
            let dockYPos : CGFloat = 14
            
            if (_phoneType == PhoneType.iPhone6){
                dockXBase = 199.0
                dockPosDiff = 43.0
                dockXSeparation = 87.0
            } else if (_phoneType == PhoneType.iPhone6Plus){
                dockXBase = 223.0
                dockPosDiff = 47.0
                dockXSeparation = 94.0
            }
            
            var buttonBarCount : CGFloat = CGFloat(buttonBar!.count)
            if (buttonBarCount > 4.0){
                buttonBarCount = 4
            }
            
            var x : CGFloat = dockXBase - (dockPosDiff * buttonBarCount)
            
            buttonBar?.forEach({ (rawIdentifier) in
                let iconView : UIView? = iconViewFromIdentifier(bundleIdentifier: rawIdentifier, hasLabel: false)
                if (iconView == nil){
                    return
                }
                var frame : CGRect = (iconView?.frame)!
                frame.origin.x = x
                frame.origin.y = dockYPos
                iconView?.frame = frame
                dockContentsView.addSubview(iconView!)
                x += dockXSeparation
            })
        }
        
        var iconXSeparation : CGFloat = 87
        var iconYSeparation : CGFloat = 102
        if (_deviceType == DeviceType.iPad){
            iconXSeparation = 176
            iconYSeparation = 161
        } else {
            if (_phoneType == PhoneType.iPhone5S){
                iconXSeparation = 76
                iconYSeparation = 88
            } else if (_phoneType == PhoneType.iPhone6){
                iconXSeparation = 87
                iconYSeparation = 88
            } else if (_phoneType == PhoneType.iPhone6Plus){
                iconXSeparation = 94
                iconYSeparation = 100
            } else if (_phoneType == PhoneType.iPhoneX){
                iconXSeparation = 87
                iconYSeparation = 102
            }
        }
        
        var page = 0
        var iconList : NSArray? = (iconState?.object(forKey: "iconLists") as? NSArray)?.object(at: page) as? NSArray
        while (iconList?.count == 0){
            page += 1
            iconList = (iconState?.object(forKey: "iconLists") as? NSArray)?.object(at: page) as? NSArray
        }
        var i = 1
        var x : CGFloat = 27
        var y : CGFloat = 71
        if (_deviceType == DeviceType.iPad){
            x = 82
            y = 68
        } else {
            if (_phoneType == PhoneType.iPhone5S){
                x = 16
                y = 25
            } else if (_phoneType == PhoneType.iPhone6){
                x = 27
                y = 24
            } else if (_phoneType == PhoneType.iPhone6Plus){
                x = 35
                y = 18
            } else if (_phoneType == PhoneType.iPhoneX){
                x = 27
                y = 71
            }
        }
        let initialX : CGFloat = x
        iconList?.forEach({ (rawIdentifier) in
            let iconView : UIView? = iconViewFromIdentifier(bundleIdentifier: rawIdentifier, hasLabel: true)
            if (iconView == nil){
                return
            }
            var frame : CGRect = (iconView?.frame)!
            frame.origin.x = x
            frame.origin.y = y
            iconView?.frame = frame
            homeContentsView.addSubview(iconView!)
            x += iconXSeparation
            if (i%4 == 0){
                x = initialX
                y += iconYSeparation
            }
            i += 1
            if (_deviceType != DeviceType.iPad){
                if (_phoneType != PhoneType.iPhone5S){
                    if (i > 24){
                        return
                    }
                }
            }
            if (i > 20){
                return
            }
        })
        
        let pageDots : UIView = UIView(frame: CGRect(x: 0, y: screenHeight - (effectiveDockHeight + 37), width: screenWidth, height: 37))
        let pageDot : UIImage = UIImage.kitImageNamed("UIPageIndicator")
        let pageDotCurrent : UIImage = UIImage.kitImageNamed("UIPageIndicatorCurrent")
        let pageDotSize = pageDotCurrent.size
        
        var pageCount : Int = ((iconState?.object(forKey: "iconLists") as? NSArray)?.count)!
        pageCount += 1
        
        let pageDotSeparators : CGFloat = 8.0
        let width : CGFloat = (pageDotSize.width * CGFloat(pageCount)) + (pageDotSeparators * (CGFloat(pageCount) - 1))
        var pageX : CGFloat = (pageDots.frame.size.width / 2.0) - (width / 2.0)
        let pageY : CGFloat = (pageDots.frame.size.height / 2.0) - (pageDotSize.height / 2.0)
        
        for i in stride(from: 0, to: pageCount, by: 1){
            let idx = i - 1
            
            let dotView : UIImageView = UIImageView(frame: CGRect(x: pageX, y: pageY, width: pageDotSize.width, height: pageDotSize.height))
            if (idx == page){
                dotView.image = pageDotCurrent
            } else {
                dotView.image = pageDot
            }
            pageDots.addSubview(dotView)
            pageX += pageDotSize.width + pageDotSeparators
        }
        homeContentsView.addSubview(pageDots)
        
        disableThemes()
    }
    
    func getHomeScreenIconForApp(app : LSApplicationProxy, isiPad : Bool, getThemed: Bool) -> UIImage? {
        let iconsDictionary : NSDictionary? = app.iconsDictionary() as NSDictionary?
        let bundle : Bundle? = Bundle(url: app.bundleURL())
        
        var variant : Int32 = 15
        if (_deviceType == DeviceType.iPad){
            variant = 24
        } else {
            if (UIScreen.main.scale == 3){
                variant = 32
            }
        }
        
        var options : Int32 = 0
        /*if (app.iconIsPrerendered()){
            options |= 0x10
        }*/
        
        return getIconForBundle(bundle, iconsDictionary as? [AnyHashable : Any], variant, options, 2.0, getThemed)
    }
    
    func miniIconViewFromIdentifier(bundleIdentifier : Any?) -> UIView? {
        if ((bundleIdentifier as? NSString) == nil){
            return nil
        }
        
        let scale : CGFloat = UIScreen.main.scale
        
        let app : LSApplicationProxy? = LSApplicationProxy(forIdentifier: (bundleIdentifier as! String))
        let bundlePath : NSString? = app!.bundleURL()?.path as NSString?
        if ((app == nil || bundlePath == nil) && ((bundleIdentifier as? String) == "com.apple.videos")){
            return miniIconViewFromIdentifier(bundleIdentifier: "com.apple.tv")
        }
        if (app == nil || bundlePath == nil){
            return nil
        }
        let infoPlist : NSDictionary = NSDictionary(contentsOfFile:(bundlePath?.appendingPathComponent("Info.plist"))!)!
        
        var icon : UIImage? = getHomeScreenIconForApp(app: app!, isiPad: _deviceType == DeviceType.iPad, getThemed: true)
        if ((icon == nil)){
            icon = getHomeScreenIconForApp(app: app!, isiPad: _deviceType == DeviceType.iPad, getThemed: false)
        }
        icon = icon?._applicationIconImage(forFormat: 2, precomposed: (infoPlist.object(forKey: "UIPrerenderedIcon") as? NSNumber)?.boolValue ?? false, scale: scale)
        
        var iconViewFrame : CGRect = CGRect(x: 0, y: 0, width: 13, height: 13)
        if (_deviceType == DeviceType.iPad){
            iconViewFrame = CGRect(x: 0, y: 0, width: 11, height: 11)
        }
        
        let iconView : UIImageView = UIImageView.init(frame: iconViewFrame)
        iconView.image = icon
        iconView.layer.minificationFilter = CALayerContentsFilter.trilinear
        
        return iconView
    }
    
    func folderIconViewFromIdentifier(folderDictionary : NSDictionary?, hasLabel : Bool) -> UIView? {
        var iconViewFrame : CGRect = CGRect(x: 0, y: 0, width: 76, height: 93)
        var iconImageViewFrame : CGRect = CGRect(x: -1, y: -1, width: 78, height: 78)
        var labelFrame : CGRect = CGRect(x: -10, y: 83, width: 96, height: 16)
        let cornerRadius : CGFloat = 12
        if (_deviceType != DeviceType.iPad){
            iconViewFrame = CGRect(x: 0, y: 0, width: 60, height: 74)
            iconImageViewFrame = CGRect(x: -1, y: -1, width: 62, height: 62)
            labelFrame = CGRect(x: -18, y: 63, width: 96, height: 16)
        }
        
        let iconView : UIView = UIView.init(frame: iconViewFrame)
        let iconImageView : UIImageView = UIImageView.init(frame: iconImageViewFrame)
        iconImageView.contentMode = UIView.ContentMode.center
        
        var mask : UIImage? = UIImage(contentsOfFile: "/System/Library/PrivateFrameworks/MobileIcons.framework/AppIconMask~iphone.png")
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
            mask = UIImage(contentsOfFile: "/System/Library/PrivateFrameworks/MobileIcons.framework/AppIconMask~ipad.png")
        }
        
        UIGraphicsBeginImageContextWithOptions(iconImageView.bounds.size, false, 0)
        UIColor.white.setFill()
        mask?.draw(in: CGRect(x: (iconImageView.bounds.size.width-mask!.size.width)/2.0, y: (iconImageView.bounds.size.height-mask!.size.height)/2.0, width: mask!.size.width, height: mask!.size.height))
        let renderedMask : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let maskView = UIImageView.init(frame: iconImageView.bounds)
        maskView.image = renderedMask
        
        let folderSettings : _UIBackdropViewSettings = _UIBackdropViewSettings(forStyle: 2060, graphicsQuality: 100)
        let folderBackgroundView : _UIBackdropView = _UIBackdropView.init(frame: CGRect.zero, autosizesToFitSuperview: true, settings: folderSettings)
        folderBackgroundView.layer.cornerRadius = cornerRadius
        folderBackgroundView.clipsToBounds = true
        iconImageView.addSubview(folderBackgroundView)
        
        let folderOverlayView : UIView = UIView.init(frame: iconImageView.bounds)
        folderOverlayView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        folderOverlayView.layer.cornerRadius = cornerRadius
        folderOverlayView.clipsToBounds = true
        iconImageView.addSubview(folderOverlayView)
        
        var i : Int32 = 1
        var x : CGFloat = 9
        var minx : CGFloat = 8
        var y : CGFloat = 9
        var maxX : Int32 = 3
        var maxItems : Int32 = 9
        
        var folderSeparator : CGFloat = 16
        if (_deviceType == DeviceType.iPad){
            x = 11
            minx = 11
            y = 11
            folderSeparator = 14
            maxX = 4
            maxItems = 16
        }
        
        let iconList : NSArray? = (folderDictionary?.object(forKey: "iconLists") as? NSArray)?.object(at: 0) as? NSArray
        iconList?.forEach({ (rawIdentifier) in
            let identifier : String? = rawIdentifier as? String
            let miniIcon : UIView? = miniIconViewFromIdentifier(bundleIdentifier: identifier)
            if (miniIcon == nil){
                return
            }
            var frame : CGRect = (miniIcon?.frame)!
            frame.origin.x = x
            frame.origin.y = y
            miniIcon?.frame = frame
            iconImageView.addSubview(miniIcon!)
            x += folderSeparator
            if (i%maxX == 0){
                x = minx
                y += folderSeparator
            }
            if (i >= maxItems){
                return
            }
            i+=1
        })
        
        iconView.addSubview(iconImageView)
        
        if (hasLabel){
            let iconLabel : UILabel = UILabel(frame: labelFrame)
            iconLabel.backgroundColor = UIColor.clear
            iconLabel.textAlignment = NSTextAlignment.center
            if (_deviceType == DeviceType.iPad){
                iconLabel.font = UIFont.systemFont(ofSize: 14)
            } else {
                iconLabel.font = UIFont.systemFont(ofSize: 12)
            }
            iconLabel.textColor = UIColor.white
            iconView.addSubview(iconLabel)
            
            let iconLabelText : String? = folderDictionary?.object(forKey: "displayName") as? String
            iconLabel.text = iconLabelText
        }
        
        return iconView
    }
    
    func iconViewFromIdentifier(bundleIdentifier : Any?, hasLabel : Bool) -> UIView? {
        if ((bundleIdentifier as? NSString) == nil){
            return folderIconViewFromIdentifier(folderDictionary: (bundleIdentifier as? NSDictionary), hasLabel: hasLabel)
        }
        
        let scale : CGFloat = UIScreen.main.scale
        
        let app : LSApplicationProxy? = LSApplicationProxy(forIdentifier: (bundleIdentifier as! String))
        let bundlePath : NSString? = app!.bundleURL()?.path as NSString?
        if ((app == nil || bundlePath == nil) && ((bundleIdentifier as? String) == "com.apple.videos")){
            return iconViewFromIdentifier(bundleIdentifier: "com.apple.tv", hasLabel:hasLabel)
        }
        if (app == nil || bundlePath == nil){
            return nil
        }
        let infoPlist : NSDictionary = NSDictionary(contentsOfFile:(bundlePath?.appendingPathComponent("Info.plist"))!)!
        
        var icon : UIImage? = getHomeScreenIconForApp(app: app!, isiPad: _deviceType == DeviceType.iPad, getThemed: true)
        if ((icon == nil)){
            icon = getHomeScreenIconForApp(app: app!, isiPad: _deviceType == DeviceType.iPad, getThemed: false)
        }
        icon = icon?._applicationIconImage(forFormat: 2, precomposed: (infoPlist.object(forKey: "UIPrerenderedIcon") as? NSNumber)?.boolValue ?? false, scale: scale)
        
        if (icon != nil){
            if ((infoPlist.object(forKey: "SBIconClass") as? String) == "SBCalendarApplicationIcon"){
                var calendarIconObj = SBCalendarApplicationIcon()
                if (calendarIconObj.responds(to: #selector(SBCalendarApplicationIcon.drawTextIntoCurrentContext(withImageSize:iconBase:)))){
                    UIGraphicsBeginImageContextWithOptions(icon!.size, false, 0.0)
                    calendarIconObj.drawTextIntoCurrentContext(withImageSize: icon!.size, iconBase: icon!)
                    icon = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                }
            }
        }
        
        var iconViewFrame : CGRect = CGRect(x: 0, y: 0, width: 76, height: 93)
        var iconImageViewFrame : CGRect = CGRect(x: -1, y: -1, width: 78, height: 78)
        var labelFrame : CGRect = CGRect(x: -10, y: 83, width: 96, height: 16)
        if (_deviceType != DeviceType.iPad){
            iconViewFrame = CGRect(x: 0, y: 0, width: 60, height: 74)
            iconImageViewFrame = CGRect(x: -1, y: -1, width: 62, height: 62)
            labelFrame = CGRect(x: -18, y: 63, width: 96, height: 16)
        }
        
        let iconView : UIView = UIView.init(frame: iconViewFrame)
        let iconImageView : UIImageView = UIImageView.init(frame: iconImageViewFrame)
        iconImageView.image = icon
        iconImageView.layer.minificationFilter = CALayerContentsFilter.trilinear
        iconView.addSubview(iconImageView)
        
        if (hasLabel){
            let iconLabel : UILabel = UILabel(frame: labelFrame)
            iconLabel.backgroundColor = UIColor.clear
            iconLabel.textAlignment = NSTextAlignment.center
            if (_deviceType == DeviceType.iPad){
                iconLabel.font = UIFont.systemFont(ofSize: 14)
            } else {
                iconLabel.font = UIFont.systemFont(ofSize: 12)
            }
            iconLabel.textColor = UIColor.white
            iconView.addSubview(iconLabel)
            
            var iconLabelText : String? = app!.localizedName()
            if (iconLabelText == "" || iconLabelText == nil){
                iconLabelText = infoPlist.object(forKey: "CFBundleExecutable") as? String
            }
            iconLabel.text = iconLabelText
        }
        
        return iconView
    }
    
    @objc func dismissController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkThemedIconForBundle(bundle: String) -> String? {
        var bundleIdentifier = bundle
        let themesDir : String = PackageListManager.sharedInstance().prefixDir()
        
        var themes : Array<String>? = UserDefaults.standard.value(forKey: "settingsPacked") as? Array<String>
        
        if (bundleIdentifier == "com.anemoneteam.anemone"){
            bundleIdentifier = "com.anemonetheming.anemone"
        }

        if (bundleIdentifier == "org.coolstar.electra1141"){
            bundleIdentifier = "org.coolstar.electra1131"
        }
        
        for identifier in themes! {
            let ibLargeThemePath : String = String(format: "%@/%@/IconBundles/%@-large.png", themesDir, identifier, bundleIdentifier)
            var icon : UIImage? = UIImage(contentsOfFile: ibLargeThemePath)
            if (icon != nil) {
                return ibLargeThemePath
            }
            
            let ibThemePath : String = String(format: "%@/%@/IconBundles/%@.png", themesDir, identifier, bundleIdentifier)
            icon  = UIImage(contentsOfFile: ibThemePath)
            if (icon != nil) {
                return ibThemePath
            }
        }
        return nil
    }
    
    func applyAltIconName(altIconName : String?){
        let workspace : LSApplicationWorkspace = LSApplicationWorkspace.default()
        let allApps : Array<LSApplicationProxy> = workspace.allInstalledApplications()
        
        let sem = DispatchSemaphore(value: allApps.count)
        
        allApps.forEach { (app) in
            let bundleIdentifier = app._boundApplicationIdentifier()
            
            clearCacheForItem(bundleIdentifier)
            
            var shouldApplyIcon = true
            
            if (altIconName == "__ANEM__AltIcon"){
                shouldApplyIcon = false
                
                let icon = checkThemedIconForBundle(bundle: app._boundApplicationIdentifier())
                
                if (icon != nil){
                    shouldApplyIcon = true
                }
            }
            if (shouldApplyIcon){
                app.setAlternateIconName(altIconName, withResult: { (success) in
                        sem.signal()
                })
            } else {
                sem.signal()
            }
        }
        let _ : DispatchTimeoutResult = sem.wait(timeout: DispatchTime.distantFuture)
    }
    
    @objc func applyThemes(){
        let alertController : UIAlertController = UIAlertController(title: "Applying Changes", message: "Please Wait", preferredStyle: UIAlertController.Style.alert)
        self.present(alertController, animated: true) {
            let recache : NSTask = NSTask()
            recache.launchPath = "/usr/bin/recache"
            recache.arguments = ["--no-respring"]
            recache.launch()
            recache.waitUntilExit()
            
            let notificationName : CFString = "com.anemoneteam.anemone/reload" as CFString
            
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(notificationName), nil, nil, true);
            
            self.applyAltIconName(altIconName: nil)
            
            self.applyAltIconName(altIconName: "__ANEM__AltIcon")
            
            alertController.dismiss(animated: true) {
                UIApplication.shared.suspend()
            }
        }
    }
}
