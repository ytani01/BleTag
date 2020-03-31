#!/usr/bin/env python3
#
# (c) 2020 Yoichi Tanibayashi
#
"""
Description
"""
__author__ = 'Yoichi Tanibayashi'
__date__   = '2020'

from NfcType3Id import NfcType3Id
from BleTagPublisher import BleTagPublisher
import threading
import time
from MyLogger import get_logger
import click
CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])


class Nfc2BleTag:
    PUBLISH_SEC = 30
    PUBLISH_INTERVAL = 0.5

    _log = get_logger(__name__, False)

    def __init__(self, debug=False):
        self._dbg = debug
        __class__._log = get_logger(__class__.__name__, self._dbg)
        self._log.debug('')

        self._nfc = NfcType3Id(self.cb_connect, self.cb_release, loop=True,
                               debug=False)

        self._blepub = None
        self._pub_active = False

    def start(self):
        self._log.debug('')
        self._nfc.start()
        self._log.debug('done')

    def end(self):
        self._log.debug('')

        self._pub_active = False
        time.sleep(2)

        self._nfc.end()

        self._log.debug('done')

    def cb_connect(self, nfcid):
        self._log.debug('nfcid=%s', nfcid)

        if self._pub_active:
            self._pub_active = False
            time.sleep(2)

        tagid = self.nfcid2tagid(nfcid)

        pub_th = threading.Thread(target=self.publish, args=(tagid,),
                                  daemon=True)
        pub_th.start()

        return True

    def cb_release(self, id):
        self._log.debug('id=%s', id)
        return True

    def publish(self, tagid):
        self._log.debug('tagid=%s', tagid)

        self._blepub = BleTagPublisher(tagid, debug=False)
        self._blepub.start()

        self._pub_active = True
        n = int(self.PUBLISH_SEC / self.PUBLISH_INTERVAL)
        for i in range(n):
            self._log.debug('i=%d/%d', i, n - 1)

            if not self._pub_active:
                self._log.debug('_pub_active=%s', self._pub_active)
                break

            time.sleep(self.PUBLISH_INTERVAL)

        self._blepub.end()
        self._log.debug('done')

    def nfcid2tagid(self, nfcid):
        self._log.debug('nfcid=%s', nfcid)

        tagid = '24:6f:28:96:34:c2'

        return tagid


class Nfc2BleTagApp:
    _log = get_logger(__name__, False)

    def __init__(self, config, debug=False):
        self._dbg = debug
        __class__._log = get_logger(__class__.__name__, self._dbg)
        self._log.debug('config=%s')

        self._config = config

        self._obj = Nfc2BleTag(debug=self._dbg)

    def main(self):
        self._log.debug('')
        self._obj.start()
        self._log.debug('done')

    def end(self):
        self._log.debug('')
        self._obj.end()
        self._log.debug('done')


@click.command(context_settings=CONTEXT_SETTINGS, help='''
NFC to BLE Tag
''')
@click.option('--config', '-c', 'config', type=str, default='',
              help='config file')
@click.option('--debug', '-d', 'debug', is_flag=True, default=False,
              help='debug flag')
def main(config, debug):
    _log = get_logger(__name__, debug)
    _log.debug('config=%s', config)

    app = Nfc2BleTagApp(config, debug=debug)
    try:
        app.main()
    finally:
        _log.debug('finally')
        app.end()
        _log.debug('done')


if __name__ == '__main__':
    main()
