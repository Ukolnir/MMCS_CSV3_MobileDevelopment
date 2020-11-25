//
//  ViewController.swift
//  Chroma
//
//  Created by Ellone on 11.11.2020.
//  Copyright © 2020 Ukolnir. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var taped = false
    var lastPoint = CGPoint.zero
    var strokeWidth: CGFloat = 10.0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadImageView: UIImageView!
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let main = mainView {
            main.bringSubviewToFront(imageView)
        }
        imageView.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        taped = true
        if let touch = touches.first {
            lastPoint = touch.location(in: imageView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        taped = false
        if let touch = touches.first {
            let currentPoint = touch.location(in: imageView)
            drawLine(from: lastPoint, to: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if taped {
            drawLine(from: lastPoint, to: lastPoint)
        }
    }
    
    var isErase = false;
    
    @IBAction func eraseBut(_ sender: UIButton) {
        isErase = true
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint:CGPoint) {
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.image?.draw(in: CGRect(origin: CGPoint.zero, size: imageView.frame.size))
        
        if let context = UIGraphicsGetCurrentContext(){
            context.setLineWidth(strokeWidth)
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineCap(.round)
            //context.setJoinStyle = .round
            context.move(to: fromPoint)
            context.addLine(to: toPoint)
            
            if isErase {
                context.setBlendMode(.clear)
            } else {
                context.setBlendMode(.normal)
            }
            context.strokePath()
        }
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func merge() -> UIImage? {
        if let background = loadImageView.image ?? UIImage(), let top = imageView.image {
            let viewSize = loadImageView.frame.size
            let imageSize = background.size
            
            var ratio = imageSize.width / viewSize.width
            if imageSize.height > imageSize.width {
                ratio = imageSize.height / viewSize.height
            }
            let x = viewSize.width / 2 - imageSize.width / ratio / 2
            let y = viewSize.height / 2 - imageSize.height / ratio / 2
            let realSize = CGSize(width: imageSize.width / ratio, height: imageSize.height / ratio)
            
            UIGraphicsBeginImageContext(loadImageView.frame.size)
            
            let areaSize = CGRect(x: x, y: y, width: realSize.width, height: realSize.height)
            background.draw(in: areaSize)
            
            top.draw(in: CGRect(origin: CGPoint.zero, size: imageView.frame.size), blendMode: .normal, alpha: 1.0)
            
            let merged = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return merged
        }
        return nil
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        guard let image = merge() else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func loadImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        loadImageView.image = image
    }
    
    var strokeColor = UIColor.red
    
    @IBAction func changeColor(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            strokeColor = UIColor.red
        case 2:
            strokeColor = UIColor.systemYellow
        case 3:
            strokeColor = UIColor.yellow
        case 4:
            strokeColor = UIColor.init(red: 0.819, green: 1, blue: 0.184, alpha: 1)
        case 5:
            strokeColor = UIColor.systemGreen
        case 6:
            strokeColor = UIColor.systemTeal
        case 7:
            strokeColor = UIColor.systemBlue
        case 8:
            strokeColor = UIColor.systemPurple
        default:
            strokeColor = UIColor.black
        }
        isErase = false
    }
}
