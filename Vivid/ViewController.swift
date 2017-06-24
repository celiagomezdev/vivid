//
//  ViewController.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 23/06/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    
    var googleMap: GMSMapView?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: 52.520736, longitude: 13.409423, zoom: 12)
        googleMap = GMSMapView.map(withFrame: mapView.frame, camera: camera)
        self.mapView = googleMap
        self.view.addSubview(mapView!)
        
        let initialLocation = CLLocationCoordinate2DMake(52.520736, 13.409423)
        let marker = GMSMarker(position: initialLocation)
        marker.title = "Berlin"
        marker.map = mapView
        
    }

    
    @IBAction func search(_ sender: Any) {

    }
 }

