# -*- coding: utf-8 -*-
"""
Created on Fri Jun 27 17:09:15 2025
author: NZXTP
"""

import asyncio
import sys
from threading import Thread

from kivy.app import App
from kivy.lang import Builder
from kivy.uix.boxlayout import BoxLayout
from kivy.properties import ListProperty, StringProperty
from kivy.utils import platform
from kivy.clock import Clock
from kivy.core.window import Window

# Bluetooth support: try Bleak first, fallback to PyBluez
try:
    from bleak import BleakScanner, BleakClient
    use_bleak = True
except ImportError:
    use_bleak = False
    try:
        import bluetooth
    except ImportError:
        bluetooth = None

KV = '''
<MainLayout>:
    orientation: 'vertical'
    spacing: dp(10)
    padding: dp(10)

    Button:
        text: root.scan_button_text
        size_hint_y: None
        height: '48dp'
        on_press: root.scan_devices()

    Button:
        text: 'Exit'
        size_hint_y: None
        height: '48dp'
        on_press: root.exit_app()

    RecycleView:
        id: rv
        viewclass: 'DeviceButton'
        RecycleBoxLayout:
            default_size: None, dp(48)
            default_size_hint: 1, None
            size_hint_y: None
            height: self.minimum_height
            orientation: 'vertical'

<DeviceButton@Button>:
    text: ''
    size_hint_y: None
    height: '48dp'
'''

class MainLayout(BoxLayout):
    devices = ListProperty([])
    scan_button_text = StringProperty('Scan Bluetooth Devices')

    def scan_devices(self):
        self.devices.clear()
        self.ids.rv.data = []
        self.scan_button_text = 'Scanning…'
        Thread(target=self._scan_thread, daemon=True).start()

    def _scan_thread(self):
        seen = set()
        if platform in ('linux', 'win', 'macosx') and use_bleak:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            scanner = BleakScanner()

            def detection_callback(device, advertisement_data):
                # Prefer advertised local_name, then device.name
                name = getattr(advertisement_data, 'local_name', None) or device.name or 'Unknown'
                entry = f"{name} ({device.address})"
                if entry not in seen:
                    seen.add(entry)
                    Clock.schedule_once(lambda dt, e=entry: self._add_device(e), 0)

            scanner.register_detection_callback(detection_callback)
            try:
                loop.run_until_complete(scanner.start())
                loop.run_until_complete(asyncio.sleep(5.0))
                loop.run_until_complete(scanner.stop())
            except Exception as ex:
                Clock.schedule_once(lambda dt, e=ex: self._add_device(f"Error: {e}"), 0)
            finally:
                loop.close()

            # Post-scan GATT lookup for Unknown entries
            for idx, entry in enumerate(list(self.devices)):
                if entry.startswith('Unknown'):
                    addr = entry.split('(')[-1].strip(')')
                    name = self._gatt_name_lookup(addr)
                    if name:
                        Clock.schedule_once(lambda dt, i=idx, nm=name: self._replace_device(i, nm), 0)

        elif platform in ('linux', 'win', 'macosx') and bluetooth:
            try:
                devices = bluetooth.discover_devices(duration=4, lookup_names=True)
                for addr, n in devices:
                    entry = f"{n or 'Unknown'} ({addr})"
                    if entry not in seen:
                        seen.add(entry)
                        Clock.schedule_once(lambda dt, e=entry: self._add_device(e), 0)
            except Exception as ex:
                Clock.schedule_once(lambda dt, e=ex: self._add_device(f"Error: {e}"), 0)
        else:
            Clock.schedule_once(lambda dt: self._add_device('Bluetooth not supported'), 0)

        Clock.schedule_once(lambda dt: self._end_scan(), 0)

    def _gatt_name_lookup(self, address):
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            client = BleakClient(address, loop=loop)
            loop.run_until_complete(client.connect())
            raw = loop.run_until_complete(
                client.read_gatt_char('00002a00-0000-1000-8000-00805f9b34fb')
            )
            loop.run_until_complete(client.disconnect())
            return raw.decode().strip()
        except Exception:
            return None
        finally:
            loop.close()

    def _add_device(self, entry):
        if entry not in self.devices:
            self.devices.append(entry)
            self.ids.rv.data = [{'text': d} for d in self.devices]

    def _replace_device(self, idx, new_name):
        addr = self.devices[idx].split('(')[-1].strip(')')
        self.devices[idx] = f"{new_name} ({addr})"
        self.ids.rv.data = [{'text': d} for d in self.devices]

    def _end_scan(self):
        self.scan_button_text = 'Scan Bluetooth Devices'

    def exit_app(self):
        App.get_running_app().stop()
        Window.close()

class BluetoothApp(App):
    def build(self):
        Builder.load_string(KV)
        root = MainLayout()
        root.ids.rv.data = []
        return root

if __name__ == '__main__':
    BluetoothApp().run()
