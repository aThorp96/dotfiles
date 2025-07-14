#!/usr/bin/env python3

import sys
import httpx
from parsel import Selector
from urllib.parse import urljoin
import os

def __main__():
    base_url = sys.argv[1]
    destination = sys.argv[2]

    urls = [(base_url, destination)]
    excluded_dirs = ["OLD", "go", "venv"]

    for (url, dir) in urls:
        try:
            os.mkdir(dir)
        except FileExistsError:
            pass

        sel = Selector(str(httpx.get(url, verify=False).content))
        for link in sel.xpath("//tr//a/@href").getall():
            full_url = urljoin(url, link)
            path = os.path.join(dir, link)

            if link.startswith("?") or link.startswith("/"):
                # Ignore sorting and parent-dir links
                pass
            elif len([d for d in excluded_dirs if link == f"{d}/"]) > 0:
                pass
            elif link.endswith("/"):
                # New diretory - enqueue
                urls.append((full_url, path))
            else:
                print(path)
                resp = httpx.get(full_url, verify=False)
                with open(path, "wb") as f:
                    f.write(resp.content)

if __name__ == "__main__":
    __main__()
