//
//  ExperienceViewController.swift
//  ExperienceTracker
//
//  Created by Jonathan T. Miles on 10/19/18.
//  Copyright © 2018 Jonathan T. Miles. All rights reserved.
//

import UIKit
import MapKit
import Photos
import AVFoundation

class ExperienceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Buttons
    
    @IBAction func addPhotoImage(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        let isRecording = recorder?.isRecording ?? false
        if isRecording {
            recorder?.stop()
        } else {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
            recorder = try! AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.record()
        }
        updateViews()
    }
    
    @IBAction func next(_ sender: Any) {
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let returnedImage = info[.originalImage] as? UIImage else { return }
        
        
    
        imageView.image = image(byFiltering: returnedImage)
        updateImage()
        updateViews()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private func updateImage() {
        guard let originalImage = originalImage else { return }
        imageView.image = image(byFiltering: originalImage)
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        let isRecording = recorder?.isRecording ?? false
        let recordButtonTitle = isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
        
        if imageView.image != nil {
            addPhotoImageButton.setTitle("", for: .normal)
        }
    }
    
    private func image(byFiltering image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return originalImage }
        
        let ciImage = CIImage(cgImage: cgImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputCIImage = filter.outputImage,
            let outputCGIImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return nil
        }
        
        return UIImage(cgImage: outputCGIImage)
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! VideoViewController
        if let experienceController = experienceController,
            let experience = experience,
            let title = titleTextField.text,
            let image = imageView.image,
            let audioRecordingURL = recorder?.url {
            destVC.experience = experienceController.update(experience: experience, title: title, audioRecording: audioRecordingURL, videoRecording: nil, image: image)
            destVC.experienceController = experienceController
            
        }
    }
    
    
    // MARK: - Properties
    
    var experienceController: ExperienceController?
    var experience: Experience?
    
    private var originalImage: UIImage? //{
//        didSet {
//            updateImage()
//        }
 //   }
    
    private let filter = CIFilter(name: "CIPhotoEffectNoir")!
    private let context = CIContext(options: nil)
    
    private var recorder: AVAudioRecorder?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addPhotoImageButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            //imageView.image
        }
    }
    
}
