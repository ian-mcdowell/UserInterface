//
//  FeatureRequestsViewController.swift
//  UserInterface
//
//  Created by Ian McDowell on 1/23/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

public class FeatureRequestsViewController: PropertiesViewController {
    
    private var deviceID: String {
        return (UIDevice.current.identifierForVendor ?? UUID()).uuidString
    }
    
    fileprivate struct FeatureRequest: Decodable {
        let id: Int
        let title: String
        let description: String
        let want_count: Int
        let wants: Bool
    }
    
    private let baseURL: URL
    public init(baseURL: URL) {
        self.baseURL = baseURL
        super.init()
        
        self.title = "Request a Feature"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(compose))
        self.automaticallyAdjustsPreferredContentSize = false
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func loadProperties() -> Properties {
        return .deferred({ [unowned self] callback in
            self.loadCurrentRequests({ requests in
                callback([
                    PropertySection(
                        name: "User Requests",
                        items: requests.map { request in
                            return Property(
                                name: request.title,
                                value: request.description,
                                style: .subtitle,
                                customAccessoryView: {
                                    let label = UILabel()
                                    label.text = "♥ \(request.want_count)"
                                    label.textColor = request.wants ? .red : Theme.current?.tableCellTextColor
                                    label.onTap { [weak self] in
                                        self?.wantRequest(request)
                                    }
                                    label.sizeToFit()
                                    return label
                                }(),
                                valueMaxLines: 4
                            )
                        },
                        description: "The items above are submitted by users like you. Tap the heart to vote on features that you would like to see added to the app."
                    )
                ])
            })
        })
    }
    
    @objc private func compose() {
        let requestVC = FeatureRequestViewController(baseURL: self.baseURL, deviceID: self.deviceID)
        let nav = SONavigationController(rootViewController: requestVC)
        if let ourNav = self.navigationController {
            nav.modalPresentationStyle = ourNav.modalPresentationStyle
        }
        self.present(nav, animated: true, completion: nil)
    }
    
    private struct WantRequestBody: Encodable {
        let id: Int
    }
    
    private func wantRequest(_ request: FeatureRequest) {
        if request.wants { return }
        
        let body: Data
        do {
            let requestBody = WantRequestBody(id: request.id)
            body = try JSONEncoder().encode(requestBody)
        } catch {
            return self.showAlert("Request a Feature", text: "Error while encoding request. \(error.localizedDescription)")
        }
        
        self.progressHUD.show()
        
        var request = URLRequest(url: self.baseURL.appendingPathComponent("want"))
        request.httpMethod = "POST"
        request.addValue(self.deviceID, forHTTPHeaderField: "device-uuid")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.progressHUD.remove()
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    return self.showAlert("Request a Feature", text: "Unable to request feature at this time.")
                }
                
                self.reload()
            }
        }
        task.resume()
    }
    
    private func loadCurrentRequests(_ callback: @escaping (_ requests: [FeatureRequest]) -> Void) {
        var request = URLRequest(url: self.baseURL)
        request.addValue(self.deviceID, forHTTPHeaderField: "device-uuid")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    return self.showAlert("Feature Requests", text: "Unable to load feature requests at this time.")
                }
                
                do {
                    callback(try JSONDecoder().decode([FeatureRequest].self, from: data))
                } catch {
                    self.showAlert("Feature Requests", text: "Unable to retrieve feature requests. \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}
