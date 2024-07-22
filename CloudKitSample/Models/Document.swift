//
//  Document.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 18/07/24.
//

import Foundation
import CloudKit
import UIKit

class Document: Identifiable {
	let id = UUID()
	var data: CKAsset?
	var images: [CKAsset]?
	var title: String
	var record: CKRecord?
	var bytes: Data?

	init(pdfURL: URL, title: String) {
		let asset = CKAsset(fileURL: pdfURL)
		self.data = asset
		self.title = title
		self.record = nil
	}
	
	init?(URLS: [URL], title: String) {
		var assets: [CKAsset] = []
		for url in URLS {
			let asset = CKAsset(fileURL: url)
			assets.append(asset)
		}
		
		self.images = assets
		self.title = title
	}
	
	init?(images: [UIImage], title: String) {
		var imagesToBeSaved: [CKAsset] = []
		
		for image in images {
			let data = image.pngData()
			
			let randID = CloudController.getID()

			let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("PDFdocument\(randID)", conformingTo: .pdf)
			do {
				try data!.write(to: url!)
			} catch {
				print("Error! \(error)")
			}
			
			imagesToBeSaved.append(CKAsset(fileURL: url!))
			
//			do {
//				try FileManager.default.removeItem(at: url!)
//			} catch {
//				print("Error deleting temp file: \(error)")
//			}
		}
		print(imagesToBeSaved)
		
		self.images = imagesToBeSaved
		self.title = title
	}
	
	init?(asset: CKAsset, title: String) {
		self.data = asset
		self.title = title
		self.record = nil
	}
	
	init?(bytes: Data, title: String) {
		self.bytes = bytes
		self.title = title
		self.record = nil
		self.data = nil
	}
	
	init?(_ record: CKRecord) {
		guard
			let data = record[DocumentFields.data.rawValue] as? CKAsset,
			let title = record[DocumentFields.title.rawValue] as? String
		else { return nil }
		
		self.data = data
		self.title = title
		self.record = record
	}
}

enum DocumentFields: String {
	case data
	case title
}
