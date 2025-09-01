import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vision_x_flutter/features/home/viewmodels/home_view_model.dart';
import 'package:vision_x_flutter/features/home/data/movie_repository.dart';
import 'package:vision_x_flutter/features/home/states/home_state.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  group('HomeViewModel Tests', () {
    late MockMovieRepository mockRepository;
    late HomeViewModel viewModel;

    setUp(() {
      mockRepository = MockMovieRepository();
      viewModel = HomeViewModel(mockRepository);
    });

    test('initial state is HomeInitial', () {
      expect(viewModel.state, isA<HomeInitial>());
    });

    // 其他测试用例需要根据具体实现编写
  });
}