//
//  ViewController.swift
//  Mapp
//
//  Created by Gabriel do Prado Moreira on 17/11/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
	
	private lazy var map: MKMapView = setupMap()
	private var locationButton: UIButton?
	
	let manager = CLLocationManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		map.delegate = self
		
		setupLocationButton()
		
		checkLocationEnabled()
	}
	
	func setupLocationButton() {
		let btn = UIButton()
		btn.backgroundColor = .systemRed
		btn.addTarget(self, action: #selector(goToCurrentLocation(sender:)), for: .touchUpInside)
		locationButton = btn
		
		view.addSubview(locationButton!)
		locationButton!.setDimensions(width: 40, height: 40)
		locationButton!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
		locationButton!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
		locationButton!.layer.zPosition = 1
	}
	
	func setupMap() -> MKMapView {
		let map = MKMapView()
		map.isScrollEnabled = true
		map.isZoomEnabled = true
		
		//reconhecedor de toques longos (pra fazer a adição de pins)
		let rec = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
		rec.isEnabled = true
		rec.delegate = self
		map.addGestureRecognizer(rec)
		
		view.addSubview(map)
		map.addMapConstraints(view)
		map.layer.zPosition = 0
		
		return map
	}
	
	//renderiza um lugar no mapa
	func render(location: CLLocation) {
				
		let coordinate = location.coordinate
		let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
		
		let region = MKCoordinateRegion(center: coordinate, span: span)
		map.setRegion(region, animated: true)
	
	}
	
	func checkLocationEnabled() {
		if CLLocationManager.locationServicesEnabled() {
			setupLocationManager()
			checkAuthorizationStatus()
			
		}
		else {
			// alertar usuario que os serviços de localização do dispositivo tão desligados
			print("dispositivo sem localização")
		}
	}
	
	//checa o tipo autorização de acordo
	func checkAuthorizationStatus() {
				
		switch manager.authorizationStatus {
			
		case .authorizedWhenInUse, .authorizedAlways:
			// atualizar posiçao do user
			map.showsUserLocation = true
			manager.startUpdatingLocation()
			
			guard let location = manager.location else {return}
			render(location: location)
			
		case .notDetermined:
			//pedir autorizaçao
			manager.requestWhenInUseAuthorization()
			
		case .denied:
			print("negado")
			
		case .restricted:
			print("restrito")
			
		@unknown default:
			print("não sabemos de nada")
		}
	}
	
	@objc func didLongPress(sender: UILongPressGestureRecognizer) {
			
		sender.isEnabled = false
		print("long press detected")
		let touchLocation = sender.location(in: map)
		let mapCoord = map.convert(touchLocation, toCoordinateFrom: map)
		
		let pin = MKPointAnnotation()
		pin.coordinate = mapCoord
		pin.title = "hey there"
		
		map.addAnnotation(pin)
		
		sender.isEnabled = true
	}
	
	@objc func goToCurrentLocation(sender: UIButton) {
		
		print("woooop")
		checkLocationEnabled()
		
	}
	
	//seta o location manager
	func setupLocationManager() {
		manager.delegate = self
		
		//mais settings...
	}
	
}

