#  BreedSheet code assessment
*A cheatsheet for cat breeds*

### The task
This simple project fetches cat breeds from The Cat API and displays them in a list with an image and title. For this
assessment I chose to keep the UI as simple as possible while focussing on a testable and easy to understand
architecture.

Instead of opting for third-party libraries, I considered the simplicity of the problem and decided to use a very basic
MVVM approach but with extensive tests to show how to ensure it all works well. MVVM-C would've been overkill as there's
only one full view shown. I kept the hierarchy as flat as possible and for now only the API client can be properly
mocked.

The main SwiftUI view is `BreedsListView` where I support different states (loading, failed, empty), all of which have
their own `#Preview`. To make previewing (and UITests) easier I’m using a special mock for the API client. 

### Project Setup
The Cat API key and base URL are kept out of source control. Before building, copy
`Configuration/Secrets.template.xcconfig` to `Configuration/Secrets.xcconfig` (same folder) and fill in your own
`CAT_API_KEY` (get one at [thecatapi.com](https://thecatapi.com)) — `Secrets.xcconfig` is git-ignored so it never
gets committed. Xcode picks the values up automatically as build settings, exposed to the app via two Info.plist
entries and read by `AppSecrets`.

This is a very basic implementation of secrets management. Still these values are unencrypted and nefarious users can
still inspect the app’s .ipa to find the values in plain text in Info.plist. Ideally some sort of code generation is
used that only stores these values in code and only decrypts them in-memory. 

### Technologies
I’m using a very simple approach to MVVM along with dependency injection to keep the project easy to understand at a
glance. The `LiveCatAPI` is injected into `BreedsViewModel` and passed on from `BreedSheetApp` to `BreedsListView`.

There’s two types of mocks for the CatAPI:
 - `PreviewCatAPI` (only in `#DEBUG` builds): Exists as a helper for Xcode Previews in `BreedListView.swift` and the
   UI tests.
 - `MockCatAPI` (only in Tests): More extensive mock that relies on a custom implementation of `URLProtocol` to stub
   responses in a configured `URLSession`.

Instead of `ObservableObject` I’m using the newer (and simpler) Observation framework. This does require iOS 17+ but
supporting three (iOS 27 not included) major versions of iOS seems plenty for this assessment. Swift Testing handles the
tests.

### Notes on Swift Concurrency
The project is set up to be `@MainActor` by default, so all components don’t need

### Limitations
- Only shows a simple list with a limited amount of cat breeds, no further navigation.
- Performance is not optimized. `AsyncImage` can cause performance hitches when loading during scrolling

### How I Would Continue
A search bar would be a nice extra feature as I'm finding myself wanting to look up the breeds of our cats (European
Shorthair, currently, but before that a Russian Blue).
I'd also love to make the app more lively. Give it an icon, a fun color scheme and add some animations.

While scrolling the images that load in can cause hitches. This could be improved by using something else than
`AsyncImage`, using a 3rd party library that loads and caches the images and makes sure they're deflated off the main
thread.

For now the architecture is fine given the limitations, but with more views, view models and API calls, code needs to be
separated more clearly using coordinators. Ideally dependencies should be grouped together. 
