//
//  PermissionProblemView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 18/04/2025.
//

import SwiftUI

struct PermissionProblemView: View {
    let problem: AppPermissionProblem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: problem.imageName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(problem.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(problem.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Otwórz ustawienia", systemImage: "arrow.forward.circle.fill")
                    .font(.subheadline)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(BorderlessButtonStyle()) //bez tego, z jakiegoś powodu cała sekcja jest przyciskiem
        }
        .padding()
        .background(Color(.secondarySystemBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 4)
//        .padding(.horizontal)
    }
}

#Preview {
    PermissionProblemView(problem: .calendar)
}

enum AppPermissionProblem {
    case calendar
    case location

    var name: String {
        switch self {
        case .calendar: return "calendar"
        case .location: return "location"
        }
    }

    var title: String {
        switch self {
        case .calendar:
            return "Brak dostępu do kalendarza"
        case .location:
            return "Brak dostępu do lokalizacji"
        }
    }

    var description: String {
        switch self {
        case .calendar:
            return "Aplikacja nie ma dostępu do Twojego kalendarza. Dzięki temu mogłaby sprawdzać, dokąd się wybierasz i podpowiadać pogodę dla tych miejsc."
        case .location:
            return "Aplikacja nie ma dostępu do Twojej lokalizacji. Potrzebuje jej, aby wyświetlać aktualną pogodę dla Twojego miejsca."
        }
    }

    var imageName: String {
        switch self {
        case .calendar: return "calendar.badge.exclamationmark"
        case .location: return "location.slash.fill"
        }
    }
}
