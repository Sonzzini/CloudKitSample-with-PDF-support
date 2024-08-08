//
//  CloudController.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 17/07/24.
//

import Foundation
import CloudKit
import SwiftUI
import CryptoKit

class CloudController: ObservableObject {
	
	let container: CKContainer
	let publicDatabase: CKDatabase
	
//	let key = SymmetricKey(size: .bits256)
	
	init() {
		container = CKContainer(identifier: "iCloud.com.PauloSonzzini.CloudKitSample.ExampleContainer") // Mesmo nome do contêiner
		publicDatabase = container.publicCloudDatabase
	}
	
	deinit {
		let byePhrases = ["Goodbye!", "See you next time!", "Until soon!", "See you later, alligator!"]
		print("CloudController says: \(byePhrases.randomElement()!)")
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
	
	func serialize<T: Codable>(object: T) -> Data? {
		do {
			let jsonData = try JSONEncoder().encode(object)
			return jsonData
		} catch {
			print("Error serializing object: \(error)")
			return nil
		}
	}
	
	func deserialize<T: Codable>(data: Data, as type: T.Type) -> T? {
		do {
			let object = try JSONDecoder().decode(T.self, from: data)
			return object
		} catch {
			print("Error deserializing data: \(error)")
			return nil
		}
	}
	
	func encrypt(data: Data, using key: SymmetricKey) -> Data? {
		do {
//			let sealedBox = try AES.GCM.seal(data, using: key)
			let sealedContent = try ChaChaPoly.seal(data, using: key).combined
			
			return sealedContent
		} catch {
			print("Error encrypting data: \(error)")
			return nil
		}
	}
	
	func decrypt(data: Data, using key: SymmetricKey) -> Data? {
		do {
//			let sealedBox = try AES.GCM.SealedBox(combined: data)
//			
//			let nonce = try AES.GCM.Nonce(data: data)
//			let tag = data[data.count - 16 ..< data.count]
//			
//			let sealedBBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: data, tag: tag)
//			return try AES.GCM.open(sealedBBox, using: key)
			let sealedBox = try ChaChaPoly.SealedBox(combined: data)
			let decryptedContent = try ChaChaPoly.open(sealedBox, using: key)
			return decryptedContent
		} catch {
			print("Error decrypting data: \(error)")
			return nil
		}
	}
	
	func saveDocument(document: Document) async {
		let documentRecord = CKRecord(recordType: "DocumentType2")

		// Seria legal saber o que o documento tem de variável não nil pra saber qual campo usar :thumbsup:
		
		// Comentário acima foi referente aos testes que estavam sendo realizados. O "Document" poderia possuir campos nil e era necessário realizar a manutenção das linhas de código seguintes
		if let data = document.data {
			documentRecord.setValue(data, forKey: "data")
		}
//		if let imagePath = document.imagePath {
//			documentRecord.setValue(imagePath, forKey: "imagePath")
//			document.record?.encryptedValues["document"] = CKAsset(fileURL: URL(fileURLWithPath: document.imagePath ?? "PATH"))
//			document.record?.encryptedValues["encryptedTitle"] = document.title
//		}
//		if let bytes = document.bytes {
//			documentRecord.setValue(bytes, forKey: "bytes")
//		}
		documentRecord.setValue(document.title, forKey: "title")
		documentRecord.setValue(Date.now, forKey: "createdAt")
		
//		let pair = await fetchID() // MARK: Era pra ser o valor que ia ser pareado com o da sua respectiva chave
//		documentRecord.encryptedValues["pair"] = pair
//		
//		let keyRecord = CKRecord(recordType: "Key")
//		keyRecord.encryptedValues["pair"] = pair
//		keyRecord.encryptedValues["key"] = key
		
		do {
			let savedRecord = try await publicDatabase.save(documentRecord)
			print(savedRecord.allKeys())
		} catch {
			print("Error saving document: \(error)")
		}
	}
	
//	func fetchID() async -> Int {
//		
//		func createMasterIDer() async {
//			let MasterRecord = CKRecord(recordType: "MasterIDer")
//			MasterRecord.setValue(0, forKey: "num")
//			
//			do {
//				let savedRecord = try await publicDatabase.save(MasterRecord)
//			} catch {
//				print("Error saving MasterRecord: \(error)")
//			}
//		}
//		
//		let query = CKQuery(recordType: "MasterIDer", predicate: NSPredicate(format: "TRUEPREDICATE"))
//		
//		do {
//			let result = try await publicDatabase.records(matching: query)
//			let records = try result.matchResults.compactMap { try $0.1.get() }
//			
//			if records.isEmpty {
//				await createMasterIDer()
//				return 0
//			} else {
//				let num = records.first?["num"] as! Int
//				records.first?.setValue(num+1, forKey: "num")
//				return num
//			}
//		} catch {
//			print("Error fetching ID: \(error)")
//		}
//		return 0
//	}
	
//	func secureSaveDocument(document: Document) async {
//		if let jsonData = serialize(object: document) {
//			if let encryptedData = encrypt(data: jsonData, using: self.key) {
//				let record = CKRecord(recordType: "DocumentType3")
//				record["encryptedData"] = encryptedData as CKRecordValue
//				
//				let fileURL = URL(filePath: document.imagePath!)
//				let asset = CKAsset(fileURL: fileURL)
//				record["file"] = asset
//				
//				do {
//					let savedRecord = try await publicDatabase.save(record)
//					print(savedRecord)
//				} catch {
//					print("Error secure saving: \(error)")
//				}
//			}
//		}
//	}
	
//	func secureGetAllDocuments() async -> [Document] {
//		let query = CKQuery(recordType: "DocumentType3", predicate: NSPredicate(format: "TRUEPREDICATE"))
//		
//		do {
//			let result = try await publicDatabase.records(matching: query)
//			let records = result.matchResults.compactMap { $0.1.get }
//			
//			var encryptedDataList: [Data] = []
//			
//			for record in records {
//				let rec = try record()
//				guard let data = rec["encryptedData"] as? Data else { return [] }
//				encryptedDataList.append(data)
//			}
//			
//			var decryptedDataList: [Data] = []
//			
//			for data in encryptedDataList {
//				if let decryptedData = decrypt(data: data, using: self.key) {
//					decryptedDataList.append(decryptedData)
//				}
//			}
//			
//			var deserializedDocumentList: [Document] = []
//			
//			for data in decryptedDataList {
//				if let deserializedDocument = deserialize(data: data, as: Document.self) {
//					print("DeserializedDocument: \(deserializedDocument)")
//					deserializedDocumentList.append(deserializedDocument)
//				}
//			}
//			
//			return deserializedDocumentList
//			
//			
//		} catch {
//			print("Error fetching secure documents: \(error)")
//		}
//		
//		return []
//	}
	
	func getAllDocuments() async -> [Document] {
		let query = CKQuery(recordType: "DocumentType2", predicate: NSPredicate(format: "TRUEPREDICATE"))
		
		query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		do {
			let result = try await publicDatabase.records(matching: query)
			let records = result.matchResults.compactMap { $0.1.get }
			
//			return records.compactMap(Document.init)
			
			var documentList: [Document] = []
			
			for record in records {
				guard let document = Document(try record()) else { return [] }
				documentList.append(document)
			}
			
			for document in documentList {
				print(document.title)
			}
			
			return documentList
			
		} catch {
			print("Error converting document records: \(error)")
		}
		
		return []
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
	
	func convert64EncodedToHex(_ data: Data) -> String {
		return data.map { String(format: "%02x", $0) }.joined()
	}
	
	// MARK: Função de exemplo.
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
