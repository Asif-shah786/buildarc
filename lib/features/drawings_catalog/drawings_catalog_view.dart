import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/account_context/state.dart';
import 'package:ardennes/libraries/core_ui/image_downloading/image_firebase.dart';
import 'package:ardennes/models/drawings/drawing_item.dart';
import 'package:ardennes/models/drawings/drawings_catalog_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

import '../../models/drawings/drawing_sheet_view_log.dart';
import '../recent_drawing/recent_drawing_bloc.dart';
import 'drawings_catalog_bloc.dart';
import 'drawings_catalog_event.dart';
import 'drawings_catalog_state.dart';

class DrawingsCatalogScreen extends StatefulWidget {
  const DrawingsCatalogScreen({super.key});

  @override
  DrawingsCatalogScreenState createState() => DrawingsCatalogScreenState();
}

class DrawingsCatalogScreenState extends State<DrawingsCatalogScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    searchController.addListener(
      () {
        final searchQuery = searchController.text;
        context.read<DrawingsCatalogBloc>().add(SearchDrawingsCatalogEvent(searchQuery));
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accountContextState = context.watch<AccountContextBloc>().state;
    final drawingsCatalogBloc = context.read<DrawingsCatalogBloc>();

    if (accountContextState is AccountContextLoadedState) {
      final selectedProject = accountContextState.selectedProject;
      if (selectedProject != null) {
        drawingsCatalogBloc.add(FetchDrawingsCatalogEvent(selectedProject));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
            controller: searchController,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<DrawingsCatalogBloc, DrawingsCatalogState>(
              builder: (context, state) {
                if (state is FetchedDrawingsCatalogState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilterChips(
                        drawingsCatalogData: state.drawingsCatalog,
                        selectedVersionId: state.uiState.selectedVersion,
                        selectedCollection: state.uiState.selectedCollection,
                        selectedDiscipline: state.uiState.selectedDiscipline,
                        selectedTag: state.uiState.selectedTag,
                        onVersionSelected: (version) {
                          context.read<DrawingsCatalogBloc>().add(UpdateSelectedVersionEvent(version));
                        },
                        onCollectionSelected: (collection) {
                          context.read<DrawingsCatalogBloc>().add(UpdateSelectedCollectionEvent(collection));
                        },
                        onDisciplineSelected: (discipline) {
                          context.read<DrawingsCatalogBloc>().add(UpdateSelectedDisciplineEvent(discipline));
                        },
                        onTagSelected: (tag) {
                          context.read<DrawingsCatalogBloc>().add(UpdateSelectedTagEvent(tag));
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: DrawingGrid(
                          drawingItems: state.displayedItems,
                          projectId: state.drawingsCatalog.projectId,
                        ),
                      )
                    ],
                  );
                } else {
                  return const ShimmeringBars();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingGrid extends StatelessWidget {
  final List<DrawingItem> drawingItems;
  final String projectId;

  const DrawingGrid({
    Key? key,
    required this.projectId,
    required this.drawingItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      children: drawingItems.map((drawing) {
        return GestureDetector(
          onTap: () {
            if ((FirebaseAuth.instance.currentUser?.uid ?? '').isNotEmpty && projectId.isNotEmpty) {
              DrawingViewLogItem newItem = DrawingViewLogItem(
                title: drawing.title,
                subTitle: drawing.collection,
                url: drawing.smallThumbnailUrl,
              );
              context.read<RecentDrawingBloc>().add(LogRecentDrawing(
                  projectId: projectId, userId: FirebaseAuth.instance.currentUser!.uid, newItem: newItem));
            }

            context.go(
              Uri(
                path: '/drawings/sheet/',
                queryParameters: {
                  'number': drawing.title,
                  'collection': drawing.collection,
                  'versionId': drawing.versionId.toString(),
                  'projectId': projectId
                },
              ).toString(),
            );
          },
          child: Card(
            child: Column(
              children: [
                Expanded(child: ImageFromFirebase(imageUrl: drawing.thumbnailUrl)),
                Text(drawing.title),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ShimmeringBars extends StatelessWidget {
  const ShimmeringBars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 1.0,
            child: Container(
              height: 24.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FractionallySizedBox(
            widthFactor: 0.75,
            child: Container(
              height: 24.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  final DrawingsCatalogData drawingsCatalogData;
  final void Function(DrawingVersion?)? onVersionSelected;
  final void Function(DrawingCollection?)? onCollectionSelected;
  final void Function(DrawingDiscipline?)? onDisciplineSelected;
  final void Function(DrawingTag?)? onTagSelected;

  final DrawingVersion? selectedVersionId;
  final DrawingCollection? selectedCollection;
  final DrawingDiscipline? selectedDiscipline;
  final DrawingTag? selectedTag;

  const FilterChips({
    Key? key,
    required this.drawingsCatalogData,
    this.onVersionSelected,
    this.onCollectionSelected,
    this.onDisciplineSelected,
    this.onTagSelected,
    this.selectedVersionId,
    this.selectedCollection,
    this.selectedDiscipline,
    this.selectedTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        DropdownButtonWidget<DrawingVersion>(
          items: drawingsCatalogData.versions,
          getName: (version) => version.name,
          onChanged: onVersionSelected,
          hint: 'Version',
          selectedItem: selectedVersionId,
        ),
        DropdownButtonWidget<DrawingCollection>(
          items: drawingsCatalogData.collections,
          getName: (collection) => collection.name,
          onChanged: onCollectionSelected,
          hint: 'Collection',
          selectedItem: selectedCollection,
        ),
        DropdownButtonWidget<DrawingDiscipline>(
          items: drawingsCatalogData.disciplines,
          getName: (discipline) => discipline.name,
          onChanged: onDisciplineSelected,
          hint: 'Discipline',
          selectedItem: selectedDiscipline,
        ),
        DropdownButtonWidget<DrawingTag>(
          items: drawingsCatalogData.tags,
          getName: (tag) => tag.name,
          onChanged: onTagSelected,
          hint: 'Tag',
          selectedItem: selectedTag,
        ),
      ],
    );
  }
}

class DropdownButtonWidget<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getName;
  final void Function(T?)? onChanged;
  final String hint;
  final T? selectedItem;

  const DropdownButtonWidget({
    Key? key,
    required this.items,
    required this.getName,
    required this.onChanged,
    required this.hint,
    this.selectedItem,
  }) : super(key: key);

  @override
  DropdownButtonWidgetState<T> createState() => DropdownButtonWidgetState<T>();
}

class DropdownButtonWidgetState<T> extends State<DropdownButtonWidget<T>> {
  T? selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedItem;
  }

  void _selectItem(T? newValue) {
    setState(() {
      selectedItem = newValue;
    });
    widget.onChanged?.call(newValue);
  }

  void _showDropdown(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy,
      ),
      items: widget.items.map((T item) {
        return PopupMenuItem<T>(
          value: item,
          child: Text(widget.getName(item)),
        );
      }).toList(),
    ).then((T? newValue) {
      if (newValue != null) {
        _selectItem(newValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = this.selectedItem;
    if (selectedItem == null) {
      return OutlinedButton(
        onPressed: () => _showDropdown(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.hint),
            const SizedBox(width: 8.0),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      );
    } else {
      return InputChip(
        label: Text(widget.getName(selectedItem)),
        onDeleted: () {
          _selectItem(null);
        },
        deleteIcon: const Icon(Icons.cancel),
        avatar: Icon(Icons.check, color: Theme.of(context).colorScheme.secondary),
        onPressed: () => _showDropdown(context),
      );
    }
  }
}
