import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class SafeWebviewScaffold extends StatefulWidget {
  const SafeWebviewScaffold({
    required Key key,
    required this.appBar,
    required this.url,
    required this.headers,
    required this.withJavascript,
    required this.clearCache,
    required this.clearCookies,
    required this.enableAppScheme,
    required this.userAgent,
    this.primary = true,
    required this.persistentFooterButtons,
    required this.bottomNavigationBar,
    required this.withZoom,
    required this.withLocalStorage,
    required this.withLocalUrl,
    required this.scrollBar,
    required this.supportMultipleWindows,
    required this.appCacheEnabled,
     this.hidden = false,
    required this.initialChild,
    required this.allowFileURLs,
    this.geolocationEnabled = false,
  }) : super(key: key);

  final PreferredSizeWidget appBar;
  final String url;
  final Map<String, String> headers;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final List<Widget> persistentFooterButtons;
  final Widget bottomNavigationBar;
  final bool withZoom;
  final bool withLocalStorage;
  final bool withLocalUrl;
  final bool scrollBar;
  final bool supportMultipleWindows;
  final bool appCacheEnabled;
  final bool hidden;
  final Widget initialChild;
  final bool allowFileURLs;
  final bool geolocationEnabled;

  @override
  _SafeWebviewScaffoldState createState() => _SafeWebviewScaffoldState();
}

class _SafeWebviewScaffoldState extends State<SafeWebviewScaffold> {
  final webviewReference = FlutterWebviewPlugin();
  late Rect _rect;
  late Timer _resizeTimer;
  late StreamSubscription<WebViewStateChanged> _onStateChanged;

  @override
  void initState() {
    super.initState();
    webviewReference.close();

    if (widget.hidden) {
      _onStateChanged =
          webviewReference.onStateChanged.listen((WebViewStateChanged state) {
        if (state.type == WebViewState.finishLoad) {
          webviewReference.show();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _resizeTimer?.cancel();
    webviewReference.close();
    if (widget.hidden) {
      _onStateChanged.cancel();
    }
    webviewReference.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      persistentFooterButtons: widget.persistentFooterButtons,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: SafeArea(
        child: _WebviewPlaceholder(
          onRectChanged: (Rect value) {
            if (_rect == null) {
              _rect = value;
              webviewReference.launch(
                widget.url,
                headers: widget.headers,
                withJavascript: widget.withJavascript,
                clearCache: widget.clearCache,
                clearCookies: widget.clearCookies,
                enableAppScheme: widget.enableAppScheme,
                userAgent: widget.userAgent,
                rect: _rect,
                withZoom: widget.withZoom,
                withLocalStorage: widget.withLocalStorage,
                withLocalUrl: widget.withLocalUrl,
                scrollBar: widget.scrollBar,
                supportMultipleWindows: widget.supportMultipleWindows,
                appCacheEnabled: widget.appCacheEnabled,
                allowFileURLs: widget.allowFileURLs,
                geolocationEnabled: widget.geolocationEnabled,
              );
            } else {
              if (_rect != value) {
                _rect = value;
                _resizeTimer?.cancel();
                _resizeTimer = Timer(const Duration(milliseconds: 250), () {
                  // avoid resizing to fast when build is called multiple time
                  webviewReference.resize(_rect);
                });
              }
            }
          },
          child: widget.initialChild ??
              const Center(child: const CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _WebviewPlaceholder extends SingleChildRenderObjectWidget {
  const _WebviewPlaceholder({
    Key? key,
    required this.onRectChanged,
    required Widget child,
  }) : super(key: key, child: child);

  final ValueChanged<Rect> onRectChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _WebviewPlaceholderRender(
      onRectChanged: onRectChanged, child: null,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _WebviewPlaceholderRender renderObject) {
    renderObject..onRectChanged = onRectChanged;
  }
}

class _WebviewPlaceholderRender extends RenderProxyBox {
  _WebviewPlaceholderRender({
    RenderBox? child,
    ValueChanged<Rect>? onRectChanged,
  })  : _callback = onRectChanged!,
        super(child);

  ValueChanged<Rect> _callback;
  Rect _rect;

  Rect get rect => _rect;

  set onRectChanged(ValueChanged<Rect> callback) {
    if (callback != _callback) {
      _callback = callback;
      notifyRect();
    }
  }

  void notifyRect() {
    if (_callback != null && _rect != null) {
      _callback(_rect);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final rect = offset & size;
    if (_rect != rect) {
      _rect = rect;
      notifyRect();
    }
  }
}
