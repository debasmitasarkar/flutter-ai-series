# Tiny static server that serves <root>/live (a symlink you swap to "deploy").
#   python3 serve.py naive  8081 <root>   every file except index.html cached for a day
#   python3 serve.py hashed 8082 <root>   index.html + flutter_bootstrap.js revalidate,
#                                         content-hashed files immutable for a year
import http.server, os, re, sys

mode, port, root = sys.argv[1], int(sys.argv[2]), sys.argv[3]


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        path = self.path.split('?')[0]
        if path in ('/', '/index.html') or (mode == 'hashed' and path == '/flutter_bootstrap.js'):
            cache = 'no-cache'
        elif mode == 'hashed' and re.search(r'\.[0-9a-f]{8}(\.|$)', path):
            cache = 'public, max-age=31536000, immutable'
        elif mode == 'hashed':
            cache = 'no-cache'
        else:
            cache = 'public, max-age=86400'
        self.send_header('Cache-Control', cache)
        super().end_headers()

    def translate_path(self, path):
        live = os.path.realpath(os.path.join(root, 'live'))
        full = os.path.join(live, path.split('?')[0].split('#')[0].lstrip('/'))
        return os.path.join(full, 'index.html') if os.path.isdir(full) else full

    def log_message(self, fmt, *args):
        # One line per request that actually reached the server.
        sys.stderr.write(f'{mode} {self.path}\n')
        sys.stderr.flush()


os.chdir(root)
http.server.ThreadingHTTPServer(('127.0.0.1', port), Handler).serve_forever()
