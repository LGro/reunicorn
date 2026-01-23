// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/map/time_selection_slider.dart'
    as _widgetbook_workspace_map_time_selection_slider;
import 'package:widgetbook_workspace/profile_socials.dart'
    as _widgetbook_workspace_profile_socials;
import 'package:widgetbook_workspace/widgets/introductions_summary.dart'
    as _widgetbook_workspace_widgets_introductions_summary;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'ui',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'map',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'TimeSelectionSlider',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _widgetbook_workspace_map_time_selection_slider
                    .buildTimeSelectionSliderUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'profile',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'widgets',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'ProfileSocialsWidget',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _widgetbook_workspace_profile_socials
                        .buildProfileSocialsWidgetUseCase,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'widgets',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'IntroductionsSummary',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _widgetbook_workspace_widgets_introductions_summary
                    .buildIntroductionsSummaryUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
