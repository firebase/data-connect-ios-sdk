//
//  GradientView.swift
//  FriendlyFlix
//
//  Created by Peter Friese on 28.08.24.
//  Copyright © 2024 Google LLC. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

let neonSunsetBlurb =
  """
  Immerse yourself in the captivating allure of Neon Sunset, a mesmerizing gradient that seamlessly blends the warmth of daylight with the electric energy of the night. This vibrant spectrum captures the fleeting magic of twilight, where the sun dips below the horizon, painting the sky with a kaleidoscope of fiery oranges, deep pinks, and electrifying purples.

  Neon Sunset is not merely a color scheme; it's an experience. It evokes a sense of wonder, igniting the imagination and transporting you to a world where boundaries blur and possibilities abound. Whether you're designing a website, creating artwork, or simply seeking a visual feast for the eyes, Neon Sunset will infuse your projects with an undeniable vibrancy and modern flair.

  Embrace the dynamism of this gradient, as it effortlessly transitions from warm to cool tones. Let the radiant oranges and yellows awaken your creativity, while the deep purples and pinks add a touch of mystery and intrigue. Neon Sunset is a versatile tool that can be adapted to suit a wide range of styles and moods, making it an essential addition to any designer's toolkit.

  Unleash the power of Neon Sunset and watch your creations come alive with a captivating energy that is both bold and sophisticated. This gradient is more than just a visual element; it's a statement. It embodies a spirit of innovation, a celebration of individuality, and a passion for pushing boundaries.

  So, step into the world of Neon Sunset and let your imagination soar. Embrace the vibrant hues, the seamless transitions, and the electrifying energy. Discover a gradient that will elevate your designs, captivate your audience, and leave a lasting impression.
  """

let prismaticDawnBlurb =
  """
  Prismatic Dawn is an enchanting gradient that captures the ephemeral beauty of sunrise, where the first rays of light kiss the horizon and transform the world into a canvas of vibrant hues. This captivating spectrum evokes a sense of wonder, joy, and limitless possibilities.

  Immerse yourself in the mesmerizing blend of soft pastels and bold primary colors. Let the gentle pinks, blues, and purples soothe your senses, while the fiery oranges and yellows ignite your creativity. Prismatic Dawn is a celebration of diversity and harmony, where each color plays a vital role in creating a symphony of light and energy.

  Embrace the fluidity of this gradient, as it seamlessly transitions from delicate shades to vivid bursts of brilliance. Whether you're designing a website, crafting artwork, or simply seeking visual inspiration, Prismatic Dawn will infuse your projects with an undeniable charm and optimism.

  Unleash the power of Prismatic Dawn and watch your creations radiate with a captivating energy that is both playful and sophisticated. This gradient is more than just a visual element; it's an invitation to embrace the magic of color and the boundless potential of creativity.

  Step into the world of Prismatic Dawn and let your imagination dance with light. Explore the harmonious blend of hues, the gentle transitions, and the vibrant energy. Discover a gradient that will elevate your designs, inspire your audience, and leave a lasting impression.
  """

let serenityDuskBlurb =
  """
  Serenity Dusk is a captivating gradient that captures the peaceful transition between day and night. This mesmerizing blend of soft blues and warm pinks evokes a sense of tranquility, introspection, and gentle beauty.

  Immerse yourself in the calming embrace of this gradient, as it seamlessly blends cool and warm tones. Let the soothing blues wash over you, while the delicate pinks awaken a sense of hope and optimism. Serenity Dusk is a celebration of balance and harmony, where opposing forces come together to create a breathtaking visual experience.

  Embrace the subtlety of this gradient, as it gently shifts from one hue to another. Whether you're designing a website, crafting artwork, or simply seeking a moment of visual respite, Serenity Dusk will infuse your projects with a sense of peace and tranquility.

  Unleash the power of Serenity Dusk and watch your creations radiate with a captivating energy that is both calming and uplifting. This gradient is more than just a visual element; it's an invitation to embrace the beauty of stillness and the transformative power of color.

  Step into the world of Serenity Dusk and let your senses be enveloped by its gentle embrace. Explore the harmonious blend of hues, the soft transitions, and the subtle vibrancy. Discover a gradient that will elevate your designs, inspire your audience, and leave a lasting impression of serenity and beauty.
  """

struct GradienConfiguration: Identifiable, Hashable {
  let id = UUID().uuidString
  let name: String
  let tagLine: String
  let subLine: String
  let description: String
  let points: [SIMD2<Float>]
  let colors: [Color]
}

extension GradienConfiguration {
  var dimension: Int {
    Int(Double(points.count).squareRoot())
  }

  static let samples: [Self] = [
    .init(
      name: "Prismatic Dawn",
      tagLine: "Where Light Dances with Color",
      subLine: "Vivid, eye-catching, modern design.",
      description: neonSunsetBlurb,
      points: [
        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
        [0.0, 0.5], [0.6, 0.5], [1.0, 0.5],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0],
      ],
      colors: [
        .red, .purple, .indigo,
        .orange, .white, .blue,
        .yellow, .green, .mint,
      ]
    ),
    .init(
      name: "Neon Sunset",
      tagLine: "Where the Day Meets the Night",
      subLine: "Playful, vibrant, and energetic.",
      description: prismaticDawnBlurb,
      points: [
        [0.0, 0.0], [1.0, 0.0],
        [0.0, 1.0], [1.0, 1.0],
      ],
      colors: [
        .red, .indigo,
        .yellow, .blue,
      ]
    ),
    .init(
      name: "Serenity Dusk",
      tagLine: "Where tranquility meets vibrancy",
      subLine: "Embrace the calming hues of twilight.",
      description: serenityDuskBlurb,
      points: [
        [0.0, 0.0], [1.0, 0.0],
        [0.0, 1.0], [1.0, 1.0],
      ],
      colors: [
        Color(hex: "#5a82e5"), Color(hex: "#ce6a7e"),
        Color(hex: "#5084e9"), Color(hex: "#d66871"),
      ]
    ),
  ]

  static let sample = Self.samples[0]
}

struct GradientView: View {
  var configuration: GradienConfiguration
  @State private var isAnimating = false
  var body: some View {
    VStack {
      if #available(iOS 18, macOS 15, tvOS 18, watchOS 11, *) {
        MeshGradient(
          width: configuration.dimension,
          height: configuration.dimension,
          points: configuration.points,
          colors: configuration.colors,
          smoothsColors: true,
          colorSpace: .perceptual
        )
      } else {
        EllipticalGradient(colors: configuration.colors)
      }
    }
    .ignoresSafeArea()
    .onAppear {
      withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
        isAnimating.toggle()
      }
    }
  }
}

#Preview {
  GradientView(configuration: GradienConfiguration.sample)
}
