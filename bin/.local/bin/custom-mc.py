#!/usr/bin/env python3
"""$ custom-mc.py [name]
Launch Minecraft with a custom display name, or the default name in this
file if unspecified on the command line.

The relevant part of the profiles file is of the form:
    {
        "authenticationDatabase": {
            <HASH>: {
                "profiles": {
                    <HASH>: {
                        "displayName": <NAME>
                    }
                }
            }
        }
    }
"""

import json
import os.path
import subprocess
import sys

NAME = "TODO enter display name here"
PROFILE_PATH = os.path.expanduser("~/.minecraft/launcher_profiles.json")


def main():
    name = NAME if not sys.argv else sys.argv[0]
    with open(PROFILE_PATH) as file:
        profiles = json.load(file)
    profiles["authenticationDatabase"].values()[0]["profiles"].values()[0]["displayName"] = name
    with open(PROFILE_PATH, "w") as file:
        json.dump(profiles, file)
    subprocess.run("minecraft-launcher")


if __name__ == "__main__":
    main()
