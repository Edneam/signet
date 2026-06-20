# Maintainer: Edneam <https://github.com/Edneam>
# Note: AUR has an unrelated 'signet' package, so this is published as 'signet-voice'.
pkgname=signet-voice
_binname=signet
pkgver=0.2.0
pkgrel=1
pkgdesc="Local, private voice dictation + AI commands for Hyprland (whisper.cpp + Gemma, on-device)"
arch=('any')
url="https://github.com/Edneam/signet"
license=('Apache-2.0')
depends=('bash' 'whisper.cpp' 'ollama' 'wtype' 'wl-clipboard' 'pipewire' 'ffmpeg' 'jq' 'curl' 'libnotify')
optdepends=('hyprland: push-to-talk keybinds')
provides=('signet-voice')
source=("$pkgname-$pkgver.tar.gz::https://github.com/Edneam/signet/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
  cd "$srcdir/signet-$pkgver"
  install -Dm755 signet "$pkgdir/usr/bin/$_binname"
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 LICENSE   "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}

# After install: run  signet setup  (model, gemma pull, mic, cues, Hyprland binds)
