part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class GetSlidersLoadingState extends HomeState {}

final class GetSlidersSuccessState extends HomeState {
  final List<slider.Slider> sliders;

  GetSlidersSuccessState(this.sliders);
}

final class GetSlidersErrorState extends HomeState {
  final String? msg;

  GetSlidersErrorState({this.msg});
}

final class GetNewsLoadingState extends HomeState {}

final class GetNewsSuccessState extends HomeState {
  final List<News> news;

  GetNewsSuccessState(this.news);
}

final class GetNewsErrorState extends HomeState {
  final String? msg;

  GetNewsErrorState({this.msg});
}

final class GetFAQLoadingState extends HomeState {}

final class GetFAQSuccessState extends HomeState {
  final List<FAQ> news;

  GetFAQSuccessState(this.news);
}

final class GetFAQErrorState extends HomeState {
  final String? msg;

  GetFAQErrorState({this.msg});
}

final class GetProfileLoadingState extends HomeState {}

final class GetProfileSuccessState extends HomeState {
  final User user;

  GetProfileSuccessState(this.user);
}

final class GetProfileErrorState extends HomeState {
  final String? msg;

  GetProfileErrorState({this.msg});
}