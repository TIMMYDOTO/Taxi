//
//  Extensions.swift
//  MusicAssistant
//
//  Created by Igor Tyukavkin on 21.10.2017.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import Alamofire

enum InternetConnectionStatus {
    case unknown
    case notReachable
    case reachableViaWiFi
    case reachableViaCellular
}

enum RCError: Error {
    case connectionError
    case incorrectData
    case cancel
    case removeFile
    case syncError
    case permissionDenied
    case unknown
    case transactionValidation
    case noResponse
    case unauthorized
}

var ConnectionStatus: InternetConnectionStatus {
    if let manager = NetworkReachabilityManager(host: "www.google.com") {
        switch manager.networkReachabilityStatus {
        case .unknown:
            return .unknown
        case .notReachable:
            return .notReachable
        case .reachable:
            if manager.isReachableOnEthernetOrWiFi {
                return .reachableViaWiFi
            } else {
                return .reachableViaCellular
            }
        }
    } else {
        return .unknown
    }
}

enum CountTextType:Int {
    case one, two, many
}

func countTextTypeWithCount(_ count:Int) -> CountTextType {
    var countLastSymbol:String = "\(count)"
    let countString = NSString(string:countLastSymbol)
    if countString.length > 1 {
        let prevSymbol = countString.substring(with: NSRange(location: countString.length - 2, length: 1))
        let lastSymbol = countString.substring(with: NSRange(location: countString.length - 1, length: 1))
        if prevSymbol == "1" {
            return .many
        }
        countLastSymbol = lastSymbol
    }
    if countLastSymbol == "1" {
        return .one
    } else if countLastSymbol == "2" || countLastSymbol == "3" || countLastSymbol == "4" {
        return .two
    }
    return .many
}

var bottomSafeAreaInset: CGFloat {
    if #available(iOS 11.0, *) {
        if let bottomEdge = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            return bottomEdge
        }
    }
    return 0.0
}

var topSafeAreaInset: CGFloat {
    if #available(iOS 11.0, *) {
        if let topEdge = UIApplication.shared.keyWindow?.safeAreaInsets.top {
            return topEdge
        }
    }
    return UIApplication.shared.statusBarFrame.height
}

extension UIView {
    private var gradientlayer:CAGradientLayer? {
        var grLayer:CAGradientLayer?
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                if let glayer  = layer as? CAGradientLayer {
                    grLayer = glayer
                    break
                }
            }
        }
        return grLayer
    }
    
    func setGradient(_ colors:[UIColor], horizontal:Bool = false) {
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
        self.gradientlayer?.removeFromSuperlayer()
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors.map({ (color) -> CGColor in
            return color.cgColor
        })
        gradient.startPoint = horizontal ? CGPoint(x: 0.0, y: 0.5) : CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = horizontal ? CGPoint(x: 1.0, y: 0.5) : CGPoint(x: 0.5, y: 1.0)
        var locations = [NSNumber]()
        for i in 0..<colors.count {
            let doubleValue = Double(i)*1.0/Double(colors.count - 1)
            let location = NSNumber(value: Double(round(100*doubleValue)/100) as Double)
            locations.append(location)
        }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func updateGradient(rect: CGRect? = nil) {
        gradientlayer?.frame = rect ?? self.bounds
    }
}

extension UIView {
    func render() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return layer.shadowColor == nil ? UIColor.clear : UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
  @IBInspectable var shadowOffset:CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
  @IBInspectable var shadowOpacity:Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    var shadowRadius:CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    func addShadow(_ color: UIColor = UIColor.black, offset: CGSize = CGSize(width: 0.0, height: 2.0), radius: CGFloat = 2, opacity: Float = 0.3) {
        shadowColor = color
        shadowOffset = offset
        shadowOpacity = opacity
        shadowRadius = radius
    }
    
    func removeShadow() {
        shadowOpacity = 0.0
    }
}

extension String {
    func attributed(attributedString: NSAttributedString?) -> NSAttributedString {
        if let attributedString = attributedString {
            let attributes = attributedString.attributes(at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: attributedString.length))
            return attributed(attributes: attributes)
        }
        return attributed(attributes: nil)
    }
    
    func attributed(attributes: [NSAttributedStringKey: Any]?) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes)
    }
}

extension UITextView {
    func resetStyles() {
        contentInset = UIEdgeInsets.zero
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0.0
    }
}

extension NumberFormatter {
    static let timerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimumIntegerDigits = 2
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

extension UIImage {
    
    class func backgroundImage(withColor color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func multiplyImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(self.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        self.draw(in: rect, blendMode: .multiply, alpha: 1)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    static func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func changeColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            let rect = CGRect(x:0, y:0, width:self.size.width, height:self.size.height)
            if let cgImage = self.cgImage {
                context.clip(to: rect, mask: cgImage)
                color.setFill()
                context.fill(rect)
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return newImage ?? self
            }
        }
        return self
    }
    
}

extension UIViewController {
    static var identifier: String {
        return String(describing: self)
    }
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        backgroundColor = nil
        let backgroundImage = UIImage.backgroundImage(withColor: color)
        setBackgroundImage(backgroundImage, for: state)
    }
    
    /** Re-position button image on top of the title label. */
    func verticallyAlignImageAndTitle(padding: CGFloat = 6.0) {
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        self.imageEdgeInsets = UIEdgeInsets( top: -(totalHeight - imageSize.height),
                                             left: 0,
                                             bottom: 0,
                                             right: -titleSize.width )
        self.titleEdgeInsets = UIEdgeInsets( top: 0,
                                             left: -imageSize.width,
                                             bottom: -(totalHeight - titleSize.height),
                                             right: 0 )
    }
}

extension String {
    
//    static func priceMinTimeString(_ minTime: Int, type: PriceCityMinTypeTime) -> String {
//        var result = ""
//        let countTextType = countTextTypeWithCount(minTime)
//        switch countTextType {
//        case .one:
//            result += "\(minTime) " + (type == .hours ? "час" : "минута")
//        case .two:
//            result += "\(minTime) " + (type == .hours ? "часа" : "минуты")
//        case .many:
//            result += "\(minTime) " + (type == .hours ? "часов" : "минут")
//        }
//        return result
//    }
    
    static func loadersString(count: Int) -> String {
        guard count > 0 else { return "Не требуются" }
        var result = ""
        let countTextType = countTextTypeWithCount(count)
        switch countTextType {
        case .one:
            result += "\(count) " + "грузчик"
        case .two:
            result += "\(count) " + "грузчика"
        case .many:
            result += "\(count) " + "грузчиков"
        }
        return result
    }
    
    var first: String {
        return String(prefix(1))
    }
    var last: String {
        return String(suffix(1))
    }
    var uppercaseFirst: String {
        return first.uppercased() + String(dropFirst())
    }
    
    func makeSpaces() -> String {
        guard self.count > 0 else { return self }
        let regexPattern = try! NSRegularExpression(pattern: "\\d{4}", options: .caseInsensitive)
        let nsString = NSString(string: self)
        let matches = regexPattern.matches(in: self, options: .withoutAnchoringBounds, range: nsString.range(of: self))
        guard matches.count > 0 else { return self }
        let matchStrings = matches.compactMap { (result) -> String? in
            return nsString.substring(with: result.range)
        }
        let count = matches.count > 4 ? 4 : matches.count
        let components = matchStrings.prefix(count)
        let lastMatchRange = matches[count-1].range
        let number = components.joined(separator: " ") + nsString.substring(from: lastMatchRange.location + lastMatchRange.length)
        return number
    }
    
    var localized: String {
        return localizedWithComment("")
    }
    
    func localizedWithComment(_ comment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
    var isEmptyOrWhitespace: Bool {
        return self.trim() == ""
    }
    
    func trim() -> String {
        if(self.isEmpty) {
            return ""
        }
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func customize(attributes: [NSAttributedStringKey : Any], delimiter: String) -> NSMutableAttributedString {
        let string = self as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.customize(attributes: attributes, delimiter: delimiter)
        return attributedString
    }
    
    /** Simplification of the 'customize()' method. It only accepts color. */
    func highlight(with color: UIColor, delimiter: String) -> NSMutableAttributedString {
        return self.customize(attributes: [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): color], delimiter: delimiter)
    }
    func addAttributes(attributes: [NSAttributedStringKey: Any], delimiter: String) -> NSMutableAttributedString {
        return self.customize(attributes: attributes, delimiter: delimiter)
    }
    
}

extension NSMutableAttributedString {
    func highlight(with color: UIColor, delimiter: String) {
        self.customize(attributes: [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): color], delimiter: delimiter)
    }
    func addAttributes(attributes: [NSAttributedStringKey: Any], delimiter: String) {
        self.customize(attributes: attributes, delimiter: delimiter)
    }
    func customize(attributes: [NSAttributedStringKey : Any], delimiter: String) {
        let escaped = NSRegularExpression.escapedPattern(for: delimiter)
        if let regex = try? NSRegularExpression(pattern:"\(escaped)(.*?)\(escaped)", options: []) {
            var offset = 0
            regex.enumerateMatches(in: self.string,
                                   options: [],
                                   range: NSRange(location: 0,
                                                  length: self.string.count)) { (result, flags, stop) -> Void in
                                                    guard let result = result else {
                                                        return
                                                    }
                                                    
                                                    let range = NSRange(location: result.range.location + offset, length: result.range.length)
                                                    self.addAttributes(attributes, range: range)
                                                    let replacement = regex.replacementString(for: result, in: self.string, offset: offset, template: "$1")
                                                    self.replaceCharacters(in: range, with: replacement)
                                                    offset -= (2 * delimiter.count)
            }
        }
    }
}

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>(withClass: T.Type) -> T {
        return instantiateViewController(withIdentifier: withClass.identifier) as! T
    }
}

extension UITableView {
    func register<T: UITableViewCell>(nib: T.Type) {
        self.register(UINib(nibName: String(describing: nib), bundle: nil), forCellReuseIdentifier: String(describing: nib))
    }
    func register<T: UITableViewCell>(class cellClass: T.Type) {
        self.register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(nib: T.Type) {
        self.register(UINib(nibName: String(describing: nib), bundle: nil), forCellWithReuseIdentifier: String(describing: nib))
    }
    func register<T: UICollectionViewCell>(class cellClass: T.Type) {
        self.register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
}

extension UIWindow {
    var topViewController: CommonViewController? {
        return parseVC(vc: self.rootViewController)
    }
    
    private func parseVC(vc: UIViewController?) -> CommonViewController? {
        if let presentedVC = vc?.presentedViewController {
            return parseVC(vc: presentedVC)
        } else if let navVC = vc as? UINavigationController {
            return parseVC(vc: navVC.topViewController)
        } else if let tabBarVC = vc as? UITabBarController {
            return parseVC(vc: tabBarVC.selectedViewController)
        } else if let commonVC = vc as? CommonViewController {
            return commonVC
        }
        return nil
    }
}

extension UITableView {
    func reloadData(transition type: String,
                    subtype: String? = nil,
                    timingFunction: String = kCAMediaTimingFunctionEaseInEaseOut,
                    duration: TimeInterval = 0.2) {
        let animation = CATransition()
        animation.type = type
        animation.subtype = subtype
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.fillMode = kCAFillModeBoth
        animation.duration = duration
        self.layer.add(animation, forKey: "UITableViewReloadDataAnimationKey")
        self.reloadData()
    }
    
}

extension Bool {
    static var random: Bool {
        return arc4random_uniform(2) == 0
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int)
    {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: 1.0)
    }
    
    convenience init(netHex: Int)
    {
        self.init(red: (netHex >> 16) & 0xff,
                  green: (netHex >> 8) & 0xff,
                  blue: netHex & 0xff)
    }
    
    convenience init(_ hexString: String)
    {
        let hexString = hexString.replacingOccurrences(of: "#", with: "")
        self.init(netHex: Int(strtoul(hexString, nil, 16)))
    }
    
    class var ma_red: UIColor {
        return UIColor(red: 255.0/255.0, green: 104.0/255.0, blue: 88.0/255.0, alpha: 1.0)
    }
    
}

extension DateFormatter {
    static let orderDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY HH:mm"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

extension NumberFormatter {
    static let volumeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
    static let distanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
    static func distanceString(_ distance: Double) -> String {
        return (distanceFormatter.string(from: distance as NSNumber) ?? "0") + " км"
    }
}

typealias PriceFormatter = NumberFormatter

extension PriceFormatter {
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencyGroupingSeparator = " "
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        formatter.allowsFloats = false
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "RU")
        return formatter
    }()
    
    static func stringFromPrice(price: Double, currencySymbol: String) -> String {
        let priceFormatter = NumberFormatter.priceFormatter
        priceFormatter.currencySymbol = currencySymbol
        return priceFormatter.string(from: price as NSNumber) ?? ""
    }
    
    static func stringFromPrice(price: Double) -> String {
        return stringFromPrice(price: price, currencySymbol: "₽")
    }
    
}

extension String {
    static func durationString(_ seconds: Int) -> String {
        var result = ""
        let minutes = seconds / 60
        let hours: Int = minutes / 60
        var extraMinutes: Int = minutes - hours*60
        extraMinutes = extraMinutes >= 0 ? extraMinutes : 0
        if hours > 0 {
            let hoursCountTextType = countTextTypeWithCount(hours)
            switch hoursCountTextType {
            case .one:
                result += "\(hours)" + " час"
            case .two:
                result += "\(hours)" + " часа"
            case .many:
                result += "\(hours)" + " часов"
            }
            result += " "
            let extraMinutesCountTextType = countTextTypeWithCount(extraMinutes)
            switch extraMinutesCountTextType {
            case .one:
                result += "\(extraMinutes)" + " минута"
            case .two:
                result += "\(extraMinutes)" + " минуты"
            case .many:
                result += "\(extraMinutes)" + " минут"
            }
        } else {
            let minutesCountTextType = countTextTypeWithCount(minutes)
            switch minutesCountTextType {
            case .one:
                result += "\(minutes)" + " минута"
            case .two:
                result += "\(minutes)" + " минуты"
            case .many:
                result += "\(minutes)" + " минут"
            }
        }
        return result
    }
}

extension Float {
    func volumeString(font: UIFont) -> NSAttributedString {
        let fontSize: CGFloat = CGFloat(roundf(Float(font.pointSize / CGFloat(1.5))))
        let smallFont = UIFont.cuprumFont(ofSize: fontSize)
        let smallAttrs: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: smallFont, NSAttributedStringKey.baselineOffset: (font.pointSize - smallFont.pointSize)]
        let string = (NumberFormatter.volumeFormatter.string(from: self as NSNumber) ?? "") + " м$$3$$"
        return string.addAttributes(attributes: smallAttrs, delimiter: "$$")
    }
}

func openSettings() {
    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
    if UIApplication.shared.canOpenURL(settingsUrl) {
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
}

extension  String {
    var json: [String: Any]? {
        if let data = self.data(using: String.Encoding.utf8) {
            let object = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            return object as? [String: Any]
        }
        return nil
    }
}

func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue
        .main
        .asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                    execute: closure)
}

@IBDesignable
class RotatedButton: UIButton {
    
    @IBInspectable var label_Rotation: CGFloat = 0 {
        didSet {
            rotateLabel(labelRotation: label_Rotation)
            self.layoutIfNeeded()
        }
    }
    
    func rotateLabel(labelRotation: CGFloat)  {
        self.transform = CGAffineTransform(rotationAngle: labelRotation)
    }
}


extension UIButton {
    
    
   
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

