#!/usr/bin/env python3
#
# (c) 2020 Yoichi Tanibayashi
#
"""
BLE Tag ID Publisher
"""
__author__ = 'Yoichi Tanibayashi'
__date__   = '2020/03'

from BlePeripheral import BlePeripheral, BlePeripheralApp
from MyLogger import get_logger  # DEBUG, INFO, WARNING, ERROR, CRITICAL
import threading
import time
import click
CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])


class BleTagPublisher(BlePeripheral):
    MYNAME = 'Yt'
    TAGID_PREFIX = 'T'

    _log = get_logger(__name__, False)

    def __init__(self, tagid, debug=False):
        self._dbg = debug
        __class__._log = get_logger(__class__.__name__, self._dbg)
        self._log.debug('tagid=%s', tagid)

        self._tagid = tagid

        self._myname = self.MYNAME
        self._ms_data = (self.TAGID_PREFIX + self._tagid).encode('utf-8')
        self._log.debug('_ms_data=%a', self._ms_data)

        super().__init__(self._myname, [], self._ms_data, debug=self._dbg)

    def start(self):
        super().start()

    def end(self):
        super().end()


class BleTagPublisherApp(BlePeripheralApp):
    _log = get_logger(__name__, False)

    def __init__(self, tagid, count, debug=False):
        self._dbg = debug
        __class__._log = get_logger(__class__.__name__, self._dbg)
        self._log.debug('tagid=%s, count=%s', tagid, count)

        self._tagid = tagid
        self._count = count

        self._ble = BleTagPublisher(self._tagid, debug=self._dbg)

        self._input_th = threading.Thread(target=self.input_loop,
                                          daemon=True)

    def main(self):
        self._log.debug('')

        self._active = True

        self._ble.start()
        self._input_th.start()
        count = 0
        while self._active and count < self._count:
            time.sleep(1)
            count += 1
            self._log.debug('count=%d/%d', count, self._count)

        self._log.debug('done')

    def input_loop(self):
        self._log.debug('')

        while True:
            try:
                s = input().strip()
                self._log.debug('s=%a', s)

            except EOFError:
                self._log.info('[EOF]')
                break

            if s.lower() in ['quit', 'exit', 'stop', 'end', '']:
                break

        self.end()
        self._log.debug('done')

    def end(self):
        self._active = False
        self._ble.end()


@click.command(context_settings=CONTEXT_SETTINGS, help='')
@click.argument('tagid', type=str)
@click.option('--count', '-c', 'count', type=int, default=20,
              help='loop count')
@click.option('--debug', '-d', 'debug', is_flag=True, default=False,
              help='debug flag')
def main(tagid, count, debug):
    _log = get_logger(__name__, debug)
    _log.debug('tagid=%s, count=%s', tagid, count)

    app = BleTagPublisherApp(tagid, count, debug=debug)
    try:
        app.main()
    finally:
        _log.debug('finally')
        app.end()
        _log.debug('done')


if __name__ == '__main__':
    main()
