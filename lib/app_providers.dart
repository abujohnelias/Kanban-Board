import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_app/blocs/kanban_bloc/kanban_bloc.dart';

class AppBlocProviders {
  static List<BlocProvider> get providers => [
    BlocProvider<KanbanBloc>(create: (context) => KanbanBloc()),
  ];
}
