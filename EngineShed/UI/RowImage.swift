//
//  RowImage.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/28/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct RowImage : View {

    var image: Image
    var width: CGFloat = 100

    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: width)
            .cornerRadius(4)
            .overlay(image
                .resizable()
                .aspectRatio(contentMode: .fit))
    }

}

#if DEBUG
struct RowImage_Previews : PreviewProvider {
    static var previews: some View {
        RowImage(image: Image("R3612"))
    }
}
#endif
