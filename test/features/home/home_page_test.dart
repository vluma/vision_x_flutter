import 'package:flutter_test/flutter_test.dart';
import 'package:vision_x_flutter/features/home/states/home_state.dart';

void main() {
  group('HomeState Tests', () {
    test('HomeInitial state', () {
      const state = HomeInitial();
      expect(state, isA<HomeState>());
    });

    test('HomeLoading state', () {
      const state = HomeLoading();
      expect(state, isA<HomeState>());
    });

    test('HomeLoaded state', () {
      const state = HomeLoaded(movies: []);
      expect(state, isA<HomeState>());
      expect(state.movies, isEmpty);
    });

    test('HomeError state', () {
      const state = HomeError('Test error');
      expect(state, isA<HomeState>());
      expect(state.message, 'Test error');
    });
  });
}