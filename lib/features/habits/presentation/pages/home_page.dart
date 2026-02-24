import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/responsive.dart';
import '../../../tracking/presentation/bloc/calendar_bloc.dart';
import '../../../tracking/presentation/bloc/calendar_event.dart';
import '../../../tracking/presentation/bloc/calendar_state.dart';
import '../../../tracking/presentation/bloc/stats_bloc.dart';
import '../../../tracking/presentation/bloc/stats_event.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_event.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../widgets/daily_goals_card.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/delete_habit_dialog_box.dart';
import '../widgets/habits_section_header.dart';
import '../widgets/habits_sliver_list.dart';
import '../widgets/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateHelper.normalize(DateTime.now());
    _loadData();
  }

  void _loadData() {
    context.read<HabitBloc>().add(const LoadActiveHabitsEvent());
    context.read<TrackingBloc>().add(LoadDateTrackingEvent(_currentDate));
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _currentDate = DateHelper.normalize(newDate));
    context.read<TrackingBloc>().add(LoadDateTrackingEvent(newDate));
  }

  void _onHabitStateChanged(BuildContext context, HabitState state) {
    if (state is HabitCreated ||
        state is HabitUpdated ||
        state is HabitDeleted) {
      final calendarState = context.read<CalendarBloc>().state;
      final refreshMonth = calendarState is CalendarLoaded
          ? calendarState.selectedDate
          : _currentDate;

      context.read<TrackingBloc>().add(LoadDateTrackingEvent(_currentDate));
      context.read<StatisticsBloc>().add(const RefreshStatisticsEvent());
      context.read<CalendarBloc>().add(RefreshCalendarEvent(refreshMonth));
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.contentMaxWidth;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: BlocListener<HabitBloc, HabitState>(
                listener: _onHabitStateChanged,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: HomeHeader(
                        username:
                            'Sachin', // TODO: Replace with dynamic user name
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: DateSelectorWidget(
                        currentDate: _currentDate,
                        onDateChanged: _onDateChanged,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: context.spacing(20)),
                    ),
                    const SliverToBoxAdapter(child: DailyGoalsCard()),
                    SliverToBoxAdapter(
                      child: HabitsSectionHeader(date: _currentDate),
                    ),
                    HabitsSliverList(
                      currentDate: _currentDate,
                      onDeleteRequested: (ctx, id) =>
                          DeleteHabitDialog.show(ctx, id),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: context.spacing(100)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
