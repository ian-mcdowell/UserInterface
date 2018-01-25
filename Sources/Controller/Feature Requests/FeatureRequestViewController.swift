//
//  FeatureRequestViewController.swift
//  UserInterface
//
//  Created by Ian McDowell on 1/23/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

class FeatureRequestViewController: PropertiesViewController {
    
    let baseURL: URL
    let deviceID: String
    
    init(baseURL: URL, deviceID: String) {
        self.baseURL = baseURL
        self.deviceID = deviceID
        super.init()
        
        self.automaticallyAdjustsPreferredContentSize = false
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feature Request"
        self.addCloseButtonIfNeeded()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submit))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.property(withID: "title")?.activate()
    }
    
    override func loadProperties() -> Properties {
        return .properties([
            PropertySection(
                name: "Title",
                items: [
                    TextProperty(ID: "title", name: "My awesome feature idea")
                ]
            ),
            PropertySection(
                name: "Description",
                items: [
                    TextProperty(ID: "description", name: "Some additional information")
                ]
            )
        ])
    }
    
    private struct RequestBody: Encodable {
        let title: String
        let description: String
    }
    
    @objc private func submit() {
        guard let title = self.property(withID: "title")?.value, let description = self.property(withID: "description")?.value, !title.isEmpty, !description.isEmpty else {
            return self.showAlert("Required Fields", text: "Please enter a title and description.")
        }
        
        guard title.count <= 64 else {
            return self.showAlert("Title", text: "The title must be 64 characters or less. It's currently \(title.count) characters.")
        }
        guard description.count <= 256 else {
            return self.showAlert("Description", text: "The description must be 256 characters or less. It's currently \(description.count) characters.")
        }
        
        let body: Data
        do {
            let requestBody = RequestBody(title: title, description: description)
            body = try JSONEncoder().encode(requestBody)
        } catch {
            return self.showAlert("Request a Feature", text: "Error while encoding request. \(error.localizedDescription)")
        }
        
        self.progressHUD.text = "Adding request..."
        self.progressHUD.show()
        
        var request = URLRequest(url: self.baseURL.appendingPathComponent("request"))
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
                
                self.closeOrGoBack()
            }
        }
        task.resume()
    }
}
