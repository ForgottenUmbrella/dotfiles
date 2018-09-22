var plasma = getApiVersion(1);

var layout = {
    "desktops": [
        {
            "applets": [
            ],
            "config": {
                "/": {
                    "formfactor": "0",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/ConfigDialog": {
                    "DialogHeight": "540",
                    "DialogWidth": "720"
                },
                "/General": {
                    "ToolBoxButtonY": "13"
                },
                "/Wallpaper/org.kde.image/General": {
                    "Image": "/home/leo/Pictures/Wallpapers/adwaita-day.jpeg"
                }
            },
            "wallpaperPlugin": "org.kde.image"
        }
    ],
    "panels": [
        {
            "alignment": "left",
            "applets": [
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/Configuration/General": {
                            "favoritesPortedToKAstats": "true"
                        }
                    },
                    "plugin": "org.kde.plasma.kickerdash"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/Configuration/General": {
                            "length": "804"
                        }
                    },
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/Configuration/Appearance": {
                            "showDate": "true"
                        },
                        "/Configuration/ConfigDialog": {
                            "DialogHeight": "540",
                            "DialogWidth": "720"
                        }
                    },
                    "plugin": "org.kde.plasma.digitalclock"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/Configuration/General": {
                            "length": "649"
                        }
                    },
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        }
                    },
                    "plugin": "org.kde.plasma.systemtray"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "2",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/ConfigDialog": {
                    "DialogHeight": "84",
                    "DialogWidth": "1920"
                }
            },
            "height": 1.5555555555555556,
            "hiding": "normal",
            "location": "top",
            "maximumLength": 106.66666666666667,
            "minimumLength": 106.66666666666667,
            "offset": 0
        },
        {
            "alignment": "center",
            "applets": [
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/Configuration/General": {
                            "launchers": "applications:firefox-nightly.desktop,file:///usr/bin/nautilus?iconData=iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAGuElEQVRogcWZy4scRRzHP7-anZmdbDCYh0lE8zbxaFiUBETxoCLR5KD4wLMXUQ8BDyLC3hRP6sWbqIgK-heIqEQ9iIoeFCGIuiquJjHE5z6mu34eqqqrumd2u3e3Ewt6q6a6uvr7rd-7V2jaZmbMkbmDb2TW3tv4mVU26Zg3P91x-kFmZmzjZxqtmpkxR-YOvX5w79YTx2--drJnDMaAGDBiEBQQFCVXRS2oQq6QW_c7t4pVxVpLbsEqrreWXJUsh1Offjs_O3fund3nu3e_9da9eTsEPPgDu7eeOH7TtZOLmdt3oiOIuL4jgoig6gjkVrEetAMOea4FiTDOrZBbJcsVERj0DR99_v387C9n39mw88p7Ppi5JauD12kCfv-uLSfuuPHQ5PwwJ1dFwJ25CKigCKj6HicaLxXBSQNxY1RR_1xY7qaVYQb7rt7S_fOvpd3n5n6bvuauR9_-4YNXVlSniZVu3vDrodf27dpy_Najhyb_XshAwRgBoxgUxWBFMVYwooiYAKcAhoAIiLp5MYKx6vArGHB_VMgs_LuQcfTw3oGit83O_foacP-aCfQ68sBDJ65jmFus7a20tNVmjHB4_-HBUy--dx_rIbA4zPj46wv8_tcSxggdcZsbgY4RjAEj7rcxUhiUAtYbc67OHqzvi99WydX11ht7WJdb2HZZj8VhrQmsTCCAUXUDdaqOivMiaFghqHWGGB5yJPx6Yh90S9N36Phxk1ZPQJ0-f_LVT6vbeaU9a-4f3LOzdk1oDQi4y6py-w17vfsM6iL-1NPe3_G9-iNVL0b1YnASUS8lRdWS5fDuZz8Uz7RDIAFx5s9ipvELltsTTwCNUlaVyqL61kgCdn14417-TwE8zPlYHpzvauygsQqttRUSVCkBL-75lxTOophv9tJaAtbr_1qAF2D9qUd7kPHAk75FI9ZVqdA4NYmgxEvDJsClMGhSAm3agNYwUGD-x1P88_179HdOM7X_zgpwWPz5FAuz79PdMc3kvmOJ4fpUJ0iF4JVaImBXMOL0tP-d_Yhnn36GJ596ggu_n473wz6LF3j85Emee-F5dNdtqJmIQc4zDXq_0jvXQGBUhcZ7E8tgMODll14ly4YMh0OybInh0I3zPCPLMkSEPM8QmUjUypYjsyfUCgH1eUvYszBGleT0wGzazyOPPVz_xo27mDB9n4pE_5_GG2vbVCGiBGzqRcLY_-nvPcbStutLp6lRPPiSgc6GK7AhImuqPmUv1J4KJRIIm6axWL0iT_Sn6HT3EOCPuEQ_UCMufUi9VNKH97QYB1zaC84bVb0L3jUq6k9ZivlI1-u6ANZ7GdGEXNwzHEprEtBlJBCDU5hL1aoctBiz3gbvme7h14Y0vBUCqUv75rvZZruus1mNB1DXmrlRq-zcvt3Vtq4WL6XRpU8b6Q8tD0uptMa5oDLF2EYJtUDAXWfPnBkPcq1t2QNWNl2-rU0v5L7hKJeuoLHa1Aet0gYuRkET1MbNedK2eQbcrKBpqaIZAV78lkIKEL9gNGm1BNz3zTVjjimCL2hKwCUGwpBSgJN4UzNrZAPrK2iivkewPmbYxBMFongPJ80o1BIQaR5UxgKvpBSqaZCrBEC_Vgqn0AaBxLMsC1ph_idf0OyYZsOBOyvAlcWfP2Thx_fpbZ-mFwqakmdKvvRWY8u6CMjy0kxzl7Sg-eP86einQuqwlBY0t6LSdadfJHU2kUBjDaonEDZcDnjU4dUUNDnS6ZbdaPhmD7USXxUBJ4EQlKIOqy_Gw7ysoqCZNL0YrIId2GgbQjsqJNXNrEZ9DYW3O0Whv-cYS1uvx2ITEaU5kJswgyvI_T1HvmzQMKI-iWyaEygdQtgwfm3WMjhVOv0pBt3d2AJMIJCUhwoq_jOKD1rp58QiA5WS4ygXFjUEwmLjL5f3-M3KtbEHL4kt-MfLyUY654l7nY95UdhozOm5f4NZf40QSQmk4DtAN50cAZ76-aQoLz6OJNFVkghcqKDVEim8KrpDK724Bwz92FJRqaoEUvCTbrMYVC5VQVOJPYPK7VJiEwgEzsbP9YEpiF5o8-btAOF8Y9Oxw2WAVQcRcLqookJTRK1MtVNTAmHbIIE-sDHcuGpzvwZk8_xdqugZ4VOd3Ags-SvHSWCsCqVSMEBPrV34_MsvJhtia7-pXcCpc8A0EiIk6YP6dIENwCbgMpwOdiprLxrkpM-BBeAPf83jpJCRSCEFlapQF6dGXRyp8B_sS9ksDuwQWPR9qkIlAmEcSAjx1C_mide1ADT3fQk8jIKrqsn_CT40XaYH4D_RuTLDSIc1eAAAAABJRU5ErkJggg%3D%3D,file:///usr/lib/gnome-terminal/gnome-terminal-server?iconData=iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFrklEQVRoge2ZvW8cRRjGn7kPny_n89qRYuqIOuFvALrEHwgHiIKCSGEokoZ_IaJC6SggWEK2-FZsHMctKUmPSxS5QNztmcJS4jvfnW9vXoqdmZ2dj921o0iR4ik89n6883vf531m987A2Tgbr_dg5oG79-7tlkvlSwCBCAAIJE8SqVmeUz_lD0rdEV8n75NnVBhKzfL-ZClKViAgisa7X3159y2dt2Im8PfTp5e6vZ4dXIM2ZwWtzSAJa88WvH5fKr62NoDm1NRlk9dKQMG7oPLgXUn7kiiSmJYgQHj-_NDEtRMoDJ-5cHaChdTxrJ2bgAs-3Rb5quh976yoDz5rbRU_TwEY8mb0uRW8YFuc2E_SD0USeBXM6mJQ9-YqUAT-JZs1iyE3AVcv-xd-eWZ1FtBhArcCr4RZ3QU0R8k64oAnV1AtuIR9Y-4CvrhzG81mM4llXp8LL9pOtR_JqjoVsBLI3EI9ppUVv768jDcvXsTtlRU0Gg2HYjGIDqYD-55BegELKGD0sph9vawUIMLq-jr-abUwN3cBdz7_DM3pKc0rSaIpVQx1LXhpbnV9ngIatPpbACTPiHT1ZCLdwy6-_vY-_m21cX52Fiu3bmG62UzHLGpWg8HnA1sBTerUTkP5wQlA7_AQ36yuotWOk_j0k5toTjX9fjJ85Spcqu3yFbCDmmb1PlnF3O128d33a2iFIc7PzuLmxzfQbEyd0KxGayn18hQoYFY1S384zNrrdbG2to5WGGJ2JsCN6x9iqtEoZlbH7pUqWKYCBrTLrNlVSxbr9o7ww48_Iex0EMzM4KMPrqHROJdvVt_ajuE0sWuL083qC-4ya693hJ9_-RWdzj6mgwDXlt9Ho3GukJ9S6hM5k3C2kL0LeYK7zO0wa--oj98ePMD-_n-Ynp7G0tIi6vW6Fr_AM0KyGcPxOp1c-KKvwQlU_DvnY0RRhH6_j6OjHjgnMGZvHN61LXzP67QVQIMyzZoK7kgQBEzWJ_He0iKCIEAYhtjY2MSwPwBjDBO1Wm7h9HVyE0j1nAHnDe5RhQio1yextLig4Dc3fsdwOACIwEEYDgeoVmuxEuY6zsIVUSDLTJnBDfjJGhYX5hEEATphiM3NLQyHAxCn-Asd0Vqj4yEqExPxdzw5a5vDswsZAQqaNQVfq2FhYR7BzAw6nY6A76fgZYtxzjEaDsE5z9_GcxXQoU9jVhDqtUnMLwr4MMTW1kMBD0CYlhEBYCBIIxOi0QiVSgXS2aavXC72fq1yGrNK-KsLV1XPb289xHAwEGuTgAdIZQIQB4gBRByjKEKlXIaUyVonV4FTmhUC_sr8lRi-HeLR9jYGg0EqeRMeFMPHR-Pj42iMcqX8gruQBp1nVqnA2---gyAI0G63sbO9E-82XviYnFi8lrQFE1WOogjlctnBkB7ZT-ICZpXtRER48ucT7O3tYWf7kYCXOxqLeeVm4IRnAp6BiMAI4OOxVcB8BU5gVjP4wcEBHv_xGMfHx0ksisGEZyF7xgcPEn8xiKMnVUBVTcykzb7ENDUAhmq1BiIm4OGGl0JwFu9IJHeeBF55RLC4POB-DmitYbZMkddgVmKo1aoAAzhIsBGIi4pyWSoGxiSU8InglpknBZRX5ClQwKxFXoPBSpjQnq4AoIwg_q3CNKBYJPn_FuYsYKEWKmJWCR2fk61ltx0AVGUSKjFmLpjAy9bxMBT8PCDbyPCA7EMN2gpuJRgXW73nSHhSHZLqd2laV-Fc_e9WoKBZXcF9H4IYgHKlCvnKyRjAxQkTHp7CkSpcemR-uWtvoUj1udX3Et6RPGNAuVQCx1h8kGHKrEwrXNY27jKBpcDoeJQEKGBWBe-pmt52jDEwVkqZVW2zOfBEhCiK8hU4fPZsl3N-WWabwOsVkEGVZtAuSjYMmaBeQfFrnBBS0GoFsxVVuvjLyuBsnI3XfPwPw-dX-dA4uVQAAAAASUVORK5CYII%3D,applications:systemsettings.desktop"
                        }
                    },
                    "plugin": "org.kde.plasma.icontasks"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/Configuration/ConfigDialog": {
                            "DialogHeight": "540",
                            "DialogWidth": "720"
                        },
                        "/Configuration/General": {
                            "favoritesPortedToKAstats": "true"
                        },
                        "/Shortcuts": {
                            "global": "Alt+F1"
                        }
                    },
                    "plugin": "org.kde.plasma.kickerdash"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "3",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/ConfigDialog": {
                    "DialogHeight": "1080",
                    "DialogWidth": "170"
                }
            },
            "height": 4.222222222222222,
            "hiding": "autohide",
            "location": "left",
            "maximumLength": 60,
            "minimumLength": 14.777777777777779,
            "offset": 0
        }
    ],
    "serializationFormatVersion": "1"
}
;

plasma.loadSerializedLayout(layout);
