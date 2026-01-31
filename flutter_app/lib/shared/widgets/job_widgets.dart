import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/job_model.dart';
import 'animated_widgets.dart';
import 'badges.dart';

/// Job progress card - shows AI generation progress
class JobProgressCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const JobProgressCard({
    super.key,
    required this.job,
    this.onCancel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _getBorderColor(),
            width: 1.5,
          ),
          boxShadow: AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Provider badge
                _ProviderBadge(provider: job.provider),
                const SizedBox(width: AppSpacing.sm),

                // Status badge
                StatusBadge(
                  label: job.status.displayName,
                  type: _getStatusType(),
                ),

                const Spacer(),

                // Cancel button (if cancellable)
                if (job.isCancellable && onCancel != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onCancel,
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Prompt text
            Text(
              job.prompt,
              style: AppTypography.titleSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.md),

            // Progress section
            if (job.isInProgress) ...[
              _buildProgressSection(isDark),
            ] else if (job.isComplete) ...[
              _buildCompleteSection(isDark),
            ] else if (job.isFailed) ...[
              _buildFailedSection(isDark),
            ],

            // Time info
            const SizedBox(height: AppSpacing.sm),
            Text(
              _getTimeText(),
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stage info
        Row(
          children: [
            PulseAnimation(
              child: Icon(
                _getStageIcon(),
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              job.stage?.displayName ?? 'İşleniyor',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              '${(job.progressValue * 100).toInt()}%',
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Progress bar
        GradientProgressIndicator(
          value: job.progressValue,
          height: 6,
          gradient: AppColors.aiGradient,
        ),
      ],
    );
  }

  Widget _buildCompleteSection(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 16,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Model hazır!',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            'Görüntüle',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailedSection(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            size: 16,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            job.error.isNotEmpty ? job.error : 'Bir hata oluştu',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.error,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getBorderColor() {
    if (job.isInProgress) return AppColors.primary.withValues(alpha: 0.3);
    if (job.isComplete) return AppColors.success.withValues(alpha: 0.3);
    if (job.isFailed) return AppColors.error.withValues(alpha: 0.3);
    return AppColors.border;
  }

  StatusType _getStatusType() {
    switch (job.status) {
      case JobStatus.queued:
      case JobStatus.submitted:
        return StatusType.pending;
      case JobStatus.inProgress:
        return StatusType.info;
      case JobStatus.succeeded:
        return StatusType.success;
      case JobStatus.failed:
        return StatusType.error;
      case JobStatus.cancelled:
        return StatusType.warning;
    }
  }

  IconData _getStageIcon() {
    switch (job.stage) {
      case JobStage.preview:
        return Icons.auto_awesome;
      case JobStage.refine:
        return Icons.tune;
      case JobStage.remesh:
        return Icons.speed;
      default:
        return Icons.hourglass_empty;
    }
  }

  String _getTimeText() {
    final now = DateTime.now();
    final diff = now.difference(job.createdAt);

    if (diff.inSeconds < 60) {
      return 'Az önce başladı';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} dakika önce';
    } else {
      return '${diff.inHours} saat önce';
    }
  }
}

/// Provider badge
class _ProviderBadge extends StatelessWidget {
  final AIProvider provider;

  const _ProviderBadge({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isMeshy = provider == AIProvider.meshy;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        gradient: isMeshy ? AppColors.aiGradient : AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isMeshy ? 'Meshy' : 'Tripo',
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini job progress indicator (for list items)
class MiniJobProgress extends StatelessWidget {
  final Job job;

  const MiniJobProgress({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    if (job.isComplete) {
      return const Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: 20,
      );
    }

    if (job.isFailed) {
      return const Icon(
        Icons.error,
        color: AppColors.error,
        size: 20,
      );
    }

    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        value: job.progressValue,
        strokeWidth: 2,
        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        backgroundColor: AppColors.borderLight,
      ),
    );
  }
}

/// Job queue list
class JobQueueWidget extends StatelessWidget {
  final List<Job> jobs;
  final void Function(Job job)? onJobTap;
  final void Function(Job job)? onJobCancel;

  const JobQueueWidget({
    super.key,
    required this.jobs,
    this.onJobTap,
    this.onJobCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingH,
          ),
          child: Row(
            children: [
              Text(
                'Aktif İşlemler',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${jobs.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...jobs.map((job) => Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.screenPaddingH,
                right: AppSpacing.screenPaddingH,
                bottom: AppSpacing.sm,
              ),
              child: JobProgressCard(
                job: job,
                onTap: () => onJobTap?.call(job),
                onCancel: () => onJobCancel?.call(job),
              ),
            )),
      ],
    );
  }
}

/// Generation steps indicator
class GenerationStepsIndicator extends StatelessWidget {
  final JobStage currentStage;
  final double progress;

  const GenerationStepsIndicator({
    super.key,
    required this.currentStage,
    required this.progress,
  });

  static const _stages = [
    (JobStage.preview, 'Önizleme', Icons.auto_awesome),
    (JobStage.refine, 'İyileştirme', Icons.tune),
    (JobStage.remesh, 'Optimize', Icons.speed),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawIndex = _stages.indexWhere((s) => s.$1 == currentStage);
    final currentIndex = rawIndex < 0 ? 0 : rawIndex;

    return Column(
      children: [
        // Steps row
        Row(
          children: List.generate(_stages.length, (index) {
            final stage = _stages[index];
            final isActive = index == currentIndex;
            final isComplete = index < currentIndex;

            return Expanded(
              child: Row(
                children: [
                  // Step circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.success
                          : isActive
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.cardDark
                                  : AppColors.surface),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isComplete || isActive
                            ? Colors.transparent
                            : AppColors.borderLight,
                        width: 2,
                      ),
                    ),
                    child: isActive
                        ? PulseAnimation(
                            child: Icon(
                              stage.$3,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isComplete ? Icons.check : stage.$3,
                            size: 16,
                            color: isComplete || isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                  ),

                  // Connector line
                  if (index < _stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < currentIndex
                            ? AppColors.success
                            : AppColors.borderLight,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: AppSpacing.md),

        // Current stage label
        Text(
          _stages[currentIndex].$2,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Progress percentage
        Text(
          '${(progress * 100).toInt()}%',
          style: AppTypography.displaySmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
