//
//  GetHtmlVideoPageOperation.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

final class DownloadHtmlVideoPageOperation: GroupOperation {
	
	//MARK: Properties
	
	let cacheFile: URL
	
	//MARK: Initializer
	
	/// -parameter cacheFile: The file `URL` to wich  the earthquake feed will be downloaded.
	init(wwdcYear: WWDC, sessionNumber: String, cacheFile: URL) {
		self.cacheFile = cacheFile
		super.init(operations: [])
		name = "GetHtmlVideoPageOperation \(sessionNumber)"
		
		let url = URL(string: "https://developer.apple.com/videos/play/\(wwdcYear.stringValue)/" + sessionNumber + "/")!
		
		let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
			self.downloadFinished(url, response: response, error: error as NSError?)
			return()
		}
		
		let taskOperation = URLSessionTaskOperation(task: task)
		
		let reachabilityCondition = ReachabilityCondition(host: url)
		taskOperation.addCondition(reachabilityCondition)
		
		addOperation(taskOperation)
		
	}
	
	func downloadFinished(_ url: URL?, response: URLResponse?, error: NSError?) {
		if let localURL = url {
			do {
				/*
				If we already have a file at this location, just delete it.
				Also swallow the error, because we don't really care about it.
				*/
				try FileManager.default.removeItem(at: cacheFile)
			}
			catch { }
			
			do {
				try FileManager.default.moveItem(at: localURL, to: cacheFile)
			}
			catch let error as NSError {
				aggregateError(error)
			}
		}
		else if let error = error {
			aggregateError(error)
		}
		else {
			// Do nothing, and the operation will automatically finish.
		}
	}
	
}
