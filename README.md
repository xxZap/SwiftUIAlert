<div align="center">
  <h1>SwiftUIAlert</h1>
</div>

<div align="center">
A comprehensive Swift Package solution for SwiftUI alerts management in iOS projects
</div>

<p align="center">
    <img src="https://img.shields.io/badge/iOS-v15-blue"/>
    <img src="https://img.shields.io/badge/macOS-v11-purple"/>
    <img src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat"/>
    <a href="https://github.com/xxZap/SwiftUIAlert/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/license-apache 2.0-gold"/>
    </a>
</p>

## Installation
### 📦 Swift Package Manager
Add SwiftUIAlert as a Swift Package in Xcode 11.0 or later, `select File > Swift Packages > Add Package Dependency...` and add the repository URL:
```
https://github.com/xxZap/SwiftUIAlert.git
```

## Requirements
- iOS 15+
- Swift 5

## Feature
Here's the list of the awesome features `SwiftUIAlert` has:
- [X] clean way to show single or multiple `Alert`s in SwiftUI
- [X] you don't have to add `Alert`s as view modifiers any more
- [X] blends in perfectly with all other SwiftUI functioanlity and principles
- [X] `Combine` friendly: just listen for changes and communicate them to the `AlertController`
- [X] `MVVM` friendly: handle alerts business logic directly from your viewModels and keep your views agnostic
- [ ] feedbacks

## The Problem

In `SwiftUI` alerts are added as view modifiers with a bit of help from `@State`:

``` swift
struct MyView: View {

    @State private var isSwiftUIAlert1Presented = false
    @State private var isSwiftUIAlert2Presented = false
    
    var body: some View {
        Button("SwiftUI Alert") {
            isSwiftUIAlert1Presented = true
        }
        .alert(isPresented: $isSwiftUIAlert1Presented) {
            Alert(title: Text("SwiftUI Alert 1"))
        }
        .alert(isPresented: $isSwiftUIAlert2Presented) {
            Alert(title: Text("SwiftUI Alert 2"))
        }
        ...
    }
}  
```

This will get ugly really quickly if you're trying to add multiple `Alert`s on a view. Lots of `@State`s with `Alert`s scattered all around your view 💩

## License
[Apache License 2.0][license]. See Apache Software Foundation's [licensing FAQ][licensing-faq]

[license]: LICENSE.txt
[licensing-faq]: https://www.apache.org/licenses/LICENSE-2.0
