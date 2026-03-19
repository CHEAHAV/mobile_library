class OnBoardingContent {
  String image;
  String title;
  String description;
  OnBoardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnBoardingContent> contents = [
  OnBoardingContent(
    image: "assets/images/onboard/l1.png",
    title: "Explore Thousands of Books",
    description: "Browse our vast collection of books across every genre and topic.",
  ),
  OnBoardingContent(
    image: "assets/images/onboard/l2.png",
    title: "Borrow with Ease",
    description: "Reserve and borrow books anytime, right from your phone.",
  ),
  OnBoardingContent(
    image: "assets/images/onboard/l3.png",
    title: "Track Your Reading",
    description: "Save your favorites and keep track of everything you have read.",
  ),
];