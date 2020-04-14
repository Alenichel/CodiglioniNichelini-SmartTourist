//
//  MapView.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import UIKit
import Tempura
import PinLayout
import GoogleMaps


struct AttractionsViewModel: ViewModelWithLocalState {
    let places: [GPPlace]
    let location: CLLocationCoordinate2D?
    let actualLocation: CLLocationCoordinate2D?
    let city: String?
    let mapCentered: Bool
    let favorites: [GPPlace]
    let needToMoveMap: Bool
    let selectedSegmentedIndex: SelectedPlaceList
    let littleCircleRadius: Double
    let bigCircleRadius: Double
    
    init?(state: AppState?, localState: AttractionsLocalState) {
        guard let state = state else { return nil }
        self.selectedSegmentedIndex = localState.selectedSegmentIndex
        switch self.selectedSegmentedIndex {
        case .nearest:
            self.places = state.locationState.nearestPlaces
        case .popular:
            self.places = state.locationState.popularPlaces
        case .favorites:
            self.places = state.favorites
        }
        self.location = state.locationState.currentLocation
        self.actualLocation = state.locationState.actualLocation
        self.city = state.locationState.currentCity
        self.mapCentered = state.locationState.mapCentered
        self.favorites = state.favorites
        self.needToMoveMap = state.needToMoveMap
        self.littleCircleRadius = state.pedometerState.littleCircleRadius
        self.bigCircleRadius = state.pedometerState.bigCircleRadius
    }
}


enum CardState: Int {
    case expanded = 30
    case collapsed = 70
}


class MapView: UIView, ViewControllerModellableView {
    // MARK: Subviews
    var cityNameButton = UIButton()
    var mapView: GMSMapView!
    var locationButton = RoundedButton()
    var littleCircle = GMSCircle()
    var bigCircle = GMSCircle()
    var locationMarker = GMSCircle()
    var topBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light))
    var listCardView = ListCardView()
    var markerPool: GMSMarkerPool!
    var searchButton = RoundedButton()
    
    // MARK: - Interactions
    var didTapCityNameButton: Interaction?
    var didTapLocationButton: Interaction?
    var ditTapSearchButton: Interaction?
    var didMoveMap: Interaction?
    
    // Animator-related
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var cardState: CardState = .collapsed
    private var animator: UIViewPropertyAnimator?
    private var firstLayout = true
    
    // MARK: Setup
    func setup() {
        self.mapView = GMSMapView(frame: .zero)
        self.loadMapStyle()
        self.mapView.settings.compassButton = true
        self.mapView.settings.tiltGestures = false
        self.mapView.delegate = self.viewController as? AttractionsViewController
        self.locationButton.on(.touchUpInside) { button in
            self.didTapLocationButton?()
            self.centerMap()
        }
        self.searchButton.tintColor = .label
        self.searchButton.on(.touchUpInside) { button in
            self.ditTapSearchButton?()
        }
        
        self.cityNameButton.on(.touchUpInside) { button in
            self.didTapCityNameButton?()
        }
        self.markerPool = GMSMarkerPool(mapView: self.mapView)
        self.addSubview(self.mapView)
        self.addSubview(self.locationButton)
        self.addSubview(self.listCardView)
        self.addSubview(self.cityNameButton)
        self.addSubview(self.searchButton)
        self.addSubview(self.topBlurEffect)
        self.listCardView.setup()
        self.listCardView.style()
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        self.addGestureRecognizer(self.panGestureRecognizer)
        self.panGestureRecognizer.delegate = self
    }
    
    // MARK: Style
    func style() {
        self.backgroundColor = .systemBackground
        self.cityNameButton.setTitleColor(.label, for: .normal)
        self.cityNameButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.cityNameButton.contentHorizontalAlignment = .left
        self.locationButton.backgroundColor = .systemBackground
        self.locationButton.tintColor = .label
        self.locationButton.layer.cornerRadius = 20
        self.locationButton.layer.shadowColor = UIColor.black.cgColor
        self.locationButton.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.75
        self.locationButton.layer.shadowOffset = .zero
        self.locationButton.layer.shadowRadius = 4
        self.searchButton.backgroundColor = .systemBackground
        self.searchButton.layer.cornerRadius = 20
        self.searchButton.layer.shadowColor = UIColor.black.cgColor
        self.searchButton.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.75
        self.searchButton.layer.shadowOffset = .zero
        self.searchButton.layer.shadowRadius = 4
        self.searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    }
    
    // MARK: Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cityNameButton.sizeToFit()
        self.topBlurEffect.pin.top().left().right().bottom(94.5%)
        self.cityNameButton.pin.below(of: self.topBlurEffect).left(10)
        self.searchButton.pin.right(of: self.cityNameButton, aligned: .center).margin(2%).size(40)
        if self.firstLayout {
            self.layoutCardView(targetPercent: CardState.collapsed.rawValue%, layoutMap: true)
            self.firstLayout.toggle()
        }
    }
    
    func layoutCardView(targetPercent: Percent, layoutMap: Bool) {
        self.listCardView.pin.bottom().left().right().top(targetPercent)
        if layoutMap { self.layoutMapView(targetPercent: targetPercent) }
        let inversePercent = (100 - targetPercent.of(100) + 2)%
        self.locationButton.pin.bottom(inversePercent).right(4%).size(40)
        self.layoutIfNeeded()
    }
    
    func layoutMapView(targetPercent: Percent) {
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: targetPercent.of(self.frame.height))
    }
    
    // MARK: Update
    func update(oldModel: AttractionsViewModel?) {
        guard let model = self.model else { return }
        if self.mapView.camera.zoom >= 9 {
            self.markerPool.setMarkers(places: model.places)
            self.cityNameButton.isHidden = false
        } else {
            self.markerPool.setMarkers(places: [])
            self.cityNameButton.isHidden = true
        }
        let listCardViewModel = ListCardViewModel(currentLocation: model.location, places: model.places, favorites: model.favorites, selectedSegmentedIndex: model.selectedSegmentedIndex)
        self.listCardView.model = listCardViewModel
        self.locationButton.setImage(UIImage(systemName: model.mapCentered ? "location.fill" : "location"), for: .normal)
        if let location = model.location {
            self.mapView.isMyLocationEnabled = true
            self.locationMarker.position = location
            self.locationMarker.radius = 819200.0 * pow(2, -Double(self.mapView.camera.zoom))
            self.locationMarker.map = self.mapView
            if model.mapCentered {
                self.locationMarker.strokeColor = .clear
                self.locationMarker.fillColor = .clear
                self.centerMap()
            } else {
                self.locationMarker.strokeColor = .label
                self.locationMarker.fillColor = .label
            }
            if model.needToMoveMap {
                self.moveMap(to: location)
                self.didMoveMap?()
            }
        }
        if let actualLocation = model.actualLocation {
            self.littleCircle.position = actualLocation
            self.littleCircle.radius = model.littleCircleRadius
            self.bigCircle.position = actualLocation
            self.bigCircle.radius = model.bigCircleRadius
            self.littleCircle.strokeColor = .label
            self.bigCircle.strokeColor = .label
            self.littleCircle.map = self.mapView
            self.bigCircle.map = self.mapView
        }
        if let city = model.city {
            self.cityNameButton.setTitle(city, for: .normal)
        } else {
            self.cityNameButton.setTitle("SmartTourist", for: .normal)
        }
        self.setNeedsLayout()
    }
    
    private func moveMap(to location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15)
        self.mapView.animate(to: camera)
    }
    
    private func centerMap() {
        guard let model = self.model, let location = model.location else { return }
        self.moveMap(to: location)
    }
    
    private func loadMapStyle() {
        do {
            let style = UITraitCollection.current.userInterfaceStyle == .dark ? "mapStyle.dark" : "mapStyle"
            if let styleURL = Bundle.main.url(forResource: style, withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.loadMapStyle()
        self.topBlurEffect.effect = UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light)
    }
    
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            self.panningBegan()
        case .changed:
            let translation = recognizer.translation(in: self.superview)
            self.panningChanged(withTranslation: translation)
        case .ended:
            let translation = recognizer.translation(in: self.superview)
            let velocity = recognizer.velocity(in: self)
            self.panningEnded(withTranslation: translation, velocity: velocity)
        default:
            break
        }
    }
    
    private func panningBegan() {
        let cardState = self.cardState
        var targetPercent: Percent
        switch cardState {
        case .collapsed:
            targetPercent = CardState.expanded.rawValue%
        case .expanded:
            targetPercent = CardState.collapsed.rawValue%
        }
        self.animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: {
            switch cardState {
            case .collapsed:
                self.layoutCardView(targetPercent: targetPercent, layoutMap: false)
            case .expanded:
                self.layoutCardView(targetPercent: targetPercent, layoutMap: true)
            }
        })
    }
    
    private func panningChanged(withTranslation translation: CGPoint) {
        guard let animator = self.animator else { return }
        let translatedY = self.center.y + translation.y
        var progress: CGFloat
        switch self.cardState {
        case .collapsed:
            progress = 1 - (translatedY / self.center.y)
        case .expanded:
            progress = (translatedY / self.center.y) - 1
        }
        progress = max(0.001, min(0.999, progress))
        animator.fractionComplete = progress
    }
    
    private func panningEnded(withTranslation translation: CGPoint, velocity: CGPoint) {
        self.panGestureRecognizer.isEnabled = false
        let screenHeight = UIScreen.main.bounds.size.height
        switch self.cardState {
        case .collapsed:
            if translation.y <= -screenHeight / 3 || velocity.y <= -100 {
                self.animator?.isReversed = false
                self.animator?.addCompletion { [unowned self] _ in
                    self.cardState = .expanded
                    self.panGestureRecognizer.isEnabled = true
                    self.layoutMapView(targetPercent: self.cardState.rawValue%)
                    self.listCardView.attractionListView.isScrollEnabled = true
                }
            } else {
                self.animator?.isReversed = true
                self.animator?.addCompletion { [unowned self] _ in
                    self.cardState = .collapsed
                    self.panGestureRecognizer.isEnabled = true
                    self.layoutMapView(targetPercent: self.cardState.rawValue%)
                    self.listCardView.attractionListView.isScrollEnabled = false
                }
            }
        case .expanded:
            if translation.y >= screenHeight / 3 || velocity.y >= 100 {
                self.animator?.isReversed = false
                self.animator?.addCompletion { [unowned self] _ in
                    self.cardState = .collapsed
                    self.panGestureRecognizer.isEnabled = true
                    self.layoutMapView(targetPercent: self.cardState.rawValue%)
                    self.listCardView.attractionListView.isScrollEnabled = false
                }
            } else {
                self.animator?.isReversed = true
                self.animator?.addCompletion { [unowned self] _ in
                    self.cardState = .expanded
                    self.panGestureRecognizer.isEnabled = true
                    self.layoutMapView(targetPercent: self.cardState.rawValue%)
                    self.listCardView.attractionListView.isScrollEnabled = true
                }
            }
        }
        let velocityVector = CGVector(dx: velocity.x / 100, dy: velocity.y / 100)
        let springParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: velocityVector)
        self.animator?.continueAnimation(withTimingParameters: springParameters, durationFactor: 1.0)
    }
}


extension MapView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.cardState == .collapsed {
            self.listCardView.attractionListView.isScrollEnabled = false
        } else {
            let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            if panGestureRecognizer.velocity(in: self).y > 0 && self.listCardView.attractionListView.contentOffset.y <= 0 {
                self.listCardView.attractionListView.isScrollEnabled = false
                return true
            } else {
                self.listCardView.attractionListView.isScrollEnabled = true
            }
        }
        return false
    }
}
