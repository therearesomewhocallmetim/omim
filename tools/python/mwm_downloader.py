from __future__ import print_function

import json
import logging
from os import makedirs
from os.path import join, exists
from argparse import ArgumentParser
from Util import find_omim

from shutil import rmtree
import subprocess

logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)

LAST_DOWNLOADED_URL_FILE = "last_downloaded.url"


class MwmDownloader:
    def __init__(self, omim_root, url):
        self.omim_root = omim_root
        self.datapath = join(self.omim_root, "..", "data")
        self.url_path = join(self.datapath, LAST_DOWNLOADED_URL_FILE)
        self.link = url


    def read_url_from_file(self, url_file):
        with open(url_file, "r") as the_file:
            return the_file.readline()


    def should_download(self):
        if not exists(self.datapath):
            return True

        if not exists(self.url_path):
            return True

        if self.read_url_from_file(self.url_path) != self.link:
            return True

        return False


    def _delete_all_data(self):
        if exists(self.datapath):
            rmtree(self.datapath)
        makedirs(self.datapath)


    def _download_new_data(self):
        process = subprocess.Popen(
            "wget -nv --recursive --no-parent --no-directories --directory-prefix={prefix} {link}".format(
                prefix=self.datapath, link=self.link
            ),
            shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )

        downloaded = 0

        while True:
            line = process.stderr.readline()
            if not line:
                break
            downloaded += 1
            logging.debug("{downloaded} >> {line}".format(downloaded=downloaded, line=line))

        with open(self.url_path, "w") as url_file:
            url_file.write(self.link)


    def download(self):
        if self.should_download():
            self._delete_all_data()
            self._download_new_data()


def process_cli():
    parser = ArgumentParser()
    parser.add_argument("-u", "--url", dest="link", help="The url from which the MWMs should be downloaded")

    args = parser.parse_args()
    return args


def link_from_countries_txt(omim_root):
    with open(join(omim_root, "data", "countries.txt")) as countries:
        data = json.load(countries)

    version = data["v"]
    return "http://direct.mapswithme.com/direct/{}/".format(version)


if __name__ == "__main__":
    omim_root = find_omim()
    args = process_cli()
    link = args.link or link_from_countries_txt(omim_root)

    d = MwmDownloader(omim_root, link)
    d.download()
