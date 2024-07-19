//
//  Lamp.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 17/07/24.
//

import Foundation
import CloudKit

class Lamp: Identifiable {
	let id = UUID()
	var name: String
	var price: Double
	var size: Int
	var record: CKRecord?
	
	init(name: String, price: Double, size: Int) {
		self.name = name
		self.price = price
		self.size = size
		self.record = nil
	}
	
	init?(_ record: CKRecord) {
		guard
			let name = record[LampFields.name.rawValue] as? String,
			let price = record[LampFields.price.rawValue] as? Double,
			let size = record[LampFields.size.rawValue] as? Int
		else { return nil }
		
		self.name = name
		self.price = price
		self.size = size
		self.record = record
	}
	
}

enum LampFields: String {
	case name
	case price
	case size
}
