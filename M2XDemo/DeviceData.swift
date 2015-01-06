//
//  DeviceData.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/11/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import UIKit

enum DeviceType : String {
    case Weight = "demo_weight"
    case Exercise = "demo_exercise"
    case Kick = "demo_kicks"
    case Glucose = "demo_glucose"
    
    static let allValues = [Weight, Exercise, Kick, Glucose]
}

enum StreamType : String {
    case Weight = "weight"
    case Exercise = "exercise"
    case Kick = "kicks"
    case Glucose = "glucose"
}

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        
        return String(format: hash)
    }
}

@objc class DeviceData: NSObject, M2XClientDelegate {
    init(fromCache: Bool) {
        super.init()
        self.fromCache = fromCache
    }
    
    convenience override init() {
        self.init(fromCache: true)
    }
    
    class var monthsMocked: Int {
        return 1;
    }

    var cacheData: Bool = false
    var fromCache: Bool = true // if offline mode
    
    let streamsByDevice = [
        DeviceType.Weight: StreamType.Weight,
        DeviceType.Exercise: StreamType.Exercise,
        DeviceType.Kick: StreamType.Kick,
        DeviceType.Glucose: StreamType.Glucose
    ]
    
    let paramsByStreams = [
        StreamType.Weight: ["unit": ["label": "pound", "symbol": "lb"], "type": "numeric"],
        StreamType.Exercise: ["unit": ["label": "minutes", "symbol": "min"], "type": "numeric"],
        StreamType.Kick: ["unit": ["label": "kicks", "symbol": "kick"], "type": "numeric"],
        StreamType.Glucose: ["unit": ["label": "mmol/L", "symbol": "mmol/L"], "type": "numeric"]
    ]
    
    let daysByStreams = [
        StreamType.Weight: [1, 7, 13, 19, 25],
        StreamType.Exercise: (1...30).map { $0 },
        StreamType.Glucose: (1...30).map { $0 },
    ]
    
    var client: M2XClient {
        var defaults = NSUserDefaults.standardUserDefaults()
        let key = defaults.valueForKey("key") as? String
        let client = M2XClient(apiKey: key!)
        if fromCache {
            client.delegate = self
        }
        return client
    }
    
    let apiDelay = 2.0 // since API is async we wait this time to assume data was created on the server
    
    // will create devices if needed
    func fetchDevice(type: String, completionHandler: (device: M2XDevice?, values: [AnyObject]?, lastResponse: M2XResponse) -> ()) {
        let enumType = DeviceType(rawValue: type)!
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.devices(enumType).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            let devices = task.result as [M2XDevice]
            
            return self.device(enumType, existingDevices: devices).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                let device = task.result as M2XDevice
                
                self.fillSamples(enumType, device: device, completionHandler: { (values: [AnyObject]?, response: M2XResponse) -> () in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completionHandler(device: device, values: values, lastResponse: response)
                })
                
                return nil
            })

        }.continueWithBlock { (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completionHandler(device: nil, values: nil, lastResponse: M2XResponse(response: nil, data: nil, error: task.error))
            }
            
            return nil
        }
    }

    func cacheAllData(completionHandler: M2XBaseCallback, progressHandler:(progress: Float) -> ()) {
        var value: Float = 0.0
        
        cacheAllData(completionHandler, progressHandler: progressHandler, progress: &value)
    }
    
    func cacheAllData(completionHandler: M2XBaseCallback, progressHandler:(progress: Float) -> (), inout progress: Float) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var count = 0
        let inc: Float = 0.125
        progressHandler(progress: 0)
        for deviceType in DeviceType.allValues {
            fetchDevice(deviceType.rawValue, completionHandler: { (device, values, lastResponse) -> () in
                count++
                progress +=  inc
                progressHandler(progress: min(1.0, progress))
                if count == DeviceType.allValues.count {
                    if self.cacheData {
                        self.cacheData = false
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        completionHandler(lastResponse)
                    } else {
                        // we finally do a re-call of the devices with CACHE mode on, since the first time some creation could have happened
                        self.cacheData = true
                        DeviceData.loadedDevicesByType.removeAllObjects()
                        self.cacheAllData(completionHandler, progressHandler: progressHandler, progress:&progress)
                    }
                }
            })
        }
    }
    
    func deleteAllData(completionHandler: M2XBaseCallback) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let noCacheClient = client
        noCacheClient.delegate = nil
        noCacheClient.devicesWithParameters(nil, completionHandler: { [weak self] (devices: [AnyObject]!, response: M2XResponse!) -> Void in
            if (response.error) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completionHandler(response)
                return
            }
            
            var existingDevices = [M2XDevice]()
            for deviceType in DeviceType.allValues {
                let device: M2XDevice? = self?.findDevice(deviceType, existingDevices: devices as [M2XDevice])
                
                if device != nil {
                    existingDevices.append(device!)
                }
            }
            
            var count = 0
            for device in existingDevices {
                let deviceId = device["id"] as String
                device.deleteWithCompletionHandler { (response: M2XResponse!) -> Void in
                    println("device \(deviceId) deleted")
                    
                    count++
                    if count == existingDevices.count {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        completionHandler(M2XResponse())
                    }
                }
            }

            if existingDevices.count == 0 {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completionHandler(M2XResponse())
            }
        })
    }
    
    func deleteCache() {
        var devices = DeviceData.loadedDevicesByType
        devices.removeAllObjects()
        
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let dir = paths[0] as String
        let manager = NSFileManager.defaultManager()
        let pathEnum = manager.enumeratorAtPath(dir)
        while let file = pathEnum?.nextObject() as NSString? {
            let path = dir.stringByAppendingPathComponent(file)
            var dir: ObjCBool = false
            if manager.fileExistsAtPath(path, isDirectory: &dir) {
                if !dir {
                    manager.removeItemAtPath(path, error: nil)
                }
            }
        }
    }
    
    private func fillSamples(type: DeviceType, device: M2XDevice, completionHandler: (values: [AnyObject]?, response: M2XResponse) -> ()) {
        let name = device["name"] as String
        var deviceEnum = DeviceType(rawValue: name)!
        
        let deviceId = device["id"] as String
        let streamType = streamsByDevice[deviceEnum]!
        let creationDays = daysByStreams[streamType]
        let params: [String: AnyObject] = ["limit": 1000]
        
        let stream = M2XStream(client: client, device: device, attributes: ["name": streamType.rawValue])
        
        stream.valuesWithParameters(params, completionHandler: { (objects: [AnyObject]!, valuesResponse: M2XResponse!) -> Void in
            if (valuesResponse.error) {
                completionHandler(values: [AnyObject](), response: valuesResponse)
                return
            }
            
            let dict = (valuesResponse.json as [String: AnyObject])
            let values = dict["values"] as [AnyObject]
            
            let sortBlock = { (values: [AnyObject]?) -> ([AnyObject]?) in
                if values != nil {
                    return Helper.sortValues(values);
                } else {
                    return values
                }
            }
            
            if let foundCreation = creationDays { // auto creation of values
                self.postMissingValues(type, streamType: streamType, existingValues: values, stream: stream, completionHandler: { (objects, response) -> () in
                    completionHandler(values: sortBlock(objects), response: valuesResponse)
                })
            } else {
                completionHandler(values: sortBlock(objects), response: valuesResponse)
            }
        })
    }
    
    private func postMissingValues(deviceType: DeviceType, streamType: StreamType, existingValues: [AnyObject], stream: M2XStream, completionHandler: ([AnyObject]?, response: M2XResponse) -> ()) {
        let days = daysByStreams[streamType]!
        var previousDates = createPreviousWeeks(DeviceData.monthsMocked * days.count, days: days)
        
        var missingValues = [AnyObject]()
        for value in existingValues {
            let date = NSDate.fromISO8601(value["timestamp"] as String)

            let index = find(previousDates, date)

            if index != nil {
                previousDates.removeAtIndex(index!)
            }
        }
        
        var value = 0.0
        if existingValues.count > 0 {
            value = existingValues[0]["value"] as Double // last value
        }

        let valueBlock = valuesByDevice[deviceType]!
        
        for val in valueBlock(dates: previousDates, startValue: value) {
            missingValues.append(val)
        }

        let updatedValues = missingValues + existingValues

        if missingValues.count > 0 {
            stream.postValues(missingValues, completionHandler: { (response: M2XResponse!) -> Void in
                completionHandler(updatedValues, response: response)
            })
        } else {
            completionHandler(updatedValues, response: M2XResponse())
        }
    }

    private func findDevice(type:DeviceType, existingDevices: [M2XDevice]) -> M2XDevice? {
        var foundDevice: M2XDevice? = nil
        for device in existingDevices {
            let deviceName = device["name"] as String
            if deviceName == type.rawValue {
                foundDevice = device
                break
            }
        }
        
        return foundDevice
    }

    private func fillDevice(type:DeviceType, existingDevices: [M2XDevice], completionHandler: (device: M2XDevice?, error: NSError?) -> ()) {
        var foundDevice: M2XDevice? = findDevice(type, existingDevices: existingDevices)

        let streamName = streamsByDevice[type]
        let streamParams = paramsByStreams[streamName!]
        
        if foundDevice == nil {
            let deviceDict = ["name": type.rawValue, "description": "m2x demo device", "visibility": "private"]

            M2XDevice.createWithClient(client, parameters: deviceDict) { (device: M2XDevice!, response: M2XResponse!) -> Void in
                self.createStreamDelayed(streamName!, device: device, parameters: streamParams!, completionHandler: { (streamResponse: M2XResponse!) -> Void in
                    completionHandler(device: device, error: streamResponse.errorObject)
                })
            }
        } else {
            self.createStreamDelayed(streamName!, device: foundDevice!, parameters: streamParams!, completionHandler: { (response: M2XResponse!) -> Void in
                completionHandler(device: foundDevice, error: response.errorObject)
            })
        }
    }
    
    private func createStreamDelayed(stream: StreamType, device: M2XDevice, parameters: NSDictionary, completionHandler: M2XBaseCallback) {
        self.dispatchDelayed {
            let stream = M2XStream(client: self.client, device: device, attributes: ["name": stream.rawValue])
            stream.updateWithParameters(parameters, completionHandler: { (object: M2XStream!, response: M2XResponse!) -> Void in
                completionHandler(M2XResponse())
            })
        }
    }
    
    private func dispatchDelayed(block: () -> Void) {
        let delay = isOffline() ? 0 : apiDelay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            block()
        }
    }
}

extension DeviceData {
    var valuesByDevice : [DeviceType: (dates: [NSDate], startValue: AnyObject) -> [AnyObject]] {
        get {
            return [ DeviceType.Weight: { (dates: [NSDate], startValue: AnyObject) -> [AnyObject] in
                let endReference = 7.7
                var value = startValue as Double
                var values = [AnyObject]()
                for date in dates.reverse() {
                    value += (endReference - value)/Double(DeviceData.monthsMocked * self.daysByStreams[.Weight]!.count)
                    value += endReference * 0.015 - (Double(arc4random()) % (endReference * 0.03))
                    value = max(0, value)
                    values.append(["timestamp": date.toISO8601(), "value": value])
                }
                
                return values
                },
                DeviceType.Exercise: { (dates: [NSDate], startValue: AnyObject) -> [AnyObject] in
                    let endReference = 30.0
                    var value = startValue as Double
                    var values = [AnyObject]()
                    for date in dates.reverse() {
                        value = endReference * 1.15 - ((Double(arc4random()) % endReference) * 0.3)
                        values.append(["timestamp": date.toISO8601(), "value": value])
                    }
                    
                    return values
                },
                DeviceType.Glucose: { (dates: [NSDate], startValue: AnyObject) -> [AnyObject] in
                    let endReference = 5.0
                    var value = startValue as Double
                    var values = [AnyObject]()
                    for date in dates.reverse() {
                        value = endReference * 1.05 - ((Double(arc4random()) % endReference) * 0.1)
                        values.append(["timestamp": date.toISO8601(), "value": value])
                    }
                    
                    return values
                }
            ]
        }
    }

}

extension DeviceData {
    private func createPreviousWeeks(amount: Int, days: [Int]) -> [NSDate] {
        let today = NSDate()
        var year = today.year()
        var month = today.month()
        
        var dates = [NSDate]()
        
        var loop = true
        while loop {
            for day in days.reverse() {
                let date = createDateFromComponents(day, month: month, year: year)
                if today.isLaterThanOrEqualTo(date) {
                    dates.append(date)
                    
                    if (dates.count == amount) {
                        loop = false
                        break
                    }
                }
            }
            
            month--
            if month == 0 {
                month = 12
                year--
            }
        }
        
        return dates
    }
    
    private func createDateFromComponents(day: Int, month: Int, year: Int) -> NSDate {
        var comp = NSDateComponents()
        if month == 2 && day == 29 {
            comp.day = day - 1
        } else {
            comp.day = day
        }
        comp.month = month
        comp.year = year
        comp.hour = 0
        comp.minute = 0
        
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return calendar.dateFromComponents(comp)!
    }
}

extension DeviceData {
    private func cachePathFor(request: NSURLRequest) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let dir = paths[0] as String
        let path = "\(dir)/\(request.URL.description.md5)"
        return path
    }
    
    func handleResponseWithData(data: NSData!, request: NSURLRequest!, response: NSHTTPURLResponse?, error: NSError!, completionHandler: M2XBaseCallback!) {
        if request.HTTPMethod != "GET" || !cacheData {
            let m2xResponse = M2XResponse(response: response, data: data, error: error)
            completionHandler(m2xResponse)
            return
        }
        
        let responseUrl = response?.URL? ?? NSURL()
        
        let manager = NSFileManager.defaultManager()
        let path = cachePathFor(request)
        if error == nil {
            manager.createFileAtPath(path, contents: data, attributes: nil)
        }
        
        let m2xResponse = M2XResponse(response: response, data: data, error: error)
        completionHandler(m2xResponse)
    }
    
    func handleRequest(request: NSURLRequest!, completionHandler: M2XResponseCallback!) {
        let cachedResponse = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: ["X-Cache": "HIT"])
        
        if request.HTTPMethod == "GET" {
            let manager = NSFileManager.defaultManager()
            let path = cachePathFor(request)
            
            let cachedData = manager.contentsAtPath(path)
            
            println("CACHE: using cached version of \(request.URL)")
            
            completionHandler(cachedData, cachedResponse, nil)
        } else {
            completionHandler(nil, cachedResponse, nil)
        }
    }
    
    func canHandleRequest(request: NSURLRequest!) -> Bool {
        let isGet = request.HTTPMethod == "GET"
        
        if isOffline() && !isGet {
            return true
        } else {
            let path = cachePathFor(request)
            
            let hasCache = NSFileManager.defaultManager().fileExistsAtPath(path)
            
            return hasCache && isOffline()
        }
    }
    
    func isOffline() -> Bool {
        var defaults = NSUserDefaults.standardUserDefaults()
        let manager = NSFileManager.defaultManager()
        let offlineSetting = defaults.valueForKey("offline") as? Bool
        let offline = offlineSetting != nil && offlineSetting!
        
        return offline
    }
}

extension DeviceData {
    struct Static {
        static var instance: NSMutableDictionary?
    }
    
    class var loadedDevicesByType: NSMutableDictionary {
        if Static.instance == nil {
            Static.instance = NSMutableDictionary()
        }
        
        return Static.instance!
    }
    
    func devices(deviceType: DeviceType) -> BFTask {
        var task = BFTaskCompletionSource()
        
        if let device = DeviceData.loadedDevicesByType[deviceType.rawValue] as? M2XDevice {
            task.setResult([device])
        } else {
            client.devicesWithParameters(["q": deviceType.rawValue], completionHandler: { (devices: [AnyObject]!, response: M2XResponse!) -> Void in
                if response.error {
                    task.setError(response.errorObject)
                } else {
                    task.setResult(devices)
                }
            })
        }
        
        return task.task
    }
    
    func device(deviceType: DeviceType, existingDevices: [M2XDevice]) -> BFTask {
        var task = BFTaskCompletionSource()
        
        if let device = DeviceData.loadedDevicesByType[deviceType.rawValue] as? M2XDevice {
            task.setResult(device)
        } else {
            self.fillDevice(deviceType, existingDevices: existingDevices, completionHandler: { (filledDevice: M2XDevice?, error: NSError?) -> () in
                if error != nil {
                    task.setError(error)
                } else {
                    var devices = DeviceData.loadedDevicesByType
                    devices.setValue(filledDevice, forKey: deviceType.rawValue)
                    task.setResult(filledDevice)
                }
            })
        }
        
        return task.task
    }
}
