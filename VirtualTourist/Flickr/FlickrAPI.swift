//
//  API.swift
//  VirtualTourist
//
//  Created by Maram Moh on 15/08/2020.
//  Copyright © 2020 Maram Moh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class API{
    
    static let shared = API()
    var session = URLSession.shared
    private var tasks: [String: URLSessionDataTask] = [:]
    
    
    
    func search(latitude: Double, longitude: Double, totalPages: Int?, completion: @escaping (_ result: Photo?, _ error: Error?) -> Void) {
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/10)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        let bbox = stringBbox(latitude: latitude, longitude: longitude)
        
        let prameter = []
        
        _ = getMethod(parameters: prameter) { (data, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "Could not retrieve data."]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
                return
            }
            
            do {
                let photosParser = try JSONDecoder().decode(Photo.self, from: data)
                completion(photosParser, nil)
            } catch {
                print("\(#function) error: \(error)")
                completion(nil, error)
            }
            
        }
    }
    func downloadImage(imageUrl: String,result: @escaping(_ result: Data?, _ error: NSError?) ->Void){
        guard let url = URL(string: imageUrl) else {
            return
        }
        let task = getMethod(nil, url, parameters: [:]) { (data, error) in
            result(data, error)
            self.tasks.removeValue(forKey: imageUrl)
        }
        
        if tasks[imageUrl] == nil {
            tasks[imageUrl] = task
        }
    }
    
    
    func stringBbox(latitude: Double,longitude: Double) -> String {
        let minLongitude = max(longitude - 0.2,-180.0,180.0)
        let minLatitude = max(latitude - 0.2,-90.0,90.0)
        let maxLongitude = min(longitude +  0.2,-180.0,180.0)
        let maxLatitude = min(latitude + 0.2, -90.0,90.0)
        return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }
    
    
    func getMethod(_ method : String? = nil,_ customUrl : URL? = nil,parameters : [String: String],
                   completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request: NSMutableURLRequest!
        if let customUrl = customUrl {
            request = NSMutableURLRequest(url: customUrl)
        } else {
            request = NSMutableURLRequest(url: getUrl(parameters, withPathExtension: method))
        }
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                if (error as NSError).code == URLError.cancelled.rawValue {
                    completionHandlerForGET(nil, nil)
                } else {
                    sendError(error.localizedDescription)
                }
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                sendError("error connection")
                return
            }
            
            guard let data = data else {
                sendError("No data")
                return
            }
            
            completionHandlerForGET(data, nil)
            
        }
        
        task.resume()
        
        return task
    }
}

private func getUrl(_ parameters: [String: String], withPathExtension: String? = nil) -> URL {
    
    var components = URLComponents()
    components.scheme = "http"
    components.host = "api.flickr.com"
    components.path = "/services/rest" + (withPathExtension ?? "")
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
        let queryItem = URLQueryItem(name: key, value: value)
        components.queryItems!.append(queryItem)
    }
    
    return components.url!
}


