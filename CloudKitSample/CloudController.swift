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
	
	static func getID() -> Int {
		return 0
	}
	
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
	
	func saveDocument(document: Document) async {
		let documentRecord = CKRecord(recordType: "DocumentType2")

		// Seria legal saber o que o documento tem de variável não nil pra saber qual campo usar :thumbsup:
		
		documentRecord.setValue(document.data, forKey: "data")
		documentRecord.setValue(document.title, forKey: "title")
		documentRecord.setValue(Date.now, forKey: "createdAt")
		
		do {
			let savedRecord = try await publicDatabase.save(documentRecord)
			print(savedRecord)
		} catch {
			print("Error saving document: \(error)")
		}
	}
	
	func getAllDocuments() async -> [Document] {
		let query = CKQuery(recordType: "DocumentType2", predicate: NSPredicate(format: "TRUEPREDICATE"))
		
		query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
		
		do {
			let result = try await publicDatabase.records(matching: query)
			let records = result.matchResults.compactMap { $0.1.get }
			
//			return records.compactMap(Document.init)
			
			var documentList: [Document] = []
			
			for record in records {
				guard let document = Document(try record()) else { return [] }
				documentList.append(document)
			}
			return documentList
			
		} catch {
			print("Error converting document records: \(error)")
		}
		
		return []
	}
	
//	func saveDocumentDeleteURLs(document: Document, urls: [URL]) async {
//		print("Entered 2")
//		let documentRecord = CKRecord(recordType: "DocumentType")
//		print("Created record 2")
//		
//		documentRecord.setValue(document.images, forKey: "data")
//		documentRecord.setValue(document.title, forKey: "title")
//		print(documentRecord)
//		
//		do {
//			print("Will try to save 2")
//			let savedRecord = try await publicDatabase.save(documentRecord)
//			print(savedRecord)
//			print("Tried to save record :) 2")
//		} catch {
//			print("Error saving document: \(error)")
//		}
		
//		for url in urls {
//			do {
//				try FileManager.default.removeItem(at: url)
//			} catch {
//				print("Error deleting temp file: \(error)")
//			}
//		}
		
//	}
	
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
