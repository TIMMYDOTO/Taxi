//
//  ActiveOrderViewController.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 30.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import GoogleMaps
import MaterialActivityIndicator

class ActiveOrderViewController: CommonViewController {

    @IBOutlet weak var cancelOrderButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.cuprumFont(ofSize: 20.0)
            newValue.layer.backgroundColor = UIColor.blue_main.cgColor
            newValue.setTitleColor(.white, for: .normal)
            newValue.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
            newValue.layer.cornerRadius = 22.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.clear.cgColor
            newValue.tintColor = .white
            newValue.addShadow()
        }
    }
    
    @IBOutlet weak var searchingView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.white
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 19.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
            newValue.layer.borderWidth = 1.0
        }
    }
    
    @IBOutlet weak var orderInfoButton: UIButton! {
        willSet {
            newValue.isHidden = true
            newValue.layer.backgroundColor = UIColor.white.cgColor
            newValue.layer.masksToBounds = false
            newValue.layer.cornerRadius = 25.0
            newValue.layer.borderColor = UIColor.blue_main.cgColor
            newValue.layer.borderWidth = 1.0
            newValue.setTitleColor(UIColor.blue_main, for: .normal)
            newValue.setTitle("Информация о заказе".uppercased(), for: .normal)
            newValue.titleLabel?.font = UIFont.cuprumFont(ofSize: 20.0)
            newValue.addShadow()
        }
    }
    
    @IBOutlet weak var searchingLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 20.0)
            newValue.textColor = .black
            newValue.text = "Поиск исполнителей"
        }
    }
    
    @IBOutlet weak var loadingIndicator: MaterialActivityIndicatorView! {
        willSet {
            newValue.color = .blue_main
            newValue.backgroundColor = .clear
            newValue.startAnimating()
        }
    }
    
    @IBOutlet weak var performerView: ActiveOrderPerformerView! {
        willSet {
            newValue.alpha = 0.0
            newValue.isHidden = true
            newValue.communicateHandler = { [weak self] in
                self?.communicate(performer: $0)
            }
        }
    }
    fileprivate var isClosing = false
    
    @IBOutlet weak var mapOverlay: UIView!
    
    @IBOutlet weak var mapView: UIView!
    var map: GMSMapView!
    var markers: [GMSMarker] = []
    var polyline: GMSPolyline?
//    {
//        didSet {
//            guard let path = polyline?.path else { return }
//            self.path = path
//        }
//    }
    var start: GMSMarker?
    var end: GMSMarker?
    var selectedPerformer: OrderPerformer?
    let insetValue: CGFloat = 50.0
    
//    var drawingStarted = false
//    var animationPolyline = GMSPolyline()
//    var path = GMSPath()
//    var animationPath = GMSMutablePath()
//    var i: UInt = 0
//    var timer: Timer?
    

    
    fileprivate lazy var presentationModel: ActiveOrderPresentationModel = { [unowned self] in
        let model = ActiveOrderPresentationModel() { [weak self] in
            self?.handleError($0)
        }
        model.loadingHandler = { [weak self] in
            $0 ? self?.showHUD() : self?.hideHUD()
        }
        return model
    }()
    
//    deinit {
//        timer?.invalidate()
//        timer = nil
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Выполнение заказа"
        setupMap()
        presentationModel.cancelOrderHandler = { [weak self] in
            self?.orderCancelled()
        }
        presentationModel.showAlertHandler = { [weak self] in
            self?.showAlert(message: $0)
        }
        presentationModel.nearbyPerformersUpdated = { [weak self] in
            self?.updatePerformers(performers: $0)
        }
        presentationModel.orderUpdated = { [weak self] in
            self?.handleOrderChanges()
        }
        presentationModel.closeCurrentOrderHandler = { [weak self] in
            self?.closeCurrentOrder()
        }
        presentationModel.firstPerformerhandler = { [weak self] in
            self?.animateToPerformer()
        }
        presentationModel.needReviewPerformer = { [weak self] in
            self?.needReviewPerformer(performer: $0)
        }
        presentationModel.openDialog = { [weak self] in
            self?.communicate(performer: $0)
        }
        handleOrderChanges()
        animateToPerformer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        if let performer = AvtoletService.shared.performersToReview.first {
            needReviewPerformer(performer: performer)
        }
//        if polyline?.map == nil && !drawingStarted {
//            drawingStarted = true
//            let duration = 1.5 / Double(path.count() <= 0 ? 1 : path.count())
//            self.timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentationModel.getActiveOrder()
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude:  NovosibirskCenterCoordinate.coordinate.latitude,
                                              longitude: NovosibirskCenterCoordinate.coordinate.longitude,
                                              zoom: 16)
        self.map = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        self.map.settings.rotateGestures = false
        self.map.settings.tiltGestures = false
        self.mapView.addSubview(self.map)
        self.map.topAnchor.constraint(equalTo: self.mapView.topAnchor).isActive = true
        self.map.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor).isActive = true
        self.map.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor).isActive = true
        self.map.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor).isActive = true
        self.map.delegate = self
        setupRoute()
    }
    
    func updatePerformers(performers: [NearbyPerformer]) {
        guard presentationModel.performers?.count == 0 else { return }
        performerView.hide()
        let currentIds = performers.compactMap({ ($0.id, $0.type, $0.coordinate)})
        relocateMarkers(markersInfo: currentIds, animated: false)
        guard let bounds = presentationModel.order.routeData?.bounds else { return }
        var fit = GMSCoordinateBounds.init(coordinate: CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng), coordinate: CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng))
        for marker in markers {
            fit = fit.includingCoordinate(marker.position)
        }
        startAnimation(bounds: fit)
    }

    func setupRoute() {
        guard let bounds = presentationModel.order.routeData?.bounds else { return }
        CATransaction.begin()
        CATransaction.setValue(0.0, forKey: kCATransactionAnimationDuration)
        map.animate(with: GMSCameraUpdate.fit(GMSCoordinateBounds.init(coordinate: CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng), coordinate: CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng)), withPadding: insetValue))
        CATransaction.commit()
        guard let overviewPolyline = presentationModel.order.routeData?.overviewPolyline,
            let path = GMSPath(fromEncodedPath: overviewPolyline) else { return }
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = UIColor.blue_main
        polyline.geodesic = true
        polyline.map = self.map
        self.polyline = polyline
        guard let startLocation = presentationModel.order.routeData?.originLocation,
            let endLocation = presentationModel.order.routeData?.destinationLocation else { return }
        let startPoint = GMSMarker(position: CLLocationCoordinate2D(latitude: startLocation.lat,
                                                                    longitude: startLocation.lng))
        startPoint.iconView = {
            let imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30.0, height: 30.0)))
            imageView.contentMode = .scaleAspectFit
            imageView.image = #imageLiteral(resourceName: "point_round")
            return imageView
        }()
        startPoint.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        startPoint.map = self.map
        self.start = startPoint
        let endPoint = GMSMarker(position: CLLocationCoordinate2D(latitude: endLocation.lat,
                                                                    longitude: endLocation.lng))
        endPoint.iconView = {
            let imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30.0, height: 30.0)))
            imageView.contentMode = .scaleAspectFit
            imageView.image = #imageLiteral(resourceName: "point_square")
            return imageView
        }()
        endPoint.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        endPoint.map = self.map
        self.end = endPoint
    }
    
    func startAnimation(bounds: GMSCoordinateBounds) {
        CATransaction.begin()
        CATransaction.setValue(60.0, forKey: kCATransactionAnimationDuration)
        map.animate(with: GMSCameraUpdate.fit(bounds, withPadding: insetValue))
        CATransaction.commit()
    }
    
    func stopAnimation() {
        CATransaction.begin()
        CATransaction.setValue(0.0, forKey: kCATransactionAnimationDuration)
        map.animate(toZoom: map.camera.zoom)
        CATransaction.commit()
    }
    
//    @objc func animatePolylinePath() {
//        if (self.i < self.path.count()) {
//            DispatchQueue(label: "com.avtolet.draw").async { [weak self] in
//                guard let `self` = self else { return }
//                self.animationPath.add(self.path.coordinate(at: self.i))
//                self.animationPolyline.path = self.animationPath
//                self.animationPolyline.strokeColor = UIColor.blue_main
//                self.animationPolyline.strokeWidth = 5
//                self.animationPolyline.map = self.map
//                self.i += 1
//            }
//        }
//        else {
//            self.i = 0
//            self.animationPath = GMSMutablePath()
//            self.animationPolyline.map = nil
//            polyline?.map = map
//            timer?.invalidate()
//            timer = nil
//        }
//    }
    
}

extension ActiveOrderViewController {
    
    func needReviewPerformer(performer: OrderPerformer) {
        guard presentedViewController == nil else { return }
        guard let orderId = presentationModel.order.orderId else { return }
        OrdersRouter(presenter: self).presentReview(performer: performer,
                                                    orderId: orderId) { [weak self] (completed) in
            if completed {
                self?.closeCurrentOrder()
            }
        }
    }
    
    func communicate(performer: OrderPerformer?) {
        guard presentedViewController == nil else { return }
        guard let performer = performer else { return }
        ChatRouter(presenter: self).presentChat(performer: performer)
    }
    
    @IBAction func cancelOrder() {
        let reasons = ["Уже сделан заказ в другой компании",
                       "Указаны неверные параметры заказа",
                       "Передумали делать заказ",
                       "Заказ создан по ошибке",
                       "Не назначились исполнители"]
        let actionVC = UIAlertController(title: "Причина отмены заказа", message: nil, preferredStyle: .actionSheet)
        actionVC.view.tintColor = UIColor.blue_main
        reasons.forEach({ [weak self] title in
            let action = UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { [weak self] (_) in
                self?.presentationModel.cancelOrder(reason: title)
            })
            actionVC.addAction(action)
        })
        actionVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(actionVC, animated: true, completion: nil)
    }
    
    func orderCancelled() {
        guard !isClosing else { return }
        isClosing = true
        MainRouter(presenter: self).setMain(animated: true)
    }
    
    @IBAction func showOrderInfo() {
        let canCancelOrder = presentationModel.performers?.filter({ ($0.performer?.status.rawValue ?? 0) > 3 }).count == 0
        OrdersRouter(presenter: self).presentActiveOrder(order: presentationModel.order, canCancelOrder: canCancelOrder) { [weak self] in
            self?.presentationModel.cancelOrder(reason: $0)
        }
    }
}

//MARK: - Working with current order

extension ActiveOrderViewController {
    
    func animateToPerformer() {
        guard let bounds = presentationModel.order.routeData?.bounds else { return }
        var fit = GMSCoordinateBounds.init(coordinate: CLLocationCoordinate2D(latitude: bounds.southwest.lat, longitude: bounds.southwest.lng), coordinate: CLLocationCoordinate2D(latitude: bounds.northeast.lat, longitude: bounds.northeast.lng))
        guard let performerLocation = presentationModel.performers?.first?.performer?.coordinate else { return }
        fit = fit.includingCoordinate(performerLocation)
        map.animate(with: GMSCameraUpdate.fit(fit, withPadding: insetValue))
    }
    
    func handleOrderChanges() {
        if presentationModel.performers?.count == 0 {
            mapOverlay.isHidden = false
            searchingView.isHidden = false
            orderInfoButton.isHidden = true
            cancelOrderButton.isHidden = false
            presentationModel.getNearbyPerformers()
        } else {
            mapOverlay.isHidden = true
            searchingView.isHidden = true
            orderInfoButton.isHidden = false
            cancelOrderButton.isHidden = true
            updatePositions()
        }
    }
    
    func updatePositions() {
        guard let performers = presentationModel.performers else { return }
        let currentIds = performers.compactMap({ $0.performer != nil ? ($0.performer!.id, $0.performer!.type, $0.performer!.coordinate) : nil })
        relocateMarkers(markersInfo: currentIds, animated: true)
        markers.filter({ $0.iconView?.tag == self.selectedPerformer?.performer?.id }).first?.iconView?.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        if let selectedPerformer = performers.filter({ $0.performer?.id == selectedPerformer?.performer?.id }).first {
            performerView.setup(performer: selectedPerformer)
        }
    }
    
    func closeCurrentOrder() {
        if let performer = AvtoletService.shared.performersToReview.first {
            needReviewPerformer(performer: performer)
        } else if !isClosing {
            isClosing = true
            MainRouter(presenter: self).setMain(animated: true)
        }
    }
    
    func relocateMarkers(markersInfo: [(Int, PerformerType, CLLocationCoordinate2D)], animated: Bool) {
        let currentIds = markersInfo.map({ $0.0 })
        var newMarkers = [GMSMarker]()
        markers.forEach({ marker in
            if let tag = marker.iconView?.tag, currentIds.contains(tag) {
                newMarkers.append(marker)
            } else {
                marker.map = nil
            }
        })
        markersInfo.forEach { (info) in
            if let index = newMarkers.index(where: { $0.iconView?.tag == info.0 }) {
                let marker = newMarkers[index]
                if marker.position != info.2 {
                    CATransaction.begin()
                    CATransaction.setValue(animated ? 2.0 : 0.0, forKey: kCATransactionAnimationDuration)
                    marker.position = info.2
                    CATransaction.commit()
                }
            } else {
                let marker = GMSMarker(position: info.2)
                marker.iconView = {
                    let imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50.0, height: 50.0)))
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = info.1 == .driver ? #imageLiteral(resourceName: "driver") : #imageLiteral(resourceName: "clerk")
                    return imageView
                }()
                marker.iconView?.tag = info.0
                marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                marker.map = self.map
                newMarkers.append(marker)
            }
        }
        self.markers = newMarkers
    }
}

extension ActiveOrderViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        performerView.hide()
        showOrderInfoBtn()
        markers.forEach({ $0.iconView?.transform = .identity })
        selectedPerformer = nil
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        performerView.hide()
        showOrderInfoBtn()
        markers.forEach({ $0.iconView?.transform = .identity })
        selectedPerformer = nil
    }
    
    func showOrderInfoBtn() {
        orderInfoButton.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.orderInfoButton.alpha = 1.0
        })
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let tag = marker.iconView?.tag else { return false }
        guard let performer = presentationModel.performers?.filter({ $0.performer?.id == tag }).first else { return false }
        selectedPerformer = performer
        markers.forEach({ $0.iconView?.transform = .identity })
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            marker.iconView?.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        }, completion: nil)
        performerView.setup(performer: performer)
        performerView.show()
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.orderInfoButton.alpha = 0.0
        }) { [weak self] _ in
            self?.orderInfoButton.alpha = 0.0
            self?.orderInfoButton.isHidden = true
        }
        return true
    }
    
}
