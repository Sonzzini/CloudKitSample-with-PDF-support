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
			var cc: CloudController? = CloudController()
			let documents = await cc?.getAllDocuments()
			cc = nil
			
			let document = documents?.last!
			self.currentDocument = document
			
			if let pdfData = document?.bytes {
				let pdfDocument = PDFDocument(data: pdfData)
				self.pdfView.document = pdfDocument
			} else {
				if let asset = document?.data {
					guard let assetURL = asset.fileURL else { return }
					let pdfDocument = PDFDocument(url: assetURL)
					self.pdfView.document = pdfDocument
				}
			}
			
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
		guard
			let pdfURL = self.pdfView.document?.documentURL,
			let document = self.currentDocument
		else { return }
		
		var fc: FileController? = FileController()
		fc?.downloadPDF(pdfURL: pdfURL, document: document)
		fc = nil
		
//		let alert = UIAlertController(title: "PDF Salvo!", message: "O PDF pode ser encontrado na sua pasta de documentos.", preferredStyle: .alert)
//		alert.addAction(UIAlertAction(title: "Ok", style: .default))
//		self.present(alert, animated: true)
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
