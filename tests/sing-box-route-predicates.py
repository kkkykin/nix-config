"""Probe Linux process, UID and interface rules using only loopback traffic.

Run with a native sing-box >= 1.13. Requires a default IPv4 interface for the
default_interface_address case. This does not exercise systemd or cross-UID
capabilities; tests/sing-box-hardening.nix checks the service permissions.
"""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import pwd
import re
import socket
import struct
import subprocess
import tempfile
import threading
import time


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"route-predicate-ok")

    def log_message(self, *args):
        pass


def free_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def read_exact(sock, size):
    data = b""
    while len(data) < size:
        chunk = sock.recv(size - len(data))
        if not chunk:
            raise ConnectionError("SOCKS connection closed")
        data += chunk
    return data


def request(proxy_port, destination_port):
    try:
        with socket.create_connection(("127.0.0.1", proxy_port), timeout=1) as sock:
            sock.sendall(b"\x05\x01\x00")
            assert read_exact(sock, 2) == b"\x05\x00"
            sock.sendall(b"\x05\x01\x00\x01\x7f\x00\x00\x01" + struct.pack("!H", destination_port))
            reply = read_exact(sock, 4)
            if reply[1] != 0:
                return False
            address_size = {1: 4, 4: 16}[reply[3]]
            read_exact(sock, address_size + 2)
            sock.sendall(b"GET / HTTP/1.0\r\nHost: localhost\r\n\r\n")
            response = b""
            while chunk := sock.recv(4096):
                response += chunk
            return b"route-predicate-ok" in response
    except OSError:
        return False


executable = os.readlink("/proc/self/exe")
cases = [
    ("process_name", [Path(executable).name], ["missing-process-predicate"]),
    ("process_path", [executable], ["/missing/process-predicate"]),
    ("process_path_regex", ["^" + re.escape(executable) + "$"], ["^/missing/process-predicate$"]),
    ("user", [pwd.getpwuid(os.getuid()).pw_name], ["missing-route-predicate-user"]),
    ("user_id", [os.getuid()], [os.getuid() + 1]),
    ("interface_address", {"lo": ["127.0.0.1/32"]}, {"missing-interface": ["127.0.0.1/32"]}),
    ("default_interface_address", ["0.0.0.0/0"], ["192.0.2.1/32"]),
]

with ThreadingHTTPServer(("127.0.0.1", 0), Handler) as server:
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        for field, matching, missing in cases:
            for expected, value in ((True, matching), (False, missing)):
                with tempfile.TemporaryDirectory(prefix="sing-box-predicate-") as temporary:
                    root = Path(temporary)
                    port = free_port()
                    config = {
                        "log": {"level": "debug"},
                        "inbounds": [{"type": "socks", "listen": "127.0.0.1", "listen_port": port}],
                        "outbounds": [{"type": "direct", "tag": "direct"}],
                        "route": {"rules": [
                            {field: value, "action": "route", "outbound": "direct"},
                            {"action": "reject"},
                        ]},
                    }
                    config_file = root / "config.json"
                    config_file.write_text(json.dumps(config))
                    with (root / "log").open("w+") as log:
                        process = subprocess.Popen([
                            os.environ.get("SING_BOX", "sing-box"), "-D", str(root),
                            "-c", str(config_file), "run",
                        ], stdout=log, stderr=log)
                        try:
                            deadline = time.monotonic() + 5
                            ready = False
                            while time.monotonic() < deadline and process.poll() is None:
                                try:
                                    with socket.create_connection(("127.0.0.1", port), timeout=0.2):
                                        ready = True
                                        break
                                except OSError:
                                    time.sleep(0.02)
                            assert ready, "sing-box did not start"
                            assert request(port, server.server_port) == expected, (field, expected)
                        except BaseException:
                            log.seek(0)
                            print(log.read())
                            raise
                        finally:
                            process.terminate()
                            process.wait(timeout=5)
            print(f"{field}: matching and nonmatching connections passed")
    finally:
        server.shutdown()
        thread.join()
