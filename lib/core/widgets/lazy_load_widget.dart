import 'package:flutter/material.dart';

/// Widget that lazy loads its child when it comes into view
///
/// This widget helps improve performance by deferring the building
/// of expensive widgets until they're actually needed.
///
/// Usage:
/// ```dart
/// LazyLoadWidget(
///   builder: (context) => ExpensiveWidget(),
/// );
/// ```
class LazyLoadWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final Widget? placeholder;
  final double threshold;

  const LazyLoadWidget({
    super.key,
    required this.builder,
    this.placeholder,
    this.threshold = 200.0,
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return widget.builder(context);
    }

    return VisibilityDetector(
      key: ValueKey(widget.key),
      threshold: widget.threshold,
      onVisible: () {
        if (!_isLoaded && mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
      child: widget.placeholder ?? const SizedBox.shrink(),
    );
  }
}

/// Visibility detector for lazy loading
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onVisible;
  final double threshold;
  final ValueKey key;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisible,
    this.threshold = 200.0,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to detect when widget is in viewport
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple visibility check
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkVisibility();
          }
        });

        return widget.child;
      },
    );
  }

  void _checkVisibility() {
    try {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached) return;

      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      final screenHeight = MediaQuery.of(context).size.height;

      // Check if widget is within threshold of viewport
      if (position.dy < screenHeight + widget.threshold &&
          position.dy + size.height > -widget.threshold) {
        widget.onVisible();
      }
    } catch (e) {
      // Silently fail if we can't determine visibility
    }
  }
}

/// Optimized image widget with lazy loading
///
/// Automatically lazy loads images and provides caching.
///
/// Usage:
/// ```dart
/// OptimizedImage(
///   imageUrl: 'https://example.com/image.jpg',
///   width: 300,
///   height: 200,
/// );
/// ```
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool lazyLoad;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.lazyLoad = true,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return placeholder ??
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            const Center(
              child: Icon(Icons.error, color: Colors.red),
            );
      },
      // Enable caching
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );

    if (!lazyLoad) {
      return image;
    }

    return LazyLoadWidget(
      builder: (_) => image,
      placeholder: placeholder ??
          SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }
}

/// Lazy list view that only builds visible items
///
/// More efficient than standard ListView for large lists.
///
/// Usage:
/// ```dart
/// LazyListView(
///   itemCount: 1000,
///   itemBuilder: (context, index) => ListTile(
///     title: Text('Item $index'),
///   ),
/// );
/// ```
class LazyListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const LazyListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Add caching for better performance
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
    );
  }
}

/// Lazy grid view that only builds visible items
class LazyGridView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const LazyGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Add caching for better performance
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
    );
  }
}

/// Deferred widget that builds after a delay
///
/// Useful for splitting heavy rendering across multiple frames.
///
/// Usage:
/// ```dart
/// DeferredWidget(
///   delay: Duration(milliseconds: 100),
///   builder: (context) => HeavyWidget(),
/// );
/// ```
class DeferredWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final Duration delay;
  final Widget? placeholder;

  const DeferredWidget({
    super.key,
    required this.builder,
    this.delay = const Duration(milliseconds: 50),
    this.placeholder,
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return widget.builder(context);
    }

    return widget.placeholder ?? const SizedBox.shrink();
  }
}
