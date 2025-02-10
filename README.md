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
- [ ] multiple alerts support
- [ ] solve SwiftUI limitation around lack of completion show/hide alert that forces us a programmatic delay for consecutive alerts

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

## How SwiftUIAlert works
Simply register an `AlertController` instance on the root of a navigation. This will ensure an `@Environment` accessibility to all of the subviews all along the same navigation.

```swift
import SwiftUI
import SwiftUIAlert

struct ExampleRootView: View {

    @StateObject private var alertController = AlertController()

    var body: some View {
        NavigationStack {
            ExampleView()
        }
        .registerAlertController(alertController)               // <--- Important: register an AlertController instance on the root
                                                                //      to make it accassible to all the subviews through a dedicated Environment variable
    }
}
```

Once an `AlertController` instance is being register on the root view, you can just access to it in all of the subviews through a dedicated @Environment variable:
```swift
struct ExampleView: View {
    ...
    @Environment(\.alertController) private var alertController // <--- You have alertController as Environment variable
                                                                //      all along ExampleRootView navigation
    ...
```

Now you can just create your `ExampleView` without caring about the alert creation/handling logic because all the business logic is moved inside the viewmodel, as it should be.
You can let your `ExampleViewModel` to expose a `@Published BaseAlert?` and connect it to the living `alertController` instance.
```swift
struct ExampleView: View {

    @StateObject private var viewModel = ExampleViewModel()
    @Environment(\.alertController) private var alertController // <--- You have alertController as Environment variable
                                                                //      all along ExampleRootView navigation
    var body: some View {
        VStack {
            Button {
                viewModel.onButtonTap()
            } label: {
                Text("Show alert")
            }
        }
        .onChange(of: viewModel.alert) { alert in               // <--- When the view model emits a new alert value
            alertController.alert = alert                       //      just pass it to the alertController to handle its visibility
        }
    }
}
```

Finally, all the logic can be writte in your ViewModel.
A small example can be:
```swift
import Combine

class ExampleViewModel: ObservableObject {

    @Published var alert: BaseAlert?
    private var alertPublisher: CurrentValueSubject<BaseAlert?, Never> = .init(nil)
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.alertPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] alert in
                self?.alert = alert
            }
            .store(in: &cancellables)
    }

    func onOkButtonTap() {
        alertPublisher.send(SwiftUIAlert(title: "Title", message: "This is classic cancel/ok alert", alertButtons: [
            AlertButton("Cancel", role: .cancel) {
                // Whatever the viewmodel wants to do here...
            },
            AlertButton("Ok", role: .default) {
                // Whatever the viewmodel wants to do here...
            }
        ]))
    }
}
```

Using this library, you won't see anymore your views horribly scaling when you have to handle multiple alerts and, most of all, your views will not know anything about the logic.
You can handle multiple alerts directly on your ViewModel.
As an extra, this library exposes an alert with a `TextField`!
```swift
import Combine

class ExampleViewModel: ObservableObject {

    @Published var alert: BaseAlert?
    private var alertPublisher: CurrentValueSubject<BaseAlert?, Never> = .init(nil)
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.alertPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] alert in
                self?.alert = alert
            }
            .store(in: &cancellables)
    }

    func onOkButtonTap() {
        alertPublisher.send(SwiftUIAlert(title: "Title", message: "This is classic cancel/ok alert", alertButtons: [
            AlertButton("Cancel", role: .cancel) {
                // Whatever the viewmodel wants to do here...
            },
            AlertButton("Ok", role: .default) {
                // Whatever the viewmodel wants to do here...
            }
        ]))
    }

    func onDestructableButtonTap() {
        alertPublisher.send(SwiftUIAlert(title: "Title", message: "This is a destructable alert", alertButtons: [
            AlertButton("Cancel", role: .cancel) {
                // Whatever the viewmodel wants to do here...
            },
            AlertButton("Ok", role: .destructive) {
                // Whatever the viewmodel wants to do here...
            }
        ]))
    }

    func onConsecutiveAlertsButtonTap() {
        alertPublisher.send(SwiftUIAlert(title: "Title", message: "This alert shows another alert", alertButtons: [
            AlertButton("Show another alert") { [weak self] in
                // TODO:
                // one limitation of SwiftUI is that there's no completion on system alert show/hide action
                // and if you try to present an alert while another one is dismissing, unpredictable things can happen.
                // for the moment, a programmatic delay is needed.
                // 300 milliseconds are safe. Shorter delays may be useless
                Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    self?.alertPublisher.send(SwiftUIAlert(title: "Callback", message: "You see another alert", alertButtons: [
                        AlertButton("Ok") {
                            // Whatever the viewmodel wants to do here...
                        }
                    ]))
                }
            }
        ]))
    }

    func onTextFieldButtonTap() {
        alertPublisher.send(SwiftUITextFieldAlert(
            title: "Title",
            message: "This is an alert that contains a textfield",
            alertButtons: [
                AlertButton("Cancel", role: .cancel) {
                    // Whatever the viewmodel wants to do here...
                },
                AlertButton("Ok", role: .default) {
                    // Whatever the viewmodel wants to do here...
                    // the onSubmit will be automatically called
                }
            ],
            placeholder: "Placeholder text...",
            onSubmit: { confirmed, text, submitType in
                print("the user confirmed: \(confirmed)")
                print("the content of the textfield: \"\(text)\"")
                print("the user submit type: \(submitType)")
            }
        ))
    }
}
```

## License
[Apache License 2.0][license]. See Apache Software Foundation's [licensing FAQ][licensing-faq]

[license]: LICENSE.txt
[licensing-faq]: https://www.apache.org/licenses/LICENSE-2.0
