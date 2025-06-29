import SwiftUI

struct CourseGrid: View {
    let paths: [LearningPath]
    var viewModel: AuthenticationViewModel
    @Binding var aura: Int
    var activate: () -> Void  // The function passed in to activate popover

    let colors: [Color] = [
        Color(red: 243/255, green: 205/255, blue: 205/255),
        Color(red: 197/255, green: 232/255, blue: 240/255),
        Color(red: 222/255, green: 215/255, blue: 247/255),
        Color(red: 255/255, green: 242/255, blue: 204/255),
        Color(red: 255/255, green: 242/255, blue: 204/255),
        Color(red: 222/255, green: 215/255, blue: 247/255),
        Color(red: 243/255, green: 205/255, blue: 205/255),
        Color(red: 208/255, green: 234/255, blue: 215/255)
    ]
    
    let icons = ["xmark", "globe", "character.book.closed", "doc.text", "doc.text", "e.circle", "xmark", "flask"]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(paths.indices, id: \.self) { index in
                NavigationLink(destination: LearningPathOverview(learningPath: paths[index], viewModel: viewModel, aura: $aura)) {
                    CourseCard(
                        title: paths[index].name,
                        subtitle: "\(paths[index].lessons.count) lessons",
                        color: colors[index % colors.count],
                        icon: icons[index % icons.count]
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            AddCourseCard(onTap: activate)
        }
    }
}

struct CourseCard: View {
    let title: String
    let subtitle: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
            }

            Spacer()

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(2)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.7))
        }
        .padding()
        .frame(width: 160, height: 160) // square shape
        .background(color)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct AddCourseCard: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.gray)
                .padding(12)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
        }
        .padding()
        .frame(width: 160, height: 160)
        .background(Color.gray.opacity(0.15)) // light gray background
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
