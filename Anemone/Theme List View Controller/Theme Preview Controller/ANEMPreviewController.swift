//
//  ANEMPreviewController.swift
//  Anemone
//
//  Created by CoolStar on 1/24/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import UIKit

#if targetEnvironment(simulator)
var springboardPath = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Library/SpringBoard/")
#else
var springboardPath = URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/")
#endif

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

class ANEMPreviewController: UIViewController {
    var _deviceType = DeviceType.iPhone
    var _phoneType = PhoneType.iPhoneX
    var _useBlurredBackground = true
    
    var _refreshView: UIActivityIndicatorView?
    
    func getIconState() -> NSDictionary? {
        NSDictionary(contentsOf: springboardPath.appendingPathComponent("IconState.plist"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _deviceType = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) ? .iPad : .iPhone
        if _deviceType == .iPhone {
            _phoneType = .iPhone5S
            let screenHeight = UIScreen.main.nativeBounds.size.height
            let screenWidth = UIScreen.main.nativeBounds.size.width
			
			//XXX: 1792 is XR, 2688 is XS Max
            if screenHeight == 1792 || screenHeight == 2436 || screenHeight == 2688 {
                _phoneType = .iPhoneX
            } else if screenWidth > 400 {
                _phoneType = .iPhone6Plus
            } else if screenWidth > 350 {
                _phoneType = .iPhone6
            }
        }
        
        self.title = NSLocalizedString("Preview", comment: "")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(ANEMPreviewController.dismissController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Apply", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(ANEMPreviewController.applyThemes))
        
        _refreshView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        _refreshView?.layer.zPosition = 5000
        _refreshView?.tintColor = .black
        _refreshView?.center = CGPoint(x: 335, y: 400)
        self.view.addSubview(_refreshView!)
        _refreshView?.isHidden = true
        
        self.refreshTheme()
    }
    
    var _backgroundView: UIImageView?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let heightMargin = UIApplication.shared.statusBarFrame.size.height
        var totalHeightMargin = heightMargin
        if self.navigationController?.navigationBar.bounds.size.height != nil {
            totalHeightMargin += (self.navigationController?.navigationBar.bounds.size.height)!
        }
        
        var backgroundViewFrame = CGRect(x: 50, y: 80, width: 260, height: 530)
        
        if _deviceType == .iPad {
            backgroundViewFrame = CGRect(x: 100, y: 50, width: 470, height: 700)
        } else {
            if _phoneType == .iPhone5S {
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 226, height: 475)
            } else if _phoneType == .iPhone6 {
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 281, height: 570)
            } else if _phoneType == .iPhone6Plus {
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 281, height: 570)
            } else if _phoneType == .iPhoneX {
                backgroundViewFrame = CGRect(x: 50, y: 80, width: 260, height: 530)
            }
        }
        
        let backgroundViewScaleY = (self.view.bounds.size.height - (totalHeightMargin + 30))/backgroundViewFrame.size.height
        let backgroundViewScaleX = (self.view.bounds.size.width - 30.0)/backgroundViewFrame.size.width
        let backgroundViewScale = min(backgroundViewScaleX, backgroundViewScaleY)
        
        _backgroundView?.transform = CGAffineTransform(scaleX: backgroundViewScale, y: backgroundViewScale)
        _backgroundView?.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY + heightMargin)
    }
    
    func refreshTheme() {
        enableThemes()
        _backgroundView?.removeFromSuperview()
        
        var backgroundViewFrame = CGRect(x: 50, y: 80, width: 260, height: 530)
        var homeScreenFrame = CGRect(x: 11, y: 10, width: 236, height: 510)
        var homeScreenCornerRadius: CGFloat = 35
        var statusBarHeight: CGFloat = 44
        var transform: CGFloat = 0.63
        var dockHeight: CGFloat = 94
        var screenWidth: CGFloat = 375
        var screenHeight: CGFloat = 812
		var dockMargins: CGFloat = 0
		
        var useFloatyDock = true
        var floatyDockMargins: CGFloat = 20
        var floatyDockYMargin: CGFloat = 20
        
        if _deviceType == .iPad {
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
			useFloatyDock = false
            if _phoneType == .iPhone5S {
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 226, height: 475)
                homeScreenFrame = CGRect(x: 18, y: 69, width: 192, height: 340)
                homeScreenCornerRadius = 0
                statusBarHeight = 20
                transform = 0.60
                dockHeight = 96
                screenWidth = 320
                screenHeight = 568
            } else if _phoneType == .iPhone6 {
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 281, height: 570)
                homeScreenFrame = CGRect(x: 19, y: 69, width: 240, height: 427)
                homeScreenCornerRadius = 0
                statusBarHeight = 20
                transform = 0.64
                dockHeight = 96
                screenWidth = 375
                screenHeight = 667
            } else if _phoneType == .iPhone6Plus {
                backgroundViewFrame = CGRect(x: 47, y: 80, width: 281, height: 570)
                homeScreenFrame = CGRect(x: 19, y: 68, width: 245, height: 437)
                homeScreenCornerRadius = 0
                statusBarHeight = 20
                transform = 0.59
                dockHeight = 96
                screenWidth = 414
                screenHeight = 736
            } else if _phoneType == .iPhoneX {
                backgroundViewFrame = CGRect(x: 50, y: 80, width: 260, height: 530)
                homeScreenFrame = CGRect(x: 11, y: 10, width: 236, height: 510)
                homeScreenCornerRadius = 35
                statusBarHeight = 44
                transform = 0.63
                dockHeight = 93.33
                screenWidth = 375
                screenHeight = 812
				dockMargins = 11
            }
        }
        
        let transformedDockHeight = dockHeight * transform
        _backgroundView = UIImageView(frame: backgroundViewFrame)
        if _deviceType == .iPad {
            _backgroundView?.image = UIImage(named: "iPad mini")
        } else {
            if _phoneType == .iPhone5S {
                _backgroundView?.image = UIImage(named: "iPhone 5s")
            } else if _phoneType == .iPhone6 {
                _backgroundView?.image = UIImage(named: "iPhone 6")
            } else if _phoneType == .iPhone6Plus {
                _backgroundView?.image = UIImage(named: "iPhone 6+")
            } else if _phoneType == .iPhoneX {
                _backgroundView?.image = UIImage(named: "iPhone X")
            }
        }
        
        _backgroundView?.isUserInteractionEnabled = false
        self.view.addSubview(_backgroundView!)
        
        if _deviceType == .iPhone && _phoneType == .iPhoneX {
            let overlayView = UIImageView(frame: (_backgroundView?.bounds)!)
            overlayView.image = UIImage(named: "iPhone X-overlay")
            overlayView.isUserInteractionEnabled = false
            overlayView.layer.zPosition = 5000
            _backgroundView?.addSubview(overlayView)
        }
        
        self.viewDidLayoutSubviews()
        
        let wallpaper = getWallpaper()
        
        if _useBlurredBackground {
            let blurredBackgroundView = UIImageView(frame: self.view.bounds)
            blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurredBackgroundView.image = wallpaper
            blurredBackgroundView.contentMode = .scaleAspectFill
            
            let darkeningView = UIView(frame: blurredBackgroundView.bounds)
            darkeningView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            darkeningView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            blurredBackgroundView.addSubview(darkeningView)
            self.view.addSubview(blurredBackgroundView)
            self.view.sendSubviewToBack(blurredBackgroundView)
        }
        
        let homeScreenView = UIImageView(frame: homeScreenFrame)
        homeScreenView.image = wallpaper
        homeScreenView.contentMode = .scaleAspectFill
        homeScreenView.clipsToBounds = true
        if homeScreenCornerRadius > 0 {
            homeScreenView.layer.cornerRadius = homeScreenCornerRadius
        }
        _backgroundView?.addSubview(homeScreenView)
        
        _backgroundView?.alpha = 0.5
        UIView.animate(withDuration: 0.25, animations: {
            self._backgroundView?.alpha = 1.0
        }) { _ in
            self._refreshView?.stopAnimating()
            self._refreshView?.isHidden = true
        }
        
        let statusBar = UIStatusBar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: statusBarHeight))
        statusBar.transform = CGAffineTransform(scaleX: transform, y: transform)
        statusBar.frame = CGRect(x: 0, y: 0, width: homeScreenFrame.size.width, height: statusBarHeight * transform)
        statusBar.request(.lightContent)
        homeScreenView.addSubview(statusBar)
        
        let homeContentsView = UIView(frame: .zero)
        homeContentsView.transform = CGAffineTransform(scaleX: transform, y: transform)
        homeContentsView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        homeScreenView.addSubview(homeContentsView)
        
        let dockContentsView = UIView(frame: .zero)
        dockContentsView.transform = CGAffineTransform(scaleX: transform, y: transform)
        dockContentsView.frame = CGRect(x: 0, y: homeScreenFrame.size.height - transformedDockHeight - (dockMargins * transform), width: homeScreenFrame.size.width, height: transformedDockHeight)
        homeScreenView.addSubview(dockContentsView)
        
        let iconState = getIconState()
        
        let buttonBar = iconState?.object(forKey: "buttonBar") as? NSArray
        
        let dockSettings = _UIBackdropViewSettings(forStyle: 2060, graphicsQuality: 100)
        dockSettings.blurRadius = 25
        
        var effectiveDockHeight: CGFloat = dockHeight + dockMargins
        
        if useFloatyDock {
            var x: CGFloat = 21
            
            let floatyDockBackgroundView = AnemoneFloatyDockBackgroundView(frame: CGRect.zero, autosizesToFitSuperview: false, settings: dockSettings)
            floatyDockBackgroundView.layer.cornerRadius = 31
            floatyDockBackgroundView.clipsToBounds = true
			floatyDockBackgroundView.configureForDisplay()
            
            let floatyDockContentsView = UIView(frame: CGRect(x: 0, y: 0, width: 1024, height: dockHeight))
            floatyDockBackgroundView.addSubview(floatyDockContentsView)
            
            buttonBar?.forEach({ rawIdentifier in
                guard let iconView = iconViewFromIdentifier(rawBundleIdentifier: rawIdentifier, hasLabel: false, inDock: true) else {
                    return
                }
                var frame = iconView.frame
                frame.origin.x = x
                if _deviceType != .iPad {
                    frame.origin.y = 17
                } else {
                    frame.origin.y = 20
                }
                iconView.frame = frame
                floatyDockContentsView.addSubview(iconView)
                if _deviceType != .iPad {
                    x += frame.size.width + 27
                } else {
                    x += frame.size.width + 21
                }
            })
            
            var floatyContentFrame = floatyDockContentsView.frame
            floatyContentFrame.size.width = x
            floatyDockContentsView.frame = floatyContentFrame
            floatyDockBackgroundView.frame = floatyContentFrame
            
            let floatyScale: CGFloat = (screenWidth - floatyDockMargins)/floatyContentFrame.size.width
            if floatyScale < 1.0 {
                floatyDockBackgroundView.transform = CGAffineTransform(scaleX: floatyScale, y: floatyScale)
            }
            
            var floatyDockFrame = floatyDockBackgroundView.frame
            floatyDockFrame.origin.x = (screenWidth - floatyDockFrame.size.width)/2
            floatyDockFrame.origin.y = dockHeight - (floatyDockFrame.size.height + 17)
            floatyDockBackgroundView.frame = floatyDockFrame
            
            effectiveDockHeight = floatyDockFrame.size.height + floatyDockYMargin
            dockContentsView.addSubview(floatyDockBackgroundView)
        } else {
            let dockRootView = UIView(frame: .zero)
            dockRootView.frame = CGRect(x: 0, y: 0, width: homeScreenFrame.size.width, height: transformedDockHeight)
            dockContentsView.addSubview(dockRootView)
            
            let dockView = AnemoneDockBackgroundView(frame: CGRect(x: dockMargins, y: 0, width: screenWidth - (2 * dockMargins), height: dockHeight), autosizesToFitSuperview: false, settings: dockSettings)
			dockView.clipsToBounds = true
			dockView.layer.cornerRadius = (dockMargins * 2)
			dockView.configureForDisplay()
            dockRootView.addSubview(dockView)
            
            let dockOverlayView = AnemoneDockOverlayView(frame: CGRect(x: dockMargins, y: 0, width: screenWidth - (2 * dockMargins), height: dockHeight))
            dockOverlayView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
			dockOverlayView.clipsToBounds = true
			dockOverlayView.layer.cornerRadius = (dockMargins * 2)
			dockOverlayView.configureForDisplay()
            dockRootView.addSubview(dockOverlayView)
            
            var dockXBase: CGFloat = 168.0
            var dockPosDiff: CGFloat = 38.0
            var dockXSeparation: CGFloat = 76.0
            let dockYPos: CGFloat = 14
            
            if _phoneType == .iPhone6 {
                dockXBase = 199.0
                dockPosDiff = 43.0
                dockXSeparation = 87.0
            } else if _phoneType == .iPhone6Plus {
                dockXBase = 223.0
                dockPosDiff = 47.0
                dockXSeparation = 94.0
			} else if _phoneType == .iPhoneX {
				dockXBase = 199.0
				dockPosDiff = 43.0
				dockXSeparation = 87.0
			}
            
            var buttonBarCount: CGFloat = CGFloat(buttonBar!.count)
            if buttonBarCount > 4.0 {
                buttonBarCount = 4
            }
            
            var x: CGFloat = dockXBase - (dockPosDiff * buttonBarCount)
            
            buttonBar?.forEach({ rawIdentifier in
                guard let iconView = iconViewFromIdentifier(rawBundleIdentifier: rawIdentifier, hasLabel: false, inDock: true) else {
                    return
                }
                var frame: CGRect = iconView.frame
                frame.origin.x = x
                frame.origin.y = dockYPos
                iconView.frame = frame
                dockContentsView.addSubview(iconView)
                x += dockXSeparation
            })
        }
        
        var iconXSeparation: CGFloat = 87
        var iconYSeparation: CGFloat = 102
        if _deviceType == .iPad {
            iconXSeparation = 176
            iconYSeparation = 161
        } else {
            if _phoneType == .iPhone5S {
                iconXSeparation = 76
                iconYSeparation = 88
            } else if _phoneType == .iPhone6 {
                iconXSeparation = 87
                iconYSeparation = 88
            } else if _phoneType == .iPhone6Plus {
                iconXSeparation = 94
                iconYSeparation = 100
            } else if _phoneType == .iPhoneX {
                iconXSeparation = 87
                iconYSeparation = 102
            }
        }
        
        var page = 0
        var iconList = (iconState?.object(forKey: "iconLists") as? NSArray)?.object(at: page) as? NSArray
        while iconList?.count == 0 {
            page += 1
            iconList = (iconState?.object(forKey: "iconLists") as? NSArray)?.object(at: page) as? NSArray
        }
        var i = 1
        var x: CGFloat = 27
        var y: CGFloat = 71
        if _deviceType == .iPad {
            x = 82
            y = 68
        } else {
            if _phoneType == .iPhone5S {
                x = 16
                y = 25
            } else if _phoneType == .iPhone6 {
                x = 27
                y = 24
            } else if _phoneType == .iPhone6Plus {
                x = 35
                y = 18
            } else if _phoneType == .iPhoneX {
                x = 27
                y = 71
            }
        }
        let initialX: CGFloat = x
        iconList?.forEach({ rawIdentifier in
            guard let iconView = iconViewFromIdentifier(rawBundleIdentifier: rawIdentifier, hasLabel: true, inDock: false) else {
                return
            }
            var frame = iconView.frame
            frame.origin.x = x
            frame.origin.y = y
            iconView.frame = frame
            homeContentsView.addSubview(iconView)
            x += iconXSeparation
            if i%4 == 0 {
                x = initialX
                y += iconYSeparation
            }
            i += 1
            if _deviceType != .iPad {
                if _phoneType != .iPhone5S {
                    if i > 24 {
                        return
                    }
                }
            }
            if i > 20 {
                return
            }
        })
        
        let pageDots = UIView(frame: CGRect(x: 0, y: screenHeight - (effectiveDockHeight + 37), width: screenWidth, height: 37))
        let pageDot = AnemoneExtensionParameters.kitImageNamed("UIPageIndicator")
        let pageDotCurrent = AnemoneExtensionParameters.kitImageNamed("UIPageIndicatorCurrent")
        let pageDotSize = pageDotCurrent.size
        
        var pageCount = ((iconState?.object(forKey: "iconLists") as? NSArray)?.count)!
        pageCount += 1
        
        let pageDotSeparators: CGFloat = 8.0
        let width = (pageDotSize.width * CGFloat(pageCount)) + (pageDotSeparators * (CGFloat(pageCount) - 1))
        var pageX = (pageDots.frame.size.width / 2.0) - (width / 2.0)
        let pageY = (pageDots.frame.size.height / 2.0) - (pageDotSize.height / 2.0)
        
        for i in stride(from: 0, to: pageCount, by: 1) {
            let idx = i - 1
            
            let dotView = UIImageView(frame: CGRect(x: pageX, y: pageY, width: pageDotSize.width, height: pageDotSize.height))
            if idx == page {
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
    
    func getHomeScreenIconForApp(app: LSApplicationProxy, isiPad: Bool, getThemed: Bool) -> UIImage? {
        let iconsDictionary = app.iconsDictionary() as NSDictionary?
		let bundle = Bundle(url: app.bundleURL()!)
        
        var variant: Int32 = 15
        if _deviceType == DeviceType.iPad {
            variant = 24
        } else {
            if UIScreen.main.scale == 3 {
                variant = 32
            }
        }
        
        let options: Int32 = 0
        
        return getIconForBundle(bundle, iconsDictionary as? [AnyHashable: Any], variant, options, 2.0, getThemed)
    }
    
    func miniIconViewFromIdentifier(rawBundleIdentifier: Any?) -> UIView? {
        guard let bundleIdentifier = rawBundleIdentifier as? String else {
            return nil
        }
        
        let scale = UIScreen.main.scale
        
        guard let app = LSApplicationProxy(forIdentifier: bundleIdentifier) else {
            if bundleIdentifier == "com.apple.videos" {
                return miniIconViewFromIdentifier(rawBundleIdentifier: "com.apple.tv")
            }
            return nil
        }
        guard let bundlePathStr = app.bundleURL()?.path else {
            return nil
        }
        let bundlePath = bundlePathStr as NSString
        
        let infoPlist = NSDictionary(contentsOfFile: (bundlePath.appendingPathComponent("Info.plist")))
        
        var icon = getHomeScreenIconForApp(app: app, isiPad: _deviceType == DeviceType.iPad, getThemed: true)
        if icon == nil {
            icon = getHomeScreenIconForApp(app: app, isiPad: _deviceType == DeviceType.iPad, getThemed: false)
        }
        let prerendered = infoPlist?.object(forKey: "UIPrerenderedIcon") as? Bool
        icon = icon?._applicationIconImage(forFormat: 2, precomposed: prerendered ?? false, scale: scale)
        
        var iconViewFrame = CGRect(x: 0, y: 0, width: 13, height: 13)
        if _deviceType == DeviceType.iPad {
            iconViewFrame = CGRect(x: 0, y: 0, width: 11, height: 11)
        }
        
        let iconView = UIImageView(frame: iconViewFrame)
        iconView.image = icon
        iconView.layer.minificationFilter = .trilinear
        
        return iconView
    }
    
    func folderIconViewFromIdentifier(folderDictionary: NSDictionary?, hasLabel: Bool, inDock: Bool) -> UIView? {
        var iconViewFrame = CGRect(x: 0, y: 0, width: 76, height: 93)
        var iconImageViewFrame = CGRect(x: -1, y: -1, width: 78, height: 78)
        var labelFrame = CGRect(x: -10, y: 83, width: 96, height: 16)
        let cornerRadius: CGFloat = 12
        if _deviceType != .iPad {
            iconViewFrame = CGRect(x: 0, y: 0, width: 60, height: 74)
            iconImageViewFrame = CGRect(x: -1, y: -1, width: 62, height: 62)
            labelFrame = CGRect(x: -18, y: 63, width: 96, height: 16)
        }
        
        let iconView = AnemoneFolderIconView(frame: iconViewFrame)
        let iconImageView = UIImageView(frame: iconImageViewFrame)
        iconImageView.contentMode = .center
        
        var mask = UIImage(contentsOfFile: "/System/Library/PrivateFrameworks/MobileIcons.framework/AppIconMask~iphone.png")
        if UIDevice.current.userInterfaceIdiom == .pad {
            mask = UIImage(contentsOfFile: "/System/Library/PrivateFrameworks/MobileIcons.framework/AppIconMask~ipad.png")
        }
        
        UIGraphicsBeginImageContextWithOptions(iconImageView.bounds.size, false, 0)
        UIColor.white.setFill()
        mask?.draw(in: CGRect(x: (iconImageView.bounds.size.width-mask!.size.width)/2.0, y: (iconImageView.bounds.size.height-mask!.size.height)/2.0, width: mask!.size.width, height: mask!.size.height))
        let renderedMask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let maskView = UIImageView(frame: iconImageView.bounds)
        maskView.image = renderedMask
        
        let folderSettings = _UIBackdropViewSettings(forStyle: 2060, graphicsQuality: 100)
        let folderBackgroundView = _UIBackdropView.init(frame: CGRect.zero, autosizesToFitSuperview: true, settings: folderSettings)
        folderBackgroundView.layer.cornerRadius = cornerRadius
        folderBackgroundView.clipsToBounds = true
        iconImageView.addSubview(folderBackgroundView)
        
        let folderOverlayView = UIView(frame: iconImageView.bounds)
        folderOverlayView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        folderOverlayView.layer.cornerRadius = cornerRadius
        folderOverlayView.clipsToBounds = true
        iconImageView.addSubview(folderOverlayView)
        
        let gridView = UIView(frame: iconImageView.bounds)
        iconImageView.addSubview(gridView)
        
        var i: Int32 = 1
        var x: CGFloat = 9
        var minx: CGFloat = 8
        var y: CGFloat = 9
        var maxX: Int32 = 3
        var maxItems: Int32 = 9
        
        var folderSeparator: CGFloat = 16
        if _deviceType == DeviceType.iPad {
            x = 11
            minx = 11
            y = 11
            folderSeparator = 14
            maxX = 4
            maxItems = 16
        }
        
        let iconList = (folderDictionary?.object(forKey: "iconLists") as? NSArray)?.object(at: 0) as? NSArray
        iconList?.forEach({ rawIdentifier in
            let identifier = rawIdentifier as? String
            guard let miniIcon = miniIconViewFromIdentifier(rawBundleIdentifier: identifier) else {
                return
            }
            var frame = miniIcon.frame
            frame.origin.x = x
            frame.origin.y = y
            miniIcon.frame = frame
            gridView.addSubview(miniIcon)
            x += folderSeparator
            if i%maxX == 0 {
                x = minx
                y += folderSeparator
            }
            if i >= maxItems {
                return
            }
            i+=1
        })
        
        iconView.addSubview(iconImageView)
        
        iconView.iconView = iconImageView
        iconView.backdropView = folderBackgroundView
        iconView.backdropOverlayView = folderOverlayView
        iconView.gridView = gridView
        iconView.inDock = inDock
        
        if hasLabel {
            let iconLabel = UILabel(frame: labelFrame)
            iconLabel.backgroundColor = .clear
            iconLabel.textAlignment = .center
            if _deviceType == .iPad {
                iconLabel.font = UIFont.systemFont(ofSize: 14)
            } else {
                iconLabel.font = UIFont.systemFont(ofSize: 12)
            }
            iconLabel.textColor = .white
            iconView.addSubview(iconLabel)
            
            let iconLabelText = folderDictionary?.object(forKey: "displayName") as? String
            iconLabel.text = iconLabelText
            
            iconView.iconLabel = iconLabel
        }
        
        iconView.configureForDisplay()
        
        return iconView
    }
    
    func iconViewFromIdentifier(rawBundleIdentifier: Any?, hasLabel: Bool, inDock: Bool) -> UIView? {
        guard let bundleIdentifier = rawBundleIdentifier as? String else {
            return folderIconViewFromIdentifier(folderDictionary: (rawBundleIdentifier as? NSDictionary), hasLabel: hasLabel, inDock: inDock)
        }
        
        let scale: CGFloat = UIScreen.main.scale
        
        guard let app = LSApplicationProxy(forIdentifier: bundleIdentifier) else {
            if bundleIdentifier == "com.apple.videos" {
                return iconViewFromIdentifier(rawBundleIdentifier: "com.apple.tv", hasLabel: hasLabel, inDock: inDock)
            }
            return nil
        }
        guard let bundlePathStr = app.bundleURL()?.path else {
            return nil
        }
        let bundlePath = bundlePathStr as NSString
        let infoPlist = NSDictionary(contentsOfFile: bundlePath.appendingPathComponent("Info.plist"))!
        
        var icon = getHomeScreenIconForApp(app: app, isiPad: _deviceType == DeviceType.iPad, getThemed: true)
        if icon == nil {
            icon = getHomeScreenIconForApp(app: app, isiPad: _deviceType == DeviceType.iPad, getThemed: false)
        }
        icon = icon?._applicationIconImage(forFormat: 2, precomposed: (infoPlist.object(forKey: "UIPrerenderedIcon") as? NSNumber)?.boolValue ?? false, scale: scale)
        
        if icon != nil {
            if (infoPlist.object(forKey: "SBIconClass") as? String) == "SBCalendarApplicationIcon" {
                let calendarIconObj = SBCalendarApplicationIcon()
                if calendarIconObj.responds(to: #selector(SBCalendarApplicationIcon.drawTextIntoCurrentContext(withImageSize:iconBase:))) {
                    UIGraphicsBeginImageContextWithOptions(icon!.size, false, 0.0)
                    calendarIconObj.drawTextIntoCurrentContext(withImageSize: icon!.size, iconBase: icon!)
                    icon = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                }
            }
        }
        
        var iconViewFrame = CGRect(x: 0, y: 0, width: 76, height: 93)
        var iconImageViewFrame = CGRect(x: -1, y: -1, width: 78, height: 78)
        var labelFrame = CGRect(x: -10, y: 83, width: 96, height: 16)
        if _deviceType != .iPad {
            iconViewFrame = CGRect(x: 0, y: 0, width: 60, height: 74)
            iconImageViewFrame = CGRect(x: -1, y: -1, width: 62, height: 62)
            labelFrame = CGRect(x: -18, y: 63, width: 96, height: 16)
        }
        
        let iconView = AnemoneIconView(frame: iconViewFrame)
        let iconImageView = UIImageView(frame: iconImageViewFrame)
        iconImageView.image = icon
        iconImageView.layer.minificationFilter = .trilinear
        iconView.addSubview(iconImageView)
        
        iconView.imageView = iconImageView
        iconView.inDock = inDock
        
        if hasLabel {
            let iconLabel = UILabel(frame: labelFrame)
            iconLabel.backgroundColor = .clear
            iconLabel.textAlignment = .center
            if _deviceType == .iPad {
                iconLabel.font = UIFont.systemFont(ofSize: 14)
            } else {
                iconLabel.font = UIFont.systemFont(ofSize: 12)
            }
            iconLabel.textColor = .white
            iconView.addSubview(iconLabel)
            
            var iconLabelText = app.localizedName()
            if iconLabelText == "" || iconLabelText == nil {
                iconLabelText = infoPlist.object(forKey: "CFBundleExecutable") as? String
            }
            iconLabel.text = iconLabelText
            
            iconView.iconLabel = iconLabel
        }
        
        iconView.configureForDisplay()
        
        return iconView
    }
    
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkThemedIconForBundle(bundle: String) -> String? {
        var bundleIdentifier = bundle
        let themesDir = PackageListManager.shared.prefixDir().path
        
        guard let themes = UserDefaults.standard.value(forKey: "settingsPacked") as? [String] else {
            return nil
        }
        
        if bundleIdentifier == "com.anemoneteam.anemone" {
            bundleIdentifier = "com.anemonetheming.anemone"
        }

        if bundleIdentifier == "org.coolstar.electra1141" {
            bundleIdentifier = "org.coolstar.electra1131"
        }
        
        for identifier in themes {
            let ibLargeThemePath = String(format: "%@/%@/IconBundles/%@-large.png", themesDir, identifier, bundleIdentifier)
            var icon = UIImage(contentsOfFile: ibLargeThemePath)
            if icon != nil {
                return ibLargeThemePath
            }
            
            let ibThemePath = String(format: "%@/%@/IconBundles/%@.png", themesDir, identifier, bundleIdentifier)
            icon  = UIImage(contentsOfFile: ibThemePath)
            if icon != nil {
                return ibThemePath
            }
        }
        return nil
    }
    
    func applyAltIconName(altIconName: String?) {
        let workspace = LSApplicationWorkspace.default()
        let allApps = workspace.allInstalledApplications()
        
        let sem = DispatchSemaphore(value: allApps.count)
        
        allApps.forEach { app in
            let bundleIdentifier = app.anemIdentifier()
            
            clearCacheForItem(bundleIdentifier)
            
            var shouldApplyIcon = true
            
            if altIconName == "__ANEM__AltIcon" {
                shouldApplyIcon = false
                
                let icon = checkThemedIconForBundle(bundle: app.anemIdentifier()!)
                
                if icon != nil {
                    shouldApplyIcon = true
                }
            }
            if shouldApplyIcon {
                app.setAlternateIconName(altIconName, withResult: { _, _ in
                        sem.signal()
                })
            } else {
                sem.signal()
            }
        }
        _ = sem.wait(timeout: DispatchTime.distantFuture)
    }
    
    @objc func applyThemes() {
        let alertController = UIAlertController(title: "Applying Changes", message: "Please Wait", preferredStyle: UIAlertController.Style.alert)
        self.present(alertController, animated: true) {
            let recache = NSTask()
            recache.launchPath = "/usr/bin/recache"
            recache.arguments = ["--no-respring"]
            recache.launch()
            recache.waitUntilExit()
            
            let notificationName = "com.anemoneteam.anemone/reload" as CFString
            
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(notificationName), nil, nil, true)
            
            self.applyAltIconName(altIconName: nil)
            
            self.applyAltIconName(altIconName: "__ANEM__AltIcon")
            
            if AnemoneExtensionParameters.respringRequired() {
                let killall = NSTask()
                killall.launchPath = "/usr/bin/killall"
                killall.arguments = ["backboardd"]
                killall.launch()
                killall.waitUntilExit()
            } else {
                alertController.dismiss(animated: true) {
                    UIApplication.shared.suspend()
                }
            }
        }
    }
}
