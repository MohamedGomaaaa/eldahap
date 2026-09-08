import '../../../model/static_page.dart';

abstract class PageState {}

class PageInitial extends PageState {}

class PageLoading extends PageState {}

class PageLoaded extends PageState {
  final StaticPageModel page;
  PageLoaded(this.page);
}

class PageError extends PageState {
  final String message;
  PageError(this.message);
}