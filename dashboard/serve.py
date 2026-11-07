#!/usr/bin/env python3
"""Static server for /home/user/dashboard with no-cache HTML (prevents stale previews)."""
import http.server
import socketserver
import os
import re

os.chdir('/home/user/dashboard')

# Bump this when content changes: a NEW path can never be served from an old browser/proxy cache.
VERSION = 'v71'


class Handler(http.server.SimpleHTTPRequestHandler):
    # HTTP/1.1 + keep-alive: required by several reverse-proxy preview hosts
    protocol_version = 'HTTP/1.1'
    server_version = 'DyeHousePreview/1.0'
    sys_version = ''

    def _serve_index(self):
        """Serve index.html directly (200) — no redirect, so bare preview URLs always render."""
        try:
            with open(os.path.join(os.getcwd(), 'index.html'), 'rb') as f:
                body = f.read()
        except OSError:
            self.send_error(404, 'index.html not found')
            return
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        self.end_headers()
        if self.command != 'HEAD':
            self.wfile.write(body)

    def do_GET(self):
        path = self.path.split('?', 1)[0]
        path = re.sub(r'/+$', '/', path)
        if path in ('/', '/index.html', '/index.htm', '/' + VERSION, '/' + VERSION + '/'):
            self._serve_index()
            return
        m = re.match(r'^/v\d+/', path)
        if m:
            rest = path[m.end():]
            if rest in ('', 'index.html'):
                self._serve_index()
                return
            self.path = '/' + rest
        super().do_GET()

    def do_HEAD(self):
        path = self.path.split('?', 1)[0]
        if path in ('/', '/index.html', '/index.htm', '/' + VERSION, '/' + VERSION + '/'):
            self._serve_index()
            return
        super().do_HEAD()

    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        '.js': 'application/javascript',
        '.css': 'text/css',
        '.woff2': 'font/woff2',
        '.ttf': 'font/ttf',
    }

    def end_headers(self):
        path = self.path.split('?', 1)[0]
        if path in ('', '/') or path.endswith('.html'):
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Expires', '0')
        else:
            self.send_header('Cache-Control', 'max-age=86400')
        super().end_headers()

    def log_message(self, fmt, *args):
        pass  # quiet


class ThreadedServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True
    request_queue_size = 64


with ThreadedServer(('0.0.0.0', 8000), Handler) as httpd:
    print('serving /home/user/dashboard on 0.0.0.0:8000 (HTTP/1.1 threaded, no-cache HTML)', flush=True)
    httpd.serve_forever()
