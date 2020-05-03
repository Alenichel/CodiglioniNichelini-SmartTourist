//
//  MKMapView+image.swift
//  SmartTourist
//
//  Created on 03/05/2020
//

import MapKit
import Hydra


extension MKMapView {
    func screenshot() -> Promise<UIImage> {
        return Promise<UIImage>(in: .main) { resolve, reject, status in
            let options = MKMapSnapshotter.Options()
            options.region = self.region
            options.scale = UIScreen.main.scale
            options.size = self.frame.size
            options.pointOfInterestFilter = self.pointOfInterestFilter
            let snapshotter = MKMapSnapshotter(options: options)
            snapshotter.start(with: DispatchQueue.main) { (snapshot, error) in
                guard let snapshot = snapshot else {
                    reject(error!)
                    return
                }
                let image = snapshot.image
                UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
                image.draw(at: CGPoint.zero)
                let titleAttributes = self.titleAttributes()
                for annotation in self.annotations {
                    let point = snapshot.point(for: annotation.coordinate)
                    self.drawPin(point: point, annotation: annotation)
                    self.drawTitle(title: annotation.title!!, at: point, attributes: titleAttributes)
                }
                /*let visibleRect = CGRect(origin: CGPoint.zero, size: image.size)
                for annotation in self.annotations {
                    let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
                    var point = snapshot.point(for: annotation.coordinate)
                    if visibleRect.contains(point) {
                        point.x = point.x + marker.centerOffset.x - (marker.bounds.size.width / 2)
                        point.y = point.y + marker.centerOffset.y - (marker.bounds.size.height / 2)
                        if let markerImage = marker.image {
                            markerImage.draw(at: point)
                        } else {
                            marker.image = UIImage()
                            marker.image!.draw(at: point)
                        }
                    }
                }*/
                let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                guard let finalImage = compositeImage else {
                    reject(UnknownApiError())
                    return
                }
                resolve(finalImage)
            }
        }
    }
    
    private func drawTitle(title: String, at point: CGPoint, attributes: [NSAttributedString.Key: NSObject]) {
        let titleSize = title.size(withAttributes: attributes)
        title.draw(with: CGRect(
            x: point.x - titleSize.width / 2.0,
            y: point.y + 1,
            width: titleSize.width,
            height: titleSize.height),
                   options: .usesLineFragmentOrigin,
                   attributes: attributes,
                   context: nil)
    }

    private func titleAttributes() -> [NSAttributedString.Key: NSObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let titleFont = UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.75)
        let attrs = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        return attrs
    }

    private func drawPin(point: CGPoint, annotation: MKAnnotation) {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        annotationView.contentMode = .scaleAspectFit
        annotationView.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        annotationView.drawHierarchy(in: CGRect(
            x: point.x - annotationView.bounds.size.width / 2.0,
            y: point.y - annotationView.bounds.size.height,
            width: annotationView.bounds.width,
            height: annotationView.bounds.height),
                                     afterScreenUpdates: true)
    }
}
