//
//  ContentView.swift
//  vImageScaleBug
//
//  Created by Yi Xie on 2021/9/26.
//

import SwiftUI
import Accelerate

struct ContentView: View {
    let srcWidth = 1000
    let srcHeight = 40
    let factors = Array(25...32)
    @State var images: [UIImage] = []
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<images.count, id: \.self) { i in
                Text(String(format: "%dx: %d*%d", factors[i], srcWidth * factors[i], srcHeight * factors[i]))
                    .foregroundColor(.white)
                Image(uiImage: images[i])
                    .resizable()
                    .scaledToFit()
                    .clipped()
            }
        }
        .background(Color.black)
        .onAppear {
            var srcBuffer = try! vImage_Buffer(width: srcWidth, height: srcHeight, bitsPerPixel: 32)
            var color: [UInt8] = [255, 255, 255, 255]
            vImageBufferFill_ARGB8888(&srcBuffer, &color, vImage_Flags(kvImageNoFlags))
            for factor in factors {
                var destBuffer = try! vImage_Buffer(width: Int(srcBuffer.width) * factor, height: Int(srcBuffer.height) * factor, bitsPerPixel: 32)
                vImageScale_ARGB8888(&srcBuffer, &destBuffer, nil, vImage_Flags(kvImageEdgeExtend))
                var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue))!
                var error: vImage_Error = kvImageNoError
                let cgImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, vImage_Flags(kvImageNoFlags), &error)!.takeRetainedValue()
                images.append(UIImage(cgImage: cgImage))
                destBuffer.free()
            }
            srcBuffer.free()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
