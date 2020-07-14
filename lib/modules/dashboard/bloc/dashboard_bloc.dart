import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ks_bike_mobile/utils/key.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';
part 'dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repo = DashboardRepository();

  DashboardBloc(DashboardState initialState) : super(initialState);

  @override
  Stream<DashboardState> mapEventToState(
    DashboardEvent event,
  ) async* {
    yield DashboardLoading(state.props[0], state.props[1]);
    if (event is DashboardHasStore) {
      final result = await _repo.isHasStore();

      yield DashboardInitial(isHasStore: result);
    }
  }
}
