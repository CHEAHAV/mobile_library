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
    title: "Select from Our \n      Best Menu",
    description:
        "Pick your food from our menu \n            More than 35 times",
  ),
  OnBoardingContent(
    image: "assets/images/onboard/l2.png",
    title: "Easy and Online Payment",
    description:
        "You can pay cash on delivery and \n      Card payment is availabal",
  ),
  OnBoardingContent(
    image: "assets/images/onboard/l3.png",
    title: "Quick delivery at your Doorstep",
    description: "Delever your food at your \n                Doorstep",
  ),
];
