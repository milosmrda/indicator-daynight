<p align="center"># indicator-daynight</p>

A wingpanel indicator to toggle 'prefer dark variant' option in Elementary OS.

<img src="https://raw.githubusercontent.com/maze-n/indicator-daynight/master/screenshots/screenshot.png" width="400">
</p>

## Install, build and run

```bash
# install elementary-sdk, meson and libwingpanel
sudo apt install elementary-sdk meson libwingpanel-2.0-dev
# clone repository
git clone {{repourl}} indicator-daynight
# cd to dir
cd indicator-daynight
# run meson
meson build --prefix=/usr
# cd to build, build and test
cd build
sudo ninja install
# restart switchboard to load your indicator
pkill wingpanel -9
```