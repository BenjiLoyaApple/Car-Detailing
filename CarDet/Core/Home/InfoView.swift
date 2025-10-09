//
//  InfoView.swift
//  XcodeReleases
//
//  Created by BenjiLoya on 25.09.2025.
//

import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Xcode Releases")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("More than you ever wanted to know™")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(
    """
    All downloads are hosted by Apple. Links on this site take you directly to Apple’s download pages.
    
    In suscipit aliquid. Sint iure adipisci corrupti labore consequatur dolor. Dolores corrupti voluptatum perferendis dolorem omnis ab qui sit distinctio. Est molestiae ipsum ab esse nulla et qui reprehenderit voluptatibus. Dolores odio ut.
    
    Deserunt aliquid asperiores et quos. Quae voluptas debitis deserunt. Inventore dolor non hic sunt quod ex molestias tempora. Quo corporis sapiente sapiente est. Ut explicabo ut blanditiis ea quibusdam.
    
    Alias sed dolor quia. Et doloribus sunt quaerat molestias aperiam magnam sunt. Qui sequi qui consectetur quo est est quo est et. Amet ut repellat.
    
    Itaque distinctio non ex. Libero nostrum tempore quaerat. Dolor odio fuga deleniti harum. Ut sequi aut aliquam laborum ipsum aut cum dignissimos. Sit illum ea dolores expedita ullam corporis et vitae. Doloribus molestiae ut ut voluptatem et suscipit.
    
    Et molestiae doloremque at in eveniet voluptatem architecto voluptatum. Enim et qui laudantium quasi tempore maxime alias laudantium. Repellat ut asperiores explicabo qui et. Repellendus repudiandae
    """
                    )
                }
            }
            .padding()
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    InfoView()
}
