//
//  MainVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/21/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SideMenu
import Nominatim
import Alamofire

class MainVC: CommonViewController, UITextFieldDelegate, UISideMenuNavigationControllerDelegate, UIApplicationDelegate {
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var fromButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var payButton: UIButton!
  
    
    @IBOutlet var bottonView: UIView!{
        willSet{
             newValue.addSubview(payView)
        }
    }
    
    @IBOutlet var tariffView: UIView!
    @IBOutlet var tariffButton: UIButton!
    @IBOutlet var tariffImage: UIImageView!
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var paymentNameLabel: UILabel!
    @IBOutlet var chooseRate: UIButton!
    
    
    @IBOutlet var extraServiceView: UIView!
    @IBOutlet var extraServices: UIButton!
    let addressBuilder = AddressBuilder()
    var searchAddressUpdateHandler: (([SearchAddress]) -> ())?
    var userLocationUpdatedHandler: ((CLLocation) -> ())?
    var recalculateHandler: (() -> ())?
    let client = GMSPlacesClient.shared()
    
    var tariff: TariffPresentModel?
    
    var text = ""
    var count = Int()
    var addresses1 = [String]()
    
    let manager = AddressManager()
    lazy var locationService: LocationService = {
        let service = LocationService()
        service.delegate = self
        
        return service
    }()
    
    @IBOutlet var searchDriverView: UIView!
    @IBOutlet var mainBottonView: UIView!
    var locationDidObtained = false
    let coverView = UIView()
    
    var checkedExtraSevice: [Service]?
    @IBOutlet var bulletPoint: UIImageView!
    
    var toCoordinates: String?
    var destPoint: String?
    var departurePoint: String?
    var fromCoordinates: String?
    
    @IBOutlet var toButton: UIButton!
    let polyline = GMSPolyline()
    @IBOutlet var payView: UIView!
    var paymentMethod: PaymentMethod?
 
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationService.startTracking()
        
        setupMap()
        setupOrderInfo()
        self.hideKeyboard()
        restoreTrip()
    
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name:NSNotification.Name.UIApplicationWillTerminate , object: nil)
    }

    func restoreTrip() {
        if let dataMap = UserDefaults.standard.value(forKey:"mapData") as? Data {
            let mapData = try? PropertyListDecoder().decode(MapData.self, from: dataMap)
            fromButton.setTitle(mapData?.fromField, for: .normal)
            toButton.setTitle(mapData?.toField, for: .normal)
            
            if toButton!.titleLabel?.text != "Адрес, куда"{
                toButton.setTitleColor(.black, for: .normal)
            }
          
            fromCoordinates = mapData?.fromCoordinates
            toCoordinates = mapData?.toCoordinates
            UserDefaults.standard.removeObject(forKey: "mapData")
            
        }
        
        if let data = UserDefaults.standard.value(forKey:"tariff") as? Data {
            tariff = try? PropertyListDecoder().decode(TariffPresentModel.self, from: data)
            UserDefaults.standard.removeObject(forKey: "tariff")
            settingCoordinates()
            setTariffButton()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
       
        let dataMap = MapData(fromField: fromButton.titleLabel?.text ?? "",
                              toField: toButton!.titleLabel?.text ?? "",
                              fromCoordinates: fromCoordinates ?? "",
                              toCoordinates: toCoordinates ?? "")
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(dataMap), forKey:"mapData")
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(tariff), forKey:"tariff")
    }
    
    
    @IBAction func didTapFromButton(_ sender: UIButton) {
        let vc = storyboard!.instantiateViewController(withClass: DeparturePointVC.self)
        present(vc, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let data = UserDefaults.standard.value(forKey:"paymentMethod") as? Data {
            paymentMethod = try? PropertyListDecoder().decode(PaymentMethod.self, from: data)
            if let paymentType = paymentType(rawValue: paymentMethod!.id) {
                switch paymentType {
                case .cash:
                    paymentNameLabel.text = "Наличными"
                    paymentNameLabel.sizeToFit()
                    paymentNameLabel.frame = CGRect(x:26.25, y:12.25, width:87.5, height:19.5)
                    cardImage.image = UIImage()
                    break
                    
                case .cashless:
                    
                    cardImage.image = UIImage(imageLiteralResourceName: "mastercard")
                    paymentNameLabel.text = paymentMethod?.pan
                    paymentNameLabel.sizeToFit()
                    paymentNameLabel.frame = CGRect(x:54, y:12.25, width:87.5, height:19.5)
                    break
                    
                case .virtual:
                    paymentNameLabel.text = "Вирт. баланс"
                    
                    paymentNameLabel.sizeToFit()
                    paymentNameLabel.frame = CGRect(x:26.25, y:12.25, width:87.5, height:19.5)
                    cardImage.image = UIImage()
                    
                    break
                }
            }
            
            payView.frame = payButton.frame
      
            payButton.isHidden = true
            bottonView.bringSubview(toFront:payView)
            payView.isHidden = false
           
        }
        
    }
    
    
    
    func setTariffButton(){
        if tariff != nil {
            tariffView.frame = chooseRate.frame
            tariffButton.setTitle((tariff?.tariff_name)!, for: .normal)
            
            
            tariffImage.image = UIImage(imageLiteralResourceName: ((tariff?.tariff_name)!))
            
            chooseRate.isHidden = true
            bottonView.addSubview(tariffView)
        }
    }
    
    @objc func textDidChange (textField: UITextField){
        
        
        if count < (textField.text?.count)! {
            obtainAddresses(withText: textField.text!.capitalized)
            
        }
        count = (textField.text?.count)!
    }
    
    func updateUserAdress(latitude: Float, longitutde: Float) {
        guard let _ = locationService.currentUserLocation, text.isEmpty else { return }

        if latitude == 0.0 {return}
        
        Nominatim.getLocation(fromLatitude: String(latitude), longitude: String(longitutde), completion: {(error, location) -> Void in

            let street = location?.road?.replacingOccurrences(of: "улица", with: "ул.") ?? ""
            
            let house = location?.houseNumber ?? ""
            DispatchQueue.main.async {
                
                self.fromButton.setTitle(street + " д. " + house, for: .normal)
                self.fromButton.setTitleColor(.black, for: .normal)
                if street.isEmpty {
                    self.fromButton.setTitle("не могу найти адрес", for: .normal)
                }
                
            }
        })
        
    }
    
    func obtainAddresses(withText text: String) {
        
        self.text = text.trim()
        guard text.trim().count > 0 else { searchAddressUpdateHandler?([]) ; return }
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.address
        filter.country = "RU"
        let callback: GMSAutocompletePredictionsCallback = { [weak self] (results, _) in
            let addresses = results?.map({ SearchAddress(address: $0.attributedPrimaryText.string,
                                                         city: $0.attributedSecondaryText?.string) }) ?? []
            self?.searchAddressUpdateHandler?(addresses)
            self?.addresses1 = addresses.map { $0.query }
    
        }
        if let userlocation = locationService.currentUserLocation {
            client.autocompleteQuery(text, bounds: GMSCoordinateBounds(coordinate: userlocation.coordinate, coordinate: userlocation.coordinate), boundsMode: GMSAutocompleteBoundsMode.bias, filter: filter, callback: callback)
        } else {
            client.autocompleteQuery(text, bounds: nil, filter: filter, callback: callback)
        }
        
    }
    
    
    
    func setupOrderInfo() {}
    
    
    
    fileprivate lazy var presentationModel: FindAddressPresentationModel = { [unowned self] in
        let model = FindAddressPresentationModel() { [weak self] in
            self?.handleError($0)
        }
        model.loadingHandler = { [weak self] in
            $0 ? self?.showHUD() : self?.hideHUD()
        }
        model.addressChangedHandler = { [weak self] in
            self?.addressChanged(address: $0)
        }
        model.userLocationUpdatedHandler = { [weak self] in
            print("coordinate ", $0.coordinate)
            self?.placeMarker(coordinate: $0.coordinate)
            
        }
        return model
        }()
    
    func addressChanged(address: SearchAddress?) {
        if let address = address, !address.address.trim().isEmpty {
            fromButton.setTitle(address.address, for: .normal)
        }
        
    }
    @IBAction func unWindToMainVCFromTariff(_ sender: UIStoryboardSegue) {
        setTariffButton()
        extraServiceView.isHidden = false
        if self.tariff?.id != nil && self.toCoordinates != nil{
            self.settingCoordinates()
            
        }
    }
    
    
    
    @IBAction func unWindToMainVC(_ sender: UIStoryboardSegue) {
        
        if destPoint != nil {
            Nominatim.getLocation(fromAddress: destPoint!) { (location) in
                
                guard let locLatitude = location?.latitude else { return }
                guard let locLongitude = location?.longitude else { return }
                
                self.toCoordinates = String(locLatitude) + ", " + String(locLongitude)
                if self.tariff?.id != nil && self.toCoordinates != nil{
                    self.settingCoordinates()
                }
            }
          
            toButton.setTitle(destPoint!.components(separatedBy: ", ").dropLast().joined(separator: " "), for: .normal)
            toButton.setTitleColor(.black, for: .normal)
            
        }
        
        if departurePoint != nil {
            Nominatim.getLocation(fromAddress: departurePoint!) { (location) in
                
                guard let locLatitude = location?.latitude else { return }
                guard let locLongitude = location?.longitude else { return }
                
                self.fromCoordinates = String(locLatitude) + ", " + String(locLongitude)
                
            
                let camera = GMSCameraPosition.camera(withLatitude:  Double(locLatitude)!,
                                                      longitude: Double(locLongitude)!,
                                                      zoom: 17)
                DispatchQueue.main.async {
               self.mapView.animate(to: camera)
                }

            }
            fromButton.setTitle(departurePoint, for: .normal)
            
            fromButton.titleLabel?.textColor = .black
        }
        
    }
    
    
    func settingCoordinates() {
        if tariff?.id != nil && toCoordinates != nil{
            mapView.clear()

            NetworkRequests.shared.getRequest(url: host + getRouteFatePath + "?" + AvtoletService.shared.getToken(), parameters: ["origin":fromCoordinates!, "destination":toCoordinates!, "transportation_tariff_id":(tariff?.id)!]) { (response) in
                switch response.result{
                case .success(_):
                    do {
                        let routeFareResponse = try JSONDecoder().decode(RouteFareResponse.self, from: response.data!)
                        let routes = routeFareResponse.trip_cost.route_polyline
                        var locations = [CLLocation]()
                        
                        for route in routes {
                            locations.append(CLLocation(latitude: route.lat, longitude: route.long))
                        }
                        
                        self.showPath(locations: locations)
                        self.mapView.delegate = nil
                    
                    }
                    catch let error {print(error)}
                    
                    
                    break
                    
                case .failure(_):
                    break
                }
            }
        }
        
    }
    
    func showPath(locations: [CLLocation]){
        let path = GMSMutablePath()
  
        for location in locations {
            
            path.add(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        }
        
        polyline.path = path
        
        
        polyline.strokeWidth = 2.0
        polyline.geodesic = true
        polyline.strokeColor = UIColor(red: 254, green: 146, blue: 1)
        polyline.map = mapView // Your map view
        
        let startPoint = GMSMarker(position: CLLocationCoordinate2D(latitude: locations.first!.coordinate.latitude, longitude: locations.first!.coordinate.longitude))
        startPoint.icon = UIImage(imageLiteralResourceName: "startpoint")
        startPoint.map = mapView
        
        let endPoint = GMSMarker(position: CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude))
        endPoint.icon = UIImage(imageLiteralResourceName: "finish-flag")
        endPoint.map = mapView
        
        let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: locations.first!.coordinate.latitude, longitude: locations.first!.coordinate.longitude), coordinate: CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude))
        let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(180, 40, 40, 40))
        self.mapView!.moveCamera(update)
    }
    
    
    @IBAction func didTapToDestPoint(_ sender: UIButton) {
        let vc = storyboard!.instantiateViewController(withClass: DestinationPointVC.self)
        present(vc, animated: true, completion: nil)
        
    }
    @IBAction func choseRateClicked(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TariffVC") as! TariffVC

        present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - Side Menu
    
    @IBAction func sideMenuClicked(_ sender: UIButton) {
        
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {

        menuButton.titleLabel?.text = "angle-left"
        coverView.frame = CGRect(x:0, y:0, width: view.frame.width, height:view.frame.height)
        coverView.backgroundColor = .white
        coverView.alpha = 0.66
        view.addSubview(coverView)
        view.bringSubview(toFront: menuButton)
    }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        menuButton.titleLabel?.text = "bars"
        coverView.removeFromSuperview()
    }
    
    @IBAction func payClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Pay", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentMethodsVC") as! PaymentMethodsVC
        present(vc, animated: true, completion: nil)
     
    }
    
    
    
    @IBAction func additionalServiceClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Orders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AdditionalServicesVC") as! AdditionalServicesVC
        vc.transportation_tariffs_id = tariff!.id
        navigationController?.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func myLocationClicked(_ sender: UIButton) {
        mapView.animate(toLocation: (locationService.currentUserLocation?.coordinate)!)
        mapView.animate(toZoom: 16)
    }
    
    @IBAction func checkmarkClicked(_ sender: UIButton) {
        if isFieldsFilled(){
            if sender.titleLabel!.text == "check" {
                sender.setTitle("angle-down", for: .normal)
            }else{
                sender.setTitle("check", for: .normal)
            }
            
            
            var parameters = [String: Any]()
            var servicesIds = String()
            let cardId = paymentMethod!.cardId
            if let services = checkedExtraSevice{
                for service in services{
                    servicesIds = servicesIds + String(service.id) + ","
                    
                }
                
            }
            parameters = ["origin": fromCoordinates!,
                          "destination": toCoordinates ?? "",
                          "transportation_tariff_id" : tariff!.id,
                          "service_ids": servicesIds,
                          "payment_type": paymentMethod!.id,
                          "order_source": 1,
                          "card_id": cardId!
                
                
            ]
        
            print("param", parameters)
            print("tok", AvtoletService.shared.getToken())
            NetworkRequests.shared.postRequest(url: host + createOrderPath + "?" + AvtoletService.shared.getToken(), parameters: parameters) { (response) in
                print(response)
                self.searchDriverView.frame = CGRect(x: 0, y: 55, width: self.view.frame.size.width, height: 133)
                self.view.addSubview(self.searchDriverView)
                self.menuButton.isHidden = true
               
            }
        }
    }
    
    
    func getOrderInfo() {
        NetworkRequests.shared.getRequest(url: host + getOrderInfoPath + "?" + AvtoletService.shared.getToken(), parameters: [:]) { (resp) in
            
        }
    }
    
    @IBAction func didTapCancelOrder(_ sender: UIButton) {
       searchDriverView.removeFromSuperview()
        self.menuButton.isHidden = false
        mapView.delegate = self
        mapView.clear()
        
        
    }
    
    func isFieldsFilled() -> Bool {
        var badFields = [String]()
        if toCoordinates == nil {
            badFields.append("Куда")
        }
        if tariff?.id == nil{
            badFields.append("Тариф")
        }
        if paymentMethod?.id == nil{
            badFields.append("Оплату")
        }
        
        
        if badFields.count > 0 {
            let alert = UIAlertController(title: "Пожалуйста, заполните", message: badFields.joined(separator:", "), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }else{
            return true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        view.endEditing(true)
    }
    
}


extension MainVC: GMSMapViewDelegate, LocationServiceProtocol {
    
    func didFailAuthorization() {
        
    }
    
    
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude:  locationService.currentUserLocation?.coordinate.latitude ?? 0,
                                              longitude: locationService.currentUserLocation?.coordinate.longitude ?? 0,
                                              zoom: 16)
        
        
        self.mapView.camera = camera
        //        self.mapView.setMinZoom(12.0, maxZoom: 22.0)
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        mapView.padding = UIEdgeInsetsMake(0, 0, 120, 0)
        placeMarker(coordinate: NovosibirskCenterCoordinate.coordinate)
        
    }
    func userLocationUpdated(location: CLLocation) {
        placeMarker(coordinate: location.coordinate)
        mapView.animate(toZoom: 16.0)
    }
    
    
    func placeMarker(coordinate: CLLocationCoordinate2D) {
        mapView.animate(toLocation: coordinate)
    }
    
    func didUpdateUserLocation(location: CLLocation) {
        
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    
        fromCoordinates = String(position.target.latitude) + ", " + String(position.target.longitude)
    
        updateUserAdress(latitude: Float(position.target.latitude), longitutde: Float(position.target.longitude))
      
        presentationModel.obtainAddress(coordinate: position.target)
        
        
    }
}

public enum paymentType: Int {
    case cash = 1
    case cashless = 2
    case virtual = 3
    
}

struct MapData: Codable{
    let fromField: String
    let toField: String
    let fromCoordinates: String
    let toCoordinates: String
}
