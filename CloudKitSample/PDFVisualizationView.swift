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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
	}
	
	func setupUI() {
		setupGetPDFButton()
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
			let url = await documents().first?.data?.fileURL!
			let pdfDocument = PDFDocument(url: url!)
			self.pdfView.document = pdfDocument
		}
	}
	
	func setupPDFView() {
		self.view.addSubview(pdfView)
		
		NSLayoutConstraint.activate([
			pdfView.topAnchor.constraint(equalTo: getPDFButton.bottomAnchor),
			pdfView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			pdfView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
}
