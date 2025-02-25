//
//  BackgroundView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 25/02/2025.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(colors: [
            Color(red: 0.541, green: 0.867, blue: 1),
            Color(red: 0.145, green: 0.475, blue: 1)
        ], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }
}
