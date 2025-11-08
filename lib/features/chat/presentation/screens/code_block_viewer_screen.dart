import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// Code display options
class CodeDisplayOptions {
  const CodeDisplayOptions({
    this.showLineNumbers = true,
    this.wrapLines = false,
    this.fontSize = 14.0,
    this.isDarkTheme = true,
  });

  final bool showLineNumbers;
  final bool wrapLines;
  final double fontSize;
  final bool isDarkTheme;

  CodeDisplayOptions copyWith({
    bool? showLineNumbers,
    bool? wrapLines,
    double? fontSize,
    bool? isDarkTheme,
  }) {
    return CodeDisplayOptions(
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      wrapLines: wrapLines ?? this.wrapLines,
      fontSize: fontSize ?? this.fontSize,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
    );
  }
}

/// Code block data model
class CodeBlock {
  const CodeBlock({
    required this.code,
    required this.language,
    this.fileName,
    this.description,
  });

  final String code;
  final String language;
  final String? fileName;
  final String? description;

  int get lineCount => code.split('\n').length;

  String get formattedLanguage {
    final languageMap = {
      'dart': 'Dart',
      'python': 'Python',
      'javascript': 'JavaScript',
      'typescript': 'TypeScript',
      'java': 'Java',
      'kotlin': 'Kotlin',
      'swift': 'Swift',
      'cpp': 'C++',
      'c': 'C',
      'csharp': 'C#',
      'go': 'Go',
      'rust': 'Rust',
      'ruby': 'Ruby',
      'php': 'PHP',
      'html': 'HTML',
      'css': 'CSS',
      'sql': 'SQL',
      'bash': 'Bash',
      'shell': 'Shell',
      'json': 'JSON',
      'yaml': 'YAML',
      'xml': 'XML',
      'markdown': 'Markdown',
    };

    return languageMap[language.toLowerCase()] ?? language.toUpperCase();
  }

  IconData get languageIcon {
    final iconMap = {
      'dart': Icons.code,
      'python': Icons.terminal,
      'javascript': Icons.javascript,
      'typescript': Icons.code,
      'java': Icons.coffee,
      'kotlin': Icons.android,
      'swift': Icons.apple,
      'html': Icons.html,
      'css': Icons.style,
      'json': Icons.data_object,
      'sql': Icons.storage,
      'bash': Icons.terminal,
      'shell': Icons.terminal,
    };

    return iconMap[language.toLowerCase()] ?? Icons.code;
  }
}

/// Screen for viewing code blocks with syntax highlighting
class CodeBlockViewerScreen extends ConsumerStatefulWidget {
  const CodeBlockViewerScreen({
    required this.codeBlock,
    super.key,
  });

  final CodeBlock codeBlock;

  @override
  ConsumerState<CodeBlockViewerScreen> createState() =>
      _CodeBlockViewerScreenState();
}

class _CodeBlockViewerScreenState extends ConsumerState<CodeBlockViewerScreen> {
  late CodeDisplayOptions _options;
  bool _isFullScreen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _options = const CodeDisplayOptions();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Code Viewer');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.codeBlock.code));

    if (mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Code copied (${widget.codeBlock.lineCount} lines)',
      );
    }
  }

  Future<void> _shareCode() async {
    // In a real implementation, use share_plus package
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Code'),
        content: const Text('Share functionality will be implemented with share_plus package.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadCode() async {
    // In a real implementation, download the code as a file
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Code'),
        content: Text(
          'Code will be saved as: ${widget.codeBlock.fileName ?? "code.${widget.codeBlock.language}"}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showAccessibleSuccessSnackBar(
                context,
                'Code downloaded successfully',
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _OptionsBottomSheet(
        options: _options,
        onOptionsChanged: (newOptions) {
          setState(() => _options = newOptions);
        },
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _options.isDarkTheme
          ? const Color(0xFF1E1E1E)
          : Colors.grey.shade50,
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Code Viewer'),
                  if (widget.codeBlock.fileName != null)
                    Text(
                      widget.codeBlock.fileName!,
                      style: AppTextStyles.labelSmall().copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
              actions: [
                SemanticIconButton(
                  icon: Icons.copy,
                  label: 'Copy code',
                  onPressed: _copyCode,
                ),
                SemanticIconButton(
                  icon: Icons.share,
                  label: 'Share code',
                  onPressed: _shareCode,
                ),
                SemanticIconButton(
                  icon: Icons.download,
                  label: 'Download code',
                  onPressed: _downloadCode,
                ),
                SemanticIconButton(
                  icon: Icons.settings,
                  label: 'Display options',
                  onPressed: _showOptionsSheet,
                ),
              ],
            ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: Column(
            children: [
            // Header with language and stats (only when not fullscreen)
            if (!_isFullScreen) _buildHeader(),

            // Code display
            Expanded(
              child: _buildCodeDisplay(),
            ),

            // Footer with actions (only when not fullscreen)
            if (!_isFullScreen) _buildFooter(),
          ],
      ),  // Close Column
    ),  // Close ResponsiveCenter
  ),  // Close SafeArea
      floatingActionButton: _isFullScreen
          ? FloatingActionButton(
              onPressed: _toggleFullScreen,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.fullscreen_exit),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.zeusGradient,
      ),
      child: Row(
        children: [
          Semantics(
            label: '${widget.codeBlock.formattedLanguage} code',
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.codeBlock.languageIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.codeBlock.formattedLanguage,
                  style: AppTextStyles.h4().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.codeBlock.description != null)
                  Text(
                    widget.codeBlock.description!,
                    style: AppTextStyles.bodySmall().copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.line_style,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.codeBlock.lineCount} lines',
                  style: AppTextStyles.labelSmall().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeDisplay() {
    return Container(
      color: _options.isDarkTheme
          ? const Color(0xFF1E1E1E)
          : Colors.grey.shade50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line numbers
          if (_options.showLineNumbers) _buildLineNumbers(),

          // Code content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SelectableText(
                    widget.codeBlock.code,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: _options.fontSize,
                      color: _options.isDarkTheme
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineNumbers() {
    final lines = widget.codeBlock.code.split('\n');

    return Container(
      color: _options.isDarkTheme
          ? const Color(0xFF2D2D2D)
          : Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          lines.length,
          (index) => Container(
            height: _options.fontSize * 1.5,
            alignment: Alignment.centerRight,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: _options.fontSize,
                color: _options.isDarkTheme
                    ? Colors.grey.shade600
                    : Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.codeBlock.code.length} characters',
                style: AppTextStyles.labelSmall().copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // Actions
          Row(
            children: [
              TextButton.icon(
                onPressed: _toggleFullScreen,
                icon: const Icon(Icons.fullscreen, size: 18),
                label: const Text('Full Screen'),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton.icon(
                onPressed: _copyCode,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Options bottom sheet for code display customization
class _OptionsBottomSheet extends StatefulWidget {
  const _OptionsBottomSheet({
    required this.options,
    required this.onOptionsChanged,
  });

  final CodeDisplayOptions options;
  final ValueChanged<CodeDisplayOptions> onOptionsChanged;

  @override
  State<_OptionsBottomSheet> createState() => _OptionsBottomSheetState();
}

class _OptionsBottomSheetState extends State<_OptionsBottomSheet> {
  late CodeDisplayOptions _currentOptions;

  @override
  void initState() {
    super.initState();
    _currentOptions = widget.options;
  }

  void _updateOptions(CodeDisplayOptions newOptions) {
    setState(() => _currentOptions = newOptions);
    widget.onOptionsChanged(newOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Display Options',
                style: AppTextStyles.h4().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Show line numbers toggle
          SwitchListTile(
            title: const Text('Show Line Numbers'),
            subtitle: const Text('Display line numbers on the left side'),
            value: _currentOptions.showLineNumbers,
            onChanged: (value) {
              _updateOptions(_currentOptions.copyWith(showLineNumbers: value));
            },
          ),

          // Wrap lines toggle
          SwitchListTile(
            title: const Text('Wrap Lines'),
            subtitle: const Text('Wrap long lines instead of scrolling'),
            value: _currentOptions.wrapLines,
            onChanged: (value) {
              _updateOptions(_currentOptions.copyWith(wrapLines: value));
            },
          ),

          // Dark theme toggle
          SwitchListTile(
            title: const Text('Dark Code Theme'),
            subtitle: const Text('Use dark background for code display'),
            value: _currentOptions.isDarkTheme,
            onChanged: (value) {
              _updateOptions(_currentOptions.copyWith(isDarkTheme: value));
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Font size slider
          Text(
            'Font Size: ${_currentOptions.fontSize.toInt()}px',
            style: AppTextStyles.bodyMedium().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _currentOptions.fontSize,
            min: 10,
            max: 24,
            divisions: 14,
            label: '${_currentOptions.fontSize.toInt()}px',
            onChanged: (value) {
              _updateOptions(_currentOptions.copyWith(fontSize: value));
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('Done'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
