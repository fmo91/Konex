//
//  NetworkLogger.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation

public extension KonexComponent {
    
    public struct NetworkLogger: KonexPlugin {
        
        private static func JSONStringify(_ value: AnyObject,prettyPrinted:Bool = false) -> String{
            
            let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
            
            
            if JSONSerialization.isValidJSONObject(value) {
                
                do{
                    let data = try JSONSerialization.data(withJSONObject: value, options: options)
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        return string as String
                    }
                } catch {
                    
                    print("error")
                    //Access error here
                }
                
            }
            return ""
        }
        
        private static func getPrintableJSON(_ json: AnyObject) -> NSString {
            return JSONStringify(json, prettyPrinted: true) as NSString
        }
        
        public init() {}
        
        public func didReceiveResponse(_ response: Any, from request: KonexRequest) {
            print("--------------------")
            print("Did receive response from \(request.finalPath):")
            print("\(NetworkLogger.getPrintableJSON(response as AnyObject))")
            print("--------------------")
        }
        
        public func didSendRequest(_ request: KonexRequest) {
            print("--------------------")
            print("Did send a request to \(request.finalPath)")
            print("")
            print("Method: \(request.method.rawValue)")
            if let parameters = request.parameters {
                print("Parameters:")
                print("\(NetworkLogger.getPrintableJSON(request.parameters as AnyObject))")
            }
            if let headers = request.headers {
                print("Headers:")
                print("\(NetworkLogger.getPrintableJSON(request.parameters as AnyObject))")
            }
            print("--------------------")
        }
        
    }
    
}
