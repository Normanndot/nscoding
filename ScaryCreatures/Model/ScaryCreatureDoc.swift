/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class ScaryCreatureDoc: NSObject {
  enum Keys: String {
    case dataFile = "Data.plist"
    case thumbImageFile = "thumbImage.png"
    case fullImageFile = "fullImage.png"
  }

  private var _data: ScaryCreatureData?
  var data: ScaryCreatureData? {
    get {
      // 1
      if _data != nil { return _data }

      // 2
      let dataURL = docPath!.appendingPathComponent(Keys.dataFile.rawValue)
      guard let codedData = try? Data(contentsOf: dataURL) else { return nil }

      // 3
      _data = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(codedData) as?
          ScaryCreatureData

      return _data
    }
    set {
      _data = newValue
    }
  }
  
  private var _thumbImage: UIImage?
  var thumbImage: UIImage? {
    get {
      if _thumbImage != nil { return _thumbImage }
      if docPath == nil { return nil }

      let thumbImageURL = docPath!.appendingPathComponent(Keys.thumbImageFile.rawValue)
      guard let imageData = try? Data(contentsOf: thumbImageURL) else { return nil }
      _thumbImage = UIImage(data: imageData)
      return _thumbImage
    }
    set {
      _thumbImage = newValue
    }
  }
  
  private var _fullImage: UIImage?
  var fullImage: UIImage? {
    get {
      if _fullImage != nil { return _fullImage }
      if docPath == nil { return nil }

      let fullImageURL = docPath!.appendingPathComponent(Keys.fullImageFile.rawValue)
      guard let imageData = try? Data(contentsOf: fullImageURL) else { return nil }
      _fullImage = UIImage(data: imageData)
      return _fullImage
    }
    set {
      _fullImage = newValue
    }
  }
 
  init(title: String, rating: Float, thumbImage: UIImage?, fullImage: UIImage?) {
    super.init()
    _data = ScaryCreatureData(title: title, rating: rating)
    self.thumbImage = thumbImage
    self.fullImage = fullImage
    saveData()
  }

  var docPath: URL?

  init(docPath: URL) {
    super.init()
    self.docPath = docPath
  }

  func createDataPath() throws {
    guard docPath == nil else { return }

    docPath = ScaryCreatureDatabase.nextScaryCreatureDocPath()
    try FileManager.default.createDirectory(at: docPath!,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
  }

  func saveData() {
    // 1
    guard let data = data else { return }

    // 2
    do {
      try createDataPath()
    } catch {
      print("Couldn't create save folder. " + error.localizedDescription)
      return
    }

    // 3
    let dataURL = docPath!.appendingPathComponent(Keys.dataFile.rawValue)

    // 4
    let codedData = try! NSKeyedArchiver.archivedData(withRootObject: data,
                                                      requiringSecureCoding: false)

    // 5
    do {
      try codedData.write(to: dataURL)
    } catch {
      print("Couldn't write to save file: " + error.localizedDescription)
    }
  }

  func deleteDoc() {
    if let docPath = docPath {
      do {
        try FileManager.default.removeItem(at: docPath)
      }catch {
        print("Error Deleting Folder. " + error.localizedDescription)
      }
    }
  }
}

class ScaryCreatureDatabase: NSObject {
  class func nextScaryCreatureDocPath() -> URL? {
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: privateDocsDir,
      includingPropertiesForKeys: nil,
      options: .skipsHiddenFiles) else { return nil }

    var maxNumber = 0

    // 2
    files.forEach {
      if $0.pathExtension == "scarycreature" {
        let fileName = $0.deletingPathExtension().lastPathComponent
        maxNumber = max(maxNumber, Int(fileName) ?? 0)
      }
    }

    // 3
    return privateDocsDir.appendingPathComponent(
      "\(maxNumber + 1).scarycreature",
      isDirectory: true)
  }

  static let privateDocsDir: URL = {
    // 1
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // 2
    let documentsDirectoryURL = paths.first!.appendingPathComponent("PrivateDocuments")

    // 3
    do {
      try FileManager.default.createDirectory(at: documentsDirectoryURL,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
    } catch {
      print("Couldn't create directory")
    }
    
    print(documentsDirectoryURL.absoluteString)
    return documentsDirectoryURL
  }()

  class func loadScaryCreatureDocs() -> [ScaryCreatureDoc] {
    // 1
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: privateDocsDir,
      includingPropertiesForKeys: nil,
      options: .skipsHiddenFiles) else { return [] }

    return files
      .filter { $0.pathExtension == "scarycreature" } // 2
      .map { ScaryCreatureDoc(docPath: $0) } // 3
  }
}
