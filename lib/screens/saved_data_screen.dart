import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/blocs/saved_data/saved_data_cubit.dart';
import 'package:my_project/blocs/saved_data/saved_data_state.dart';

class SavedDataScreen extends StatelessWidget {
  const SavedDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavedDataCubit()..loadSavedData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Збережені дані'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<SavedDataCubit, SavedDataState>(
              builder: (context, state) {
                if (state is SavedDataLoading) {
                  return const CircularProgressIndicator();
                } else if (state is SavedDataLoaded) {
                  return Text(
                    state.data,
                    style: const TextStyle(fontSize: 18),
                  );
                } else if (state is SavedDataError) {
                  return Text(
                    state.message,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  );
                } else {
                  return const Text('Дані відсутні');
                }
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<SavedDataCubit>().loadSavedData();
          },
          tooltip: 'Оновити',
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
