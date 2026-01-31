import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/api/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/api_services.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/badges.dart';

/// 3D Editor Screen - Texture painting and mesh editing
/// Matches the "Tasarımı düzenle" screen from screenshots
class EditorScreen extends ConsumerStatefulWidget {
  final String? assetId;
  final String? templateId;
  final String? designId;

  const EditorScreen({
    super.key,
    this.assetId,
    this.templateId,
    this.designId,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  // Editor state
  Color _selectedColor = const Color(0xFF7C3AED);
  int _currentLayer = 0;
  int _polygonCount = 0;
  final int _maxPolygons = 4000;

  late final WebViewController _webController;
  bool _editorReady = false;
  final List<String> _pendingCommands = [];
  AssetFetchResponse? _assetFetch;
  Completer<Map<String, String>>? _exportCompleter;

  String? get _activeAssetId => widget.assetId ?? widget.designId;

  // Bottom toolbar items
  final List<Map<String, dynamic>> _bottomTools = [
    {'icon': Icons.view_module, 'label': 'Şablonlar'},
    {'icon': Icons.view_in_ar, 'label': '3D Elemanlar'},
    {'icon': Icons.palette, 'label': 'Renkler'},
    {'icon': Icons.chat_bubble_outline, 'label': 'Medya'},
    {'icon': Icons.cloud_upload, 'label': 'Yüklemeler'},
    {'icon': Icons.text_fields, 'label': 'Metin'},
  ];

  // Color palette
  final List<Color> _colorPalette = [
    const Color(0xFF7C3AED), // Purple
    const Color(0xFFEF4444), // Red
    const Color(0xFFF97316), // Orange
    const Color(0xFFEAB308), // Yellow
    const Color(0xFF22C55E), // Green
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFEC4899), // Pink
    const Color(0xFF1F2937), // Dark gray
    const Color(0xFFFFFFFF), // White
    const Color(0xFF9CA3AF), // Gray
    const Color(0xFF000000), // Black
  ];

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'EditorBridge',
        onMessageReceived: _onEditorMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _syncEditorState();
            _loadAssetIfNeeded();
          },
        ),
      )
      ..loadFlutterAsset('assets/3d/editor.html');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.meshPreviewBg,
        body: Column(
          children: [
            // Top Toolbar
            _buildTopToolbar(isDark, topPadding),

            // 3D Canvas Area
            Expanded(
              child: Stack(
                children: [
                  // 3D View (WebView would go here)
                  _build3DCanvas(),

                  // Polygon Counter (bottom left)
                  Positioned(
                    left: AppSpacing.base,
                    bottom: AppSpacing.base,
                    child: PolygonBadge(
                      current: _polygonCount,
                      max: _maxPolygons,
                    ),
                  ),

                  // Right side tools
                  Positioned(
                    right: AppSpacing.base,
                    bottom: AppSpacing.base,
                    child: _buildRightTools(isDark),
                  ),
                ],
              ),
            ),

            // Bottom Toolbar
            _buildBottomToolbar(isDark, bottomPadding),
          ],
        ),
      ),
    );
  }

  void _onEditorMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type == 'ready') {
        setState(() {
          _editorReady = true;
        });
        _flushPendingCommands();
        _syncEditorState();
      } else if (type == 'export') {
        final payload = data['payload'];
        if (payload is Map) {
          final exported = <String, String>{};
          for (final entry in payload.entries) {
            if (entry.key is String && entry.value is String) {
              exported[entry.key as String] = entry.value as String;
            }
          }
          _exportCompleter?.complete(exported);
          _exportCompleter = null;
        }
      }
    } catch (_) {
      // Ignore malformed messages
    }
  }

  void _enqueueCommand(String script) {
    if (!_editorReady) {
      _pendingCommands.add(script);
      return;
    }
    _webController.runJavaScript(script);
  }

  void _flushPendingCommands() {
    for (final command in _pendingCommands) {
      _webController.runJavaScript(command);
    }
    _pendingCommands.clear();
  }

  void _syncEditorState() {
    final colorHex =
        '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    _enqueueCommand(
      "window.editor && window.editor.setBrush({color: '$colorHex', size: 24, opacity: 1.0});",
    );
    _enqueueCommand(
        "window.editor && window.editor.setLayer('${_layerKey(_currentLayer)}');");
  }

  Future<void> _loadAssetIfNeeded() async {
    if (_activeAssetId == null) {
      return;
    }
    final service = ref.read(assetServiceProvider);
    final result = await service.fetchAsset(_activeAssetId!);
    if (result.isError || result.data == null) {
      return;
    }
    _assetFetch = result.data!;
    if (_assetFetch?.meshUrl != null && _assetFetch!.meshUrl!.isNotEmpty) {
      final meshUrl = _assetFetch!.meshUrl!;
      _enqueueCommand(
          "window.editor && window.editor.loadModel(${jsonEncode(meshUrl)});");
    }
    final textures = <String, String?>{
      'albedo': _assetFetch?.textureUrl,
      'metalness': _assetFetch?.pbrMetalnessUrl,
      'roughness': _assetFetch?.pbrRoughnessUrl,
      'normal': _assetFetch?.pbrNormalUrl,
    };
    _enqueueCommand(
      "window.editor && window.editor.setTextureUrls(${jsonEncode(textures)});",
    );
  }

  String _layerKey(int index) {
    switch (index) {
      case 1:
        return 'metalness';
      case 2:
        return 'roughness';
      case 3:
        return 'normal';
      default:
        return 'albedo';
    }
  }

  Future<Map<String, String>> _requestExport() async {
    if (!_editorReady) {
      throw StateError('Editor not ready');
    }
    _exportCompleter = Completer<Map<String, String>>();
    _enqueueCommand('window.editor && window.editor.exportTextures();');
    return _exportCompleter!.future.timeout(const Duration(seconds: 10),
        onTimeout: () {
      throw TimeoutException('Export timeout');
    });
  }

  Future<File> _saveDataUrl(String dataUrl, String filename) async {
    final data = UriData.parse(dataUrl);
    final bytes = data.contentAsBytes();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _handleDownload() async {
    try {
      final textures = await _requestExport();
      if (!textures.containsKey('albedo') ||
          !textures.containsKey('metalness') ||
          !textures.containsKey('roughness') ||
          !textures.containsKey('normal')) {
        throw StateError('Eksik texture katmanları');
      }
      final albedo = textures['albedo'];
      if (albedo == null) {
        throw StateError('No texture data');
      }
      final file = await _saveDataUrl(albedo, 'albedo.png');
      await Share.shareXFiles([XFile(file.path)], text: 'Roblox UGC Texture');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dışa aktarma başarısız: $e')),
        );
      }
    }
  }

  Future<void> _handlePreview() async {
    if (_activeAssetId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Önizleme için varlık bulunamadı')),
        );
      }
      return;
    }
    final url = ApiConfig.buildRobloxDeepLink(_activeAssetId!);
    final success = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Roblox açılamadı')),
      );
    }
  }

  Future<void> _handleUpload() async {
    if (_activeAssetId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yükleme için varlık bulunamadı')),
        );
      }
      return;
    }
    final repo = ref.read(assetRepositoryProvider);
    final asset = await repo.fetchAssetById(_activeAssetId!);
    if (asset == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Varlık bilgisi alınamadı')),
        );
      }
      return;
    }
    if (!mounted) return;
    context.push('/asset/${_activeAssetId!}', extra: asset);
  }

  Future<void> _saveToStorage({required bool publish}) async {
    if (_activeAssetId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaydetmek için varlık bulunamadı')),
        );
      }
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oturum bulunamadı')),
        );
      }
      return;
    }

    try {
      final textures = await _requestExport();
      final storage = ref.read(storageServiceProvider);
      final repo = ref.read(assetRepositoryProvider);

      final albedoFile = await _saveDataUrl(
        textures['albedo']!,
        'albedo_${_activeAssetId!}.png',
      );
      final metalFile = await _saveDataUrl(
        textures['metalness']!,
        'metalness_${_activeAssetId!}.png',
      );
      final roughFile = await _saveDataUrl(
        textures['roughness']!,
        'roughness_${_activeAssetId!}.png',
      );
      final normalFile = await _saveDataUrl(
        textures['normal']!,
        'normal_${_activeAssetId!}.png',
      );

      final albedoPath = storage.buildAssetObjectPath(
        userId: userId,
        assetId: _activeAssetId!,
        fileName: albedoFile.uri.pathSegments.last,
        prefix: 'albedo',
      );
      final metalPath = storage.buildAssetObjectPath(
        userId: userId,
        assetId: _activeAssetId!,
        fileName: metalFile.uri.pathSegments.last,
        prefix: 'metalness',
      );
      final roughPath = storage.buildAssetObjectPath(
        userId: userId,
        assetId: _activeAssetId!,
        fileName: roughFile.uri.pathSegments.last,
        prefix: 'roughness',
      );
      final normalPath = storage.buildAssetObjectPath(
        userId: userId,
        assetId: _activeAssetId!,
        fileName: normalFile.uri.pathSegments.last,
        prefix: 'normal',
      );

      await storage.uploadResumableFile(
        file: albedoFile,
        bucket: 'assets',
        objectPath: albedoPath,
      );
      await storage.uploadResumableFile(
        file: metalFile,
        bucket: 'assets',
        objectPath: metalPath,
      );
      await storage.uploadResumableFile(
        file: roughFile,
        bucket: 'assets',
        objectPath: roughPath,
      );
      await storage.uploadResumableFile(
        file: normalFile,
        bucket: 'assets',
        objectPath: normalPath,
      );

      await repo.updateAssetPaths(
        _activeAssetId!,
        texturePath: albedoPath,
        metalnessPath: metalPath,
        roughnessPath: roughPath,
        normalPath: normalPath,
      );
      await repo.updateVisibility(_activeAssetId!, isPublic: publish);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              publish ? 'Draft ready to publish.' : 'Design saved.',
            ),
          ),
        );
      }

      final asset = await repo.fetchAssetById(_activeAssetId!);
      if (publish && asset != null && mounted) {
        context.push('/asset/${_activeAssetId!}', extra: asset);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  Widget _buildTopToolbar(bool isDark, double topPadding) {
    return Container(
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.sm,
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home button
          _ToolbarIconButton(
            icon: Icons.home,
            onTap: () => Navigator.of(context).pop(),
            isActive: false,
          ),
          const SizedBox(width: AppSpacing.xs),

          // Undo
          _ToolbarIconButton(
            icon: Icons.undo,
            onTap: () {},
            isActive: false,
          ),
          const SizedBox(width: AppSpacing.xs),

          // Redo
          _ToolbarIconButton(
            icon: Icons.redo,
            onTap: () {},
            isActive: false,
          ),

          const Spacer(),

          // Layers button
          _ToolbarIconButton(
            icon: Icons.layers,
            onTap: () => _showLayersPanel(),
            isActive: false,
          ),
          const SizedBox(width: AppSpacing.xs),

          // Premium badge
          const PremiumBadge(),
          const SizedBox(width: AppSpacing.md),

          // Export button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: GestureDetector(
              onTap: () => _showExportSheet(),
              child: Row(
                children: [
                  Text(
                    'Export',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DCanvas() {
    return Container(
      color: AppColors.meshPreviewBg,
      child: Stack(
        children: [
          WebViewWidget(controller: _webController),
          if (!_editorReady)
            Container(
              color: Colors.black.withValues(alpha: 0.05),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightTools(bool isDark) {
    return Column(
      children: [
        // Grid toggle
        _FloatingToolButton(
          icon: Icons.grid_4x4,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        // Zoom controls
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _FloatingToolButton(
                icon: Icons.add,
                onTap: () {},
                noBg: true,
              ),
              Container(
                width: 30,
                height: 1,
                color: AppColors.borderLight,
              ),
              _FloatingToolButton(
                icon: Icons.remove,
                onTap: () {},
                noBg: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar(bool isDark, double bottomPadding) {
    return Container(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tool selector row
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              itemCount: _bottomTools.length,
              itemBuilder: (context, index) {
                final tool = _bottomTools[index];
                final isSelected = index == 0; // Example

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: () {
                      if (tool['label'] == 'Renkler') {
                        _showColorPicker();
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            tool['icon'],
                            size: 24,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tool['label'],
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLayersPanel() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _LayersPanel(
        currentLayer: _currentLayer,
        onLayerChanged: (layer) {
          setState(() {
            _currentLayer = layer;
          });
          _enqueueCommand(
            "window.editor && window.editor.setLayer('${_layerKey(layer)}');",
          );
        },
      ),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ColorPickerPanel(
        selectedColor: _selectedColor,
        colors: _colorPalette,
        onColorSelected: (color) {
          setState(() {
            _selectedColor = color;
          });
          final colorHex =
              '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
          _enqueueCommand(
            "window.editor && window.editor.setBrush({color: '$colorHex', size: 24, opacity: 1.0});",
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExportShareSheet(
        onDownload: _handleDownload,
        onPreview: _handlePreview,
        onUpload: _handleUpload,
        onPublish: () => _saveToStorage(publish: true),
        onSavePrivate: () => _saveToStorage(publish: false),
      ),
    );
  }
}

/// Toolbar Icon Button
class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;

  const _ToolbarIconButton({
    required this.icon,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isActive
              ? AppColors.primary
              : (isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight),
        ),
      ),
    );
  }
}

/// Floating Tool Button
class _FloatingToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool noBg;

  const _FloatingToolButton({
    required this.icon,
    this.onTap,
    this.noBg = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: noBg
            ? null
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
        child: Icon(
          icon,
          size: 22,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}

/// Layers Panel
class _LayersPanel extends StatelessWidget {
  final int currentLayer;
  final ValueChanged<int> onLayerChanged;

  const _LayersPanel({
    required this.currentLayer,
    required this.onLayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final layers = [
      {'name': 'Albedo (Renk)', 'icon': Icons.color_lens},
      {'name': 'Metalness', 'icon': Icons.blur_circular},
      {'name': 'Roughness', 'icon': Icons.texture},
      {'name': 'Normal', 'icon': Icons.grain},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sheetPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Texture Layers',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          ...layers.asMap().entries.map((entry) {
            final isSelected = entry.key == currentLayer;
            return ListTile(
              leading: Icon(
                entry.value['icon'] as IconData,
                color: isSelected ? AppColors.primary : null,
              ),
              title: Text(
                entry.value['name'] as String,
                style: AppTypography.titleSmall.copyWith(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                onLayerChanged(entry.key);
                Navigator.pop(context);
              },
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Color Picker Panel
class _ColorPickerPanel extends StatelessWidget {
  final Color selectedColor;
  final List<Color> colors;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerPanel({
    required this.selectedColor,
    required this.colors,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sheetPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Color',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: colors.map((color) {
              final isSelected = color.toARGB32() == selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (color == Colors.white
                              ? AppColors.borderLight
                              : Colors.transparent),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Color picker button
          SecondaryButton(
            text: 'Select Custom Color',
            icon: Icons.colorize,
            isExpanded: true,
            onPressed: () {
              // Show full color picker
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Export/Share Sheet - Matches the screenshot with download, preview, upload options
class ExportShareSheet extends StatelessWidget {
  final VoidCallback? onDownload;
  final VoidCallback? onPreview;
  final VoidCallback? onUpload;
  final VoidCallback? onPublish;
  final VoidCallback? onSavePrivate;

  const ExportShareSheet({
    super.key,
    this.onDownload,
    this.onPreview,
    this.onUpload,
    this.onPublish,
    this.onSavePrivate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.base,
        left: AppSpacing.sheetPadding,
        right: AppSpacing.sheetPadding,
        bottom: bottomPadding + AppSpacing.base,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title
          Row(
            children: [
              Expanded(
                child: Text(
                  'Share to Design',
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.cardDark : AppColors.backgroundLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ExportOption(
                icon: Icons.download,
                label: 'Download',
                onTap: () {
                  Navigator.pop(context);
                  if (onDownload != null) onDownload!();
                },
              ),
              _ExportOption(
                icon: Icons.visibility,
                label: 'Preview in\nRoblox',
                onTap: () {
                  Navigator.pop(context);
                  if (onPreview != null) onPreview!();
                },
              ),
              _ExportOption(
                icon: Icons.upload,
                label: 'Upload to\nRoblox',
                onTap: () {
                  Navigator.pop(context);
                  if (onUpload != null) onUpload!();
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Publish button (main CTA)
          PrimaryButton(
            text: 'Publish',
            isExpanded: true,
            onPressed: () {
              Navigator.pop(context);
              if (onPublish != null) onPublish!();
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Save as draft button
          SecondaryButton(
            text: 'Save privately',
            isExpanded: true,
            onPressed: () {
              Navigator.pop(context);
              if (onSavePrivate != null) onSavePrivate!();
            },
          ),
        ],
      ),
    );
  }
}

/// Export Option Button
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ExportOption({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
