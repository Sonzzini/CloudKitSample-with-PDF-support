//
//  PDFVisualizationView.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 22/07/24.
//

import Foundation
import UIKit
import PDFKit


class PDFVisualizationView: UIViewController, UIDocumentPickerDelegate {
	
	let cc = CloudController()
	var currentDocument: Document? = nil
	
	let pdfView: PDFView = {
		let view = PDFView(frame: .zero)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.autoScales = true
		
		return view
	}()
	
	let getPDFButton: UIButton = {
		let button = UIButton()
		
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Get PDF", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = .white
		
		return button
	}()
	
	let downloadPDFButton: UIButton = {
		let button = UIButton()
		
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Download PDF", for: .normal)
		button.setTitleColor(.blue, for: .normal)
		button.backgroundColor = .cyan
		
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
	}
	
	func setupUI() {
		setupGetPDFButton()
		setupDownloadButton()
		setupPDFView()
	}
	
	func setupGetPDFButton() {
		self.view.addSubview(getPDFButton)
		
		getPDFButton.addTarget(self, action: #selector(getPDF), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			getPDFButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			getPDFButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
		])
	}
	
	@objc func getPDF() {
		Task {
			let documents = cc.getAllDocuments
			let document = await documents().last! // MARK: NÃo faço ideia do porque eu preciso chamar documents em "documents()"
			self.currentDocument = document
			print(currentDocument?.title)
			let url = document.data?.fileURL!
			let pdfDocument = PDFDocument(url: url!)
			self.pdfView.document = pdfDocument
		}
	}
	
	func setupDownloadButton() {
		self.view.addSubview(downloadPDFButton)
		
		downloadPDFButton.addTarget(self, action: #selector(didDownloadPDF), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			downloadPDFButton.topAnchor.constraint(equalTo: getPDFButton.bottomAnchor),
			downloadPDFButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
		])
	}
	
	@objc func didDownloadPDF() {
//		ShareLink em SwiftUI
		if let pdfURL = self.pdfView.document?.documentURL {
			let fileManager = FileManager.default
			
			DispatchQueue.main.async {
				let pdfData = try? Data.init(contentsOf: pdfURL)
				let resourceDocPath = (fileManager.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
				
				
				var pdfNameFromURL = "Document-\(self.currentDocument?.title ?? "YourDocument")"
				var actualPath = resourceDocPath.appendingPathComponent(pdfNameFromURL+".pdf")
				var num = 1

				print(fileManager.fileExists(atPath: actualPath.path()))

				
				while fileManager.fileExists(atPath: actualPath.path()) {

					if pdfNameFromURL.hasSuffix(")") {
						pdfNameFromURL.removeLast()
						pdfNameFromURL.removeLast()
						pdfNameFromURL.removeLast()
						pdfNameFromURL.append("(\(num))")
					} else {
						pdfNameFromURL.append("(\(num))")
					}
					
					actualPath = resourceDocPath.appendingPathComponent(pdfNameFromURL+".pdf")
					print(actualPath)
					num += 1
				}
				
				do {
					
					
					try pdfData?.write(to: actualPath, options: [.atomic])
					
					// MARK: abre o aplicativo Files
//					let path = self.getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
//					let documentURL = URL(string: path)!
//
//					UIApplication.shared.open(documentURL)
					
					let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
					let docURL = NSURL(fileURLWithPath: docPath)
					
					if let pathComponent = docURL.appendingPathComponent("Document-\(self.currentDocument?.title ?? "YourDocument").pdf") {
						let filePath = pathComponent.path
						
						if fileManager.fileExists(atPath: filePath) {
							print("FILE AVAILABLE")
							print("PDF successfully saved!")
							
							let alert = UIAlertController(title: "PDF Salvo!", message: "O PDF pode ser encontrado na sua pasta de documentos.", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Ok", style: .default))
							self.present(alert, animated: true)
							
						} else {
							print("FILE NOT AVAILABLE")
						}
					} else {
						print("FILE PATH NOT AVAILABLE")
					}
				} catch {
					print("PDF could not be saved :(")
				}
			}
		}
		else {
			print("PDF could not be found!")
		}
	}
	
	func setupPDFView() {
		self.view.addSubview(pdfView)
		
		NSLayoutConstraint.activate([
			pdfView.topAnchor.constraint(equalTo: downloadPDFButton.bottomAnchor),
			pdfView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			pdfView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
}

extension PDFVisualizationView {
	func getDocumentsDirectory() -> URL {  // Devolve a sua pasta de documents da aplicação
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}
