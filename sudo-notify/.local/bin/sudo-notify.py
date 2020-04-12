#!/usr/bin/env python3
"""Background service to notify sudo request before it times out."""


from subprocess import CalledProcessError, check_output, run
from time import sleep
from typing import List

# A little less than when sudo is expected to time out, in seconds.
TIMEOUT = 10 * 60


def pids(process_name: str) -> List[int]:
    """Return the PIDs of a `process_name`."""
    try:
        return [
            int(pid) for pid in check_output(["pidof", process_name]).split()
        ]
    except CalledProcessError:
        return []


if __name__ == '__main__':
    while True:
        first_pids = pids("sudo")
        sleep(TIMEOUT)
        second_pids = pids("sudo")
        new_pids = not all(pid in first_pids for pid in second_pids)
        if new_pids:
            run(["notify-send", "Sudo requested", "-u", "critical"])
