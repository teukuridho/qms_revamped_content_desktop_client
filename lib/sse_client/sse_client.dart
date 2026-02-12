// Public entrypoint for SSE client.
//
// Use:
//   import 'package:qms_revamped_content_desktop_client/sse_client/sse_client.dart';

export 'src/sse_client_base.dart';
export 'src/sse_client_io.dart'
    if (dart.library.html) 'src/sse_client_web.dart';
export 'src/sse_frame.dart';
export 'src/sse_incremental_id.dart';
export 'src/sse_value_parser.dart';
