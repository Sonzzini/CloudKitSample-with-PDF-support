//
//  CloudController.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 17/07/24.
//

import Foundation
import CloudKit
import SwiftUI

class CloudController: ObservableObject {
	
	let container: CKContainer
	let publicDatabase: CKDatabase
	
	init() {
		container = CKContainer(identifier: "iCloud.com.PauloSonzzini.CloudKitSample.ExampleContainer") // Mesmo nome do contêiner
		publicDatabase = container.publicCloudDatabase
	}
	
	func saveLamp(lamp: Lamp) async {
		let lampRecord = CKRecord(recordType: "Lamp")
		lampRecord.setValue(lamp.name, forKey: "name")
		lampRecord.setValue(lamp.price, forKey: "price")
		lampRecord.setValue(lamp.size, forKey: "size")
		
		do {
			let savedRecord = try await publicDatabase.save(lampRecord)
			lamp.record = savedRecord
		} catch {
			print("Error saving lamp: \(error)")
		}
		
	}
	
	func getAllLamps() async -> [Lamp]  {
		let query = CKQuery(recordType: "Lamp", predicate: NSPredicate(format: "TRUEPREDICATE"))
		
		query.sortDescriptors = [NSSortDescriptor(key: "price", ascending: true)]
		
		do {
			let result = try await publicDatabase.records(matching: query)
			let records = result.matchResults.compactMap { $0.1.get }
			
			//return records.compactMap(Lamp.init)
			
			var lampList: [Lamp] = []
			
			for record in records {
				guard let lamp = Lamp(try record()) else { return [] }
				lampList.append(lamp)
			}
			return lampList
			
		} catch {
			print("Error fetching lamps: \(error)")
		}
		
		return []
	}
	
	func deleteLamp(lamp: Lamp) async {
		do {
			guard let recordID = lamp.record?.recordID else { return }
			try await publicDatabase.deleteRecord(withID: recordID)
		} catch {
			print("Error deleting lamp: \(error)")
		}
	}
	
	func saveEmily() {
		let emilyRecord = CKRecord(recordType: "Emily")
		emilyRecord.setValue("Emily", forKey: "Nome")
		
		publicDatabase.save(emilyRecord) { record, error in
			if let error = error {
				print("Error saving Emily: \(error)")
			} else {
				print("Emily saved successfully!")
			}
		}
	}
}
