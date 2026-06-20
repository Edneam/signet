# Maintainer: Edneam <https://github.com/Edneam>
pkgname=scriptorium
pkgver=0.1.0
pkgrel=1
pkgdesc="Local, private voice dictation for Hyprland — speak, get clean text anywhere (whisper.cpp + Gemma, on-device)"
arch=('any')
url="https://github.com/Edneam/scriptorium"
license=('Apache-2.0')
depends=('bash' 'whisper.cpp' 'ollama' 'wtype' 'wl-clipboard' 'pipewire' 'ffmpeg' 'jq' 'curl' 'libnotify')
optdepends=('hyprland: push-to-talk keybinds (bind/bindr)')
source=("$pkgname-$pkgver.tar.gz::https://github.com/Edneam/scriptorium/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
  cd "$srcdir/$pkgname-$pkgver"
  install -Dm755 scriptorium "$pkgdir/usr/bin/scriptorium"
  install -Dm644 README.md   "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 LICENSE      "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}

# After install, run:  scriptorium setup   (downloads model, pulls gemma4:e2b, configures mic + Hyprland bind)
