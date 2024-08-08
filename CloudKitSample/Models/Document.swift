//
//  Document.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 18/07/24.
//

import Foundation
import CloudKit
import UIKit

class Document: Identifiable, Codable {
	
	enum CodingKeys: CodingKey {
		case imagePath
		case title
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		title = try container.decode(String.self, forKey: .title)
		imagePath = try container.decode(String.self, forKey: .imagePath)
	}
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(title, forKey: .title)
		try container.encode(imagePath, forKey: .imagePath)
	}
	
	let id = UUID()
	var data: CKAsset?
	var imagePath: String?
	var title: String
	var record: CKRecord?
	var bytes: Data?

//	init(pdfURL: URL, title: String, imagePath: String? = nil) {
//		let asset = CKAsset(fileURL: pdfURL)
//		self.data = asset
//		self.title = title
//		self.imagePath = imagePath
//		self.record = nil
//	}
	
	// MARK: Esse init é o que está sendo utilizado, os outros funcionaram para teste
	init?(asset: CKAsset, title: String) {
		self.data = asset
		self.title = title
		self.record = nil
	}
	
	init?(imagePath: String, title: String, data: Data? = nil) {
		self.imagePath = imagePath
		self.title = title
		self.bytes = data
	}
	
	// MARK: Esse também é utilizado para criar um Document a partir de uma CKRecord request do CloudKit
	init?(_ record: CKRecord) {
		guard
			let title = record[DocumentFields.title.rawValue] as? String
		else {
			print("Failed initializing")
			return nil
		}
		
		if let data = record[DocumentFields.data.rawValue] as? CKAsset {
			self.data = data
		}
		if let bytes = record[DocumentFields.bytes.rawValue] as? Data {
			self.bytes = bytes
		}
		
		self.title = title
		self.record = record
	}
}

enum DocumentFields: String {
	case data
	case title
	case bytes
}
