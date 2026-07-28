#  BreedSheet code assessment
*A cheatsheet for cat breeds*

### The task
This simple project fetches cat breeds from The Cat API and displays them in a list with an image and title. For this
assessment I chose to keep the UI as simple as possible while focussing on a testable and easy to understand
architecture.

Instead of opting for third-party libraries, I considered the simplicity of the problem and decided to use a very basic
MVVM approach with a few tests to showcase how to ensure it all works well. MVVM-C would've been overkill as there's
only own full view show. I kept the hierarchy as flat as possible and for now only the API client can be properly
mocked.

The main SwiftUI view is `BreedsListView` where I support different states (loading, failed, empty), all of which have
their own `#Preview`. To make previewing easier I'm using a special, DEBUG-only inline mocked API client.

### Technologies
I'm using a very simple approach to MVVM along with dependency injection to keep the project easy to understand at a
glance. The `LiveCatAPI` is injected into `BreedsViewModel` and passed on from `BreedSheetApp` to `BreedsListView`.

Instead of `ObservableObject` I'm using the newer (and simpler) Observation framework. This does require iOS 17+ but
supporting three (iOS 27 not included) major versions of iOS seems plenty for this assessment. Swift Testing handles the
tests.

### Limitations
- Only shows a simple list with a limited amount of cat breeds, no further navigation.
- No pagination either, although the implementation of `CatAPI` does support this.
- UI design is very basic, in a success state it only shows an the image and name of the each breed.

### How I Would Continue
I'd love to add pagination to the main list and let each item present a large view describing the cat breed in more
detail. A search bar would be nice as well, as I'm finding myself wanting to look up the breeds of our cats (European
Shorthair, currently, but before that a Russian Blue).

I'd also love to make the app more lively. Give it an icon, a fun color scheme and add some animations.

For now the architecture is fine given the limitations, but with more views, view models and API calls, code needs to be
separated more clearly. Ideally dependencies should be grouped together. Also the ownership of view models is a bit
unclear now, which I'd like to figure out too. 
