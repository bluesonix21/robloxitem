import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class DeepLinkListener extends ConsumerStatefulWidget {
  final Widget child;

  const DeepLinkListener({super.key, required this.child});

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initLinks();
  }

  Future<void> _initLinks() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      _handleLink(initial);
    }

    _sub = _appLinks.uriLinkStream.listen(_handleLink);
  }

  void _handleLink(Uri uri) {
    if (uri.scheme != 'robloxugc') {
      return;
    }

    final path = uri.host.isNotEmpty ? uri.host : (uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '');
    if (path != 'oauth') {
      return;
    }

    final status = uri.queryParameters['status'];
    final message = uri.queryParameters['message'];
    final notifier = ref.read(robloxOAuthProvider.notifier);

    if (status == 'success') {
      ref.read(robloxConnectionProvider.notifier).loadProfile();
      notifier.success();
    } else if (status == 'error') {
      notifier.error(message);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
