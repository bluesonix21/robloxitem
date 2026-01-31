import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api/api_config.dart';
import '../../core/services/api_services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/asset_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/inputs.dart';
import '../../shared/widgets/sheets_modals.dart';

/// Asset Detail Screen - Shows full details of a 3D asset
class AssetDetailScreen extends ConsumerStatefulWidget {
  final Asset asset;

  const AssetDetailScreen({
    super.key,
    required this.asset,
  });

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  bool _isFavorite = false;
  bool _is3DMode = true;
  late Asset _asset;
  late final WebViewController _webController;
  bool _viewerReady = false;
  final List<String> _pendingCommands = [];
  AssetFetchResponse? _assetFetch;

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'ViewerBridge',
        onMessageReceived: _onViewerMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _loadAssetPreview(),
        ),
      )
      ..loadFlutterAsset('assets/3d/viewer.html');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // 3D Preview Area
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // 3D Model Viewer
                _build3DViewer(isDark),

                // Top bar with back and actions
                Positioned(
                  top: topPadding + AppSpacing.sm,
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: _buildTopBar(isDark),
                ),

                // View mode toggle
                Positioned(
                  bottom: AppSpacing.md,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildViewModeToggle(isDark),
                  ),
                ),

                // Badges
                Positioned(
                  top: topPadding + 60,
                  left: AppSpacing.md,
                  child: _buildBadges(),
                ),
              ],
            ),
          ),

          // Details Panel
          Expanded(
            flex: 2,
            child: _buildDetailsPanel(isDark, bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _build3DViewer(bool isDark) {
    return Container(
      color: AppColors.meshPreviewBg,
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(isDark: isDark),
          ),
          if (_is3DMode)
            WebViewWidget(controller: _webController)
          else
            _buildTexturePreview(isDark),
          if (_is3DMode && !_viewerReady)
            Container(
              color: Colors.black.withValues(alpha: 0.05),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            left: AppSpacing.md,
            bottom: AppSpacing.md + 50,
            child: PolygonBadge(
              current: _asset.polygonCount ?? 0,
              max: 4000,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTexturePreview(bool isDark) {
    final url = _assetFetch?.textureUrl ?? _asset.textureUrl;
    if (url == null || url.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context).error_notFound,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image),
      ),
    );
  }

  void _onViewerMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type == 'ready') {
        setState(() => _viewerReady = true);
        _flushPendingCommands();
      }
    } catch (_) {
      // ignore malformed messages
    }
  }

  void _enqueueCommand(String script) {
    if (!_viewerReady) {
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

  Future<void> _loadAssetPreview() async {
    final service = ref.read(assetServiceProvider);
    final result = await service.fetchAsset(_asset.id);
    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      _assetFetch = result.data!;
    }

    final meshUrl = _assetFetch?.meshUrl ?? _asset.meshUrl;
    if (meshUrl != null && meshUrl.isNotEmpty) {
      _enqueueCommand(
          'window.viewer && window.viewer.loadModel(${jsonEncode(meshUrl)});');
    }

    final textures = <String, String?>{
      'albedo': _assetFetch?.textureUrl ?? _asset.textureUrl,
      'metalness': _assetFetch?.pbrMetalnessUrl,
      'roughness': _assetFetch?.pbrRoughnessUrl,
      'normal': _assetFetch?.pbrNormalUrl,
    };
    _enqueueCommand(
      'window.viewer && window.viewer.setTextureUrls(${jsonEncode(textures)});',
    );

    setState(() {});
  }

  Widget _buildTopBar(bool isDark) {
    return Row(
      children: [
        // Back button
        _CircleButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.pop(context),
          isDark: isDark,
        ),

        const Spacer(),

        // Favorite button
        _CircleButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _isFavorite = !_isFavorite);
          },
          isDark: isDark,
          iconColor: _isFavorite ? AppColors.error : null,
        ),

        const SizedBox(width: AppSpacing.sm),

        // Share button
        _CircleButton(
          icon: Icons.share_outlined,
          onTap: _showShareSheet,
          isDark: isDark,
        ),

        const SizedBox(width: AppSpacing.sm),

        // More options
        _CircleButton(
          icon: Icons.more_horiz,
          onTap: _showOptionsSheet,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildViewModeToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeButton(
            icon: Icons.view_in_ar,
            label: '3D',
            isActive: _is3DMode,
            onTap: () => setState(() => _is3DMode = true),
          ),
          const SizedBox(width: 4),
          _ViewModeButton(
            icon: Icons.grid_view,
            label: '2D',
            isActive: !_is3DMode,
            onTap: () => setState(() => _is3DMode = false),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_asset.isAIGenerated) ...[
          const AIBadge(),
          const SizedBox(height: AppSpacing.xs),
        ],
        CategoryBadge(category: _asset.categoryLabel),
      ],
    );
  }

  Widget _buildDetailsPanel(bool isDark, double bottomPadding) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                bottomPadding + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _asset.name,
                          style: AppTypography.headlineSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: _asset.status.displayName,
                        type: _getStatusType(),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Date info
                  Builder(builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return Text(
                      '${l10n.common_loading} ${_formatDate(_asset.createdAt)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.lg),

                  // Stats row
                  _buildStatsRow(isDark),

                  const SizedBox(height: AppSpacing.lg),

                  // Prompt (if AI generated)
                  if (_asset.prompt != null) ...[
                    Text(
                      'AI Prompt',
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.backgroundLight,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _asset.prompt!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _asset.prompt!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)
                                        .common_success)),
                              );
                            },
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Action buttons
                  _buildActionButtons(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.view_in_ar,
          label: AppLocalizations.of(context).create_estimatedCost,
          value: '${_asset.polygonCount ?? 0}',
          isDark: isDark,
        ),
        const SizedBox(width: AppSpacing.lg),
        _StatItem(
          icon: Icons.category,
          label: AppLocalizations.of(context).create_category,
          value: _asset.categoryLabel,
          isDark: isDark,
        ),
        const SizedBox(width: AppSpacing.lg),
        _StatItem(
          icon: Icons.auto_awesome,
          label: AppLocalizations.of(context).common_all,
          value: _asset.isAIGenerated ? 'AI' : 'Manuel',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Primary action
        PrimaryButton(
          text: _asset.status == AssetStatus.published
              ? 'View on Roblox'
              : 'Publish to Roblox',
          onPressed: _asset.status == AssetStatus.published
              ? _openRobloxPreview
              : _startPublishFlow,
          icon: _asset.status == AssetStatus.published
              ? Icons.open_in_new
              : Icons.cloud_upload,
        ),

        const SizedBox(height: AppSpacing.sm),

        // Secondary actions
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Edit',
                onPressed: () => context.push('/editor/${_asset.id}'),
                icon: Icons.edit,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SecondaryButton(
                text: 'Download',
                onPressed: _downloadAsset,
                icon: Icons.download,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(
          text: 'Upload File',
          isExpanded: true,
          onPressed: _showUploadSheet,
          icon: Icons.cloud_upload,
        ),
      ],
    );
  }

  StatusType _getStatusType() {
    switch (_asset.status) {
      case AssetStatus.draft:
        return StatusType.pending;
      case AssetStatus.processing:
        return StatusType.warning;
      case AssetStatus.completed:
        return StatusType.success;
      case AssetStatus.published:
        return StatusType.info;
      case AssetStatus.failed:
        return StatusType.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _refreshAssetRecord() async {
    final repo = ref.read(assetRepositoryProvider);
    final updated = await repo.fetchAssetById(_asset.id);
    if (updated != null && mounted) {
      setState(() {
        _asset = updated;
      });
    }
    await _loadAssetPreview();
  }

  Future<void> _openRobloxPreview() async {
    final url = ApiConfig.buildRobloxDeepLink(_asset.id);
    final success = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Roblox')),
      );
    }
  }

  Future<void> _downloadAsset() async {
    final service = ref.read(assetServiceProvider);
    final result = await service.fetchAsset(_asset.id);
    if (result.isError || result.data == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'İndirme başarısız')),
        );
      }
      return;
    }
    final response = result.data!;
    final url = response.meshUrl ?? response.textureUrl;
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No downloadable file available')),
        );
      }
      return;
    }
    final success = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open download link')),
      );
    }
  }

  void _showUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _UploadFilesSheet(
        assetId: _asset.id,
        onUploaded: _refreshAssetRecord,
      ),
    );
  }

  Future<void> _startPublishFlow() async {
    if (!_asset.hasMesh) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model must be created first')),
      );
      return;
    }
    if (!_asset.isRobloxValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Polygon limit not suitable for Roblox')),
      );
      return;
    }

    final payload = await _showPublishSheet();
    if (payload == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingOverlay(message: 'Uploading to Roblox...'),
    );

    final success = await ref.read(publishProvider.notifier).publish(
          assetId: _asset.id,
          name: payload.name,
          description: payload.description,
          assetType: payload.assetType,
          creatorUserId: payload.creatorUserId,
        );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      setState(() {
        _asset = _asset.copyWith(status: AssetStatus.published);
      });
      await ResultModal.showSuccess(
        context: context,
        title: 'Published',
        message: 'Roblox upload completed.',
      );
    } else {
      final error = ref.read(publishProvider).error;
      await ResultModal.showError(
        context: context,
        title: 'Upload Failed',
        message: error ?? 'Roblox upload could not be completed.',
      );
    }
    ref.read(publishProvider.notifier).reset();
  }

  Future<_PublishPayload?> _showPublishSheet() async {
    final nameController = TextEditingController(text: _asset.name);
    final descriptionController =
        TextEditingController(text: _asset.description ?? '');
    final assetTypeController = TextEditingController(text: 'Model');
    final creatorController = TextEditingController();
    String? creatorError;

    try {
      return await AppBottomSheet.show<_PublishPayload>(
        context: context,
        title: 'Publish to Roblox',
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Title',
                  controller: nameController,
                  hintText: 'Roblox item name',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Description',
                  controller: descriptionController,
                  hintText: 'Short description',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Asset Type',
                  controller: assetTypeController,
                  hintText: 'e.g., Model',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Creator User ID',
                  controller: creatorController,
                  hintText: 'Roblox user ID',
                  keyboardType: TextInputType.number,
                  errorText: creatorError,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Roblox upload requires 750 Robux fee.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  text: 'Publish',
                  onPressed: () {
                    final creatorId =
                        int.tryParse(creatorController.text.trim());
                    if (creatorId == null) {
                      setState(() => creatorError = 'Valid ID required');
                      return;
                    }
                    Navigator.pop(
                      context,
                      _PublishPayload(
                        name: nameController.text.trim().isEmpty
                            ? _asset.name
                            : nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        assetType: assetTypeController.text.trim().isEmpty
                            ? 'Model'
                            : assetTypeController.text.trim(),
                        creatorUserId: creatorId,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      assetTypeController.dispose();
      creatorController.dispose();
    }
  }

  Future<void> _deleteAsset() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingOverlay(message: 'Siliniyor...'),
    );
    try {
      await ref.read(assetRepositoryProvider).deleteAsset(_asset);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ref.invalidate(userAssetsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Design deleted')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed')),
      );
    }
  }

  void _showShareSheet() {
    ActionSheet.show(
      context: context,
      title: 'Share',
      actions: [
        ActionSheetItem(
          icon: Icons.link,
          title: 'Copy Link',
          onTap: () {
            Navigator.pop(context);
            final url = ApiConfig.buildRobloxDeepLink(_asset.id);
            Clipboard.setData(ClipboardData(text: url));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link copied')),
            );
          },
        ),
        ActionSheetItem(
          icon: Icons.image,
          title: 'Share as Image',
          onTap: () {
            Navigator.pop(context);
            final imageUrl = _asset.textureUrl ?? _asset.thumbnailUrl;
            if (imageUrl == null || imageUrl.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No shareable image available')),
              );
              return;
            }
            Share.share(imageUrl, subject: _asset.name);
          },
        ),
        ActionSheetItem(
          icon: Icons.share,
          title: 'Other Apps',
          onTap: () {
            Navigator.pop(context);
            final url = ApiConfig.buildRobloxDeepLink(_asset.id);
            Share.share(url, subject: _asset.name);
          },
        ),
      ],
      cancelText: 'İptal',
    );
  }

  void _showOptionsSheet() {
    ActionSheet.show(
      context: context,
      title: 'Options',
      actions: [
        ActionSheetItem(
          icon: Icons.edit,
          title: 'Edit',
          subtitle: 'Open in 3D editor',
          onTap: () {
            Navigator.pop(context);
            context.push('/editor/${_asset.id}');
          },
        ),
        ActionSheetItem(
          icon: Icons.copy,
          title: 'Copy',
          subtitle: 'Create new from this design',
          onTap: () {
            Navigator.pop(context);
            final text = _asset.prompt ?? _asset.name;
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied')),
            );
          },
        ),
        ActionSheetItem(
          icon: Icons.download,
          title: 'Download',
          subtitle: 'GLB/FBX format',
          onTap: () {
            Navigator.pop(context);
            _downloadAsset();
          },
        ),
        ActionSheetItem(
          icon: Icons.delete_outline,
          title: 'Sil',
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);
            _showDeleteConfirmation();
          },
        ),
      ],
      cancelText: 'İptal',
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Design'),
        content: const Text(
          'This design will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAsset();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _UploadFilesSheet extends ConsumerStatefulWidget {
  final String assetId;
  final VoidCallback? onUploaded;

  const _UploadFilesSheet({
    required this.assetId,
    this.onUploaded,
  });

  @override
  ConsumerState<_UploadFilesSheet> createState() => _UploadFilesSheetState();
}

class _UploadFilesSheetState extends ConsumerState<_UploadFilesSheet> {
  bool _isUploading = false;
  double _progress = 0.0;
  String? _currentLabel;

  Future<void> _pickAndUpload({
    required String label,
    required List<String> allowedExtensions,
    required void Function(String path) onPathResolved,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result == null || result.files.isEmpty) return;

    final fileInfo = result.files.first;
    if (fileInfo.path == null) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session not found')),
        );
      }
      return;
    }

    final storage = ref.read(storageServiceProvider);
    final repo = ref.read(assetRepositoryProvider);

    setState(() {
      _isUploading = true;
      _progress = 0.0;
      _currentLabel = label;
    });

    try {
      final file = File(fileInfo.path!);
      final objectPath = storage.buildAssetObjectPath(
        userId: userId,
        assetId: widget.assetId,
        fileName: fileInfo.name,
        prefix: label.toLowerCase().replaceAll(' ', '_'),
      );

      final result = await storage.uploadResumableFile(
        file: file,
        bucket: 'assets',
        objectPath: objectPath,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _progress = progress.clamp(0.0, 1.0);
          });
        },
      );

      onPathResolved(result.path);

      await repo.updateAssetPaths(
        widget.assetId,
        meshPath: label == 'Mesh' ? result.path : null,
        texturePath: label == 'Texture' ? result.path : null,
        metalnessPath: label == 'Metalness' ? result.path : null,
        roughnessPath: label == 'Roughness' ? result.path : null,
        normalPath: label == 'Normal' ? result.path : null,
      );

      widget.onUploaded?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label yüklendi.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label yüklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _progress = 0.0;
          _currentLabel = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.base,
        left: AppSpacing.sheetPadding,
        right: AppSpacing.sheetPadding,
        bottom: bottomPadding + AppSpacing.base,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Upload File',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Upload mesh and texture files.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _UploadTile(
            label: 'Mesh',
            subtitle: 'glb, gltf, fbx',
            icon: Icons.view_in_ar,
            onTap: _isUploading
                ? null
                : () => _pickAndUpload(
                      label: 'Mesh',
                      allowedExtensions: const ['glb', 'gltf', 'fbx'],
                      onPathResolved: (_) {},
                    ),
          ),
          _UploadTile(
            label: 'Texture',
            subtitle: 'png, jpg',
            icon: Icons.image,
            onTap: _isUploading
                ? null
                : () => _pickAndUpload(
                      label: 'Texture',
                      allowedExtensions: const ['png', 'jpg', 'jpeg'],
                      onPathResolved: (_) {},
                    ),
          ),
          _UploadTile(
            label: 'Metalness',
            subtitle: 'png, jpg',
            icon: Icons.blur_circular,
            onTap: _isUploading
                ? null
                : () => _pickAndUpload(
                      label: 'Metalness',
                      allowedExtensions: const ['png', 'jpg', 'jpeg'],
                      onPathResolved: (_) {},
                    ),
          ),
          _UploadTile(
            label: 'Roughness',
            subtitle: 'png, jpg',
            icon: Icons.texture,
            onTap: _isUploading
                ? null
                : () => _pickAndUpload(
                      label: 'Roughness',
                      allowedExtensions: const ['png', 'jpg', 'jpeg'],
                      onPathResolved: (_) {},
                    ),
          ),
          _UploadTile(
            label: 'Normal',
            subtitle: 'png, jpg',
            icon: Icons.grain,
            onTap: _isUploading
                ? null
                : () => _pickAndUpload(
                      label: 'Normal',
                      allowedExtensions: const ['png', 'jpg', 'jpeg'],
                      onPathResolved: (_) {},
                    ),
          ),
          if (_isUploading) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              _currentLabel != null
                  ? 'Uploading $_currentLabel...'
                  : 'Uploading...',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(value: _progress),
          ],
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _UploadTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.upload),
    );
  }
}

class _PublishPayload {
  final String name;
  final String description;
  final String assetType;
  final int creatorUserId;

  const _PublishPayload({
    required this.name,
    required this.description,
    required this.assetType,
    required this.creatorUserId,
  });
}

/// Circle button for top bar
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ??
              (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          size: 22,
        ),
      ),
    );
  }
}

/// View mode toggle button
class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

/// Grid painter for 3D view background
class _GridPainter extends CustomPainter {
  final bool isDark;

  _GridPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
